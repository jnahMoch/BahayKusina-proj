import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address_model.dart';
import '../models/auth_user.dart';
import '../utils/error_handler.dart';
import '../utils/logger.dart';
import '../services/firestore_service.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  static final AuthProvider _instance = AuthProvider._internal();

  factory AuthProvider() {
    return _instance;
  }

  AuthProvider._internal() {
    checkAuthStatus();
  }

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  static const String _roleKey = 'user_role';

  // Getters
  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userRole =>
      _currentUser?.role == UserRole.vendor ? 'Vendor' : 'Customer';

  /// Helper to convert Firestore data and Firebase User to AuthUser
  AuthUser _createUser(firebase_auth.User user, Map<String, dynamic>? profile) {
    final roleStr =
        profile?['role']?.toString().toLowerCase().trim() ?? 'customer';
    final role = roleStr == 'vendor' ? UserRole.vendor : UserRole.customer;

    // Cache the role whenever we have a confirmed profile
    if (profile != null && profile.containsKey('role')) {
      AppLogger.info('Caching role: $roleStr for user: ${user.email}');
      _cacheRole(roleStr);
    }

    var addressList = <AddressModel>[];
    if (profile?['addresses'] != null) {
      addressList = (profile!['addresses'] as List)
          .map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
          .toList();
    } else if (profile?['address'] != null && profile!['address'] is String) {
      addressList.add(AddressModel(
        id: 'default',
        label: 'Default',
        fullName: profile['displayName'] ?? user.displayName ?? 'User',
        phoneNumber: profile['phone'] ?? '',
        region: '',
        province: '',
        city: '',
        barangay: '',
        streetAddress: profile['address'] as String,
        postalCode: '',
        latitude: 0.0,
        longitude: 0.0,
        isDefault: true,
      ));
    }

    return AuthUser(
      userId: user.uid,
      email: user.email ?? profile?['email'] ?? '',
      fullName: profile?['displayName'] ?? user.displayName ?? 'User',
      phone: profile?['phone'] ?? '',
      addresses: addressList,
      role: role,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  Future<void> _cacheRole(String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_roleKey, role.toLowerCase());
    } catch (e) {
      AppLogger.error('Error caching role: $e');
    }
  }

  Future<String?> _getCachedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_roleKey);
    } catch (e) {
      AppLogger.error('Error reading cached role: $e');
      return null;
    }
  }

  /// Login with email and password
  Future<bool> login(
    String email,
    String password, {
    String? expectedRole,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw firebase_auth.FirebaseAuthException(
                code: 'timeout',
                message: 'Login timed out. Check your connection.',
              );
            },
          );

      if (userCredential.user != null) {
        // Try to fetch profile from Firestore with timeout
        Map<String, dynamic>? profile;
        try {
          profile = await FirestoreService()
              .getUserProfile(userCredential.user!.uid)
              .timeout(const Duration(seconds: 5));
        } catch (e) {
          AppLogger.warning(
            'Firestore profile fetch timed out/failed during login. Using role selection/cache.',
          );
        }

        if (profile == null) {
          final cachedRole = await _getCachedRole();
          // If we have no network and no cache, use the role selected on the login screen
          final fallbackRole =
              expectedRole?.toLowerCase() ?? cachedRole ?? 'customer';
          _currentUser = _createUser(userCredential.user!, {
            'role': fallbackRole,
          });
        } else {
          _currentUser = _createUser(userCredential.user!, profile);
        }

        AppLogger.info(
          'Login successful: ${_currentUser?.email} (Role: ${_currentUser?.role})',
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      _errorMessage = AuthException.fromError(e, stackTrace).message;
    } catch (e, stackTrace) {
      _errorMessage = 'Login failed: $e';
      AppLogger.error('Login error: $e\n$stackTrace');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign up with email and password
  Future<bool> signup({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required List<AddressModel> addresses,
    required UserRole role,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw firebase_auth.FirebaseAuthException(
                code: 'timeout',
                message: 'Signup timed out. Check your connection.',
              );
            },
          );

      if (userCredential.user != null) {
        // Create profile in Firestore with a timeout so we don't hang the UI forever
        try {
          await Future.wait([
            userCredential.user!.updateDisplayName(fullName),
            FirestoreService().createUserProfile(
              userId: userCredential.user!.uid,
              email: email,
              displayName: fullName,
              phone: phone,
              addresses: addresses.map((a) => a.toJson()).toList(),
              role: role.toString().split('.').last,
            ),
          ]).timeout(const Duration(seconds: 10));
        } catch (e) {
          AppLogger.warning(
            'Firestore profile creation failed or timed out. User created but profile might be missing.',
          );
        }

        // Even if Firestore failed, we set the current user locally so they can enter the app
        _currentUser = _createUser(userCredential.user!, {
          'email': email,
          'displayName': fullName,
          'phone': phone,
          'addresses': addresses.map((a) => a.toJson()).toList(),
          'role': role.toString().split('.').last,
        });

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      _errorMessage = AuthException.fromError(e, stackTrace).message;
    } catch (e, stackTrace) {
      _errorMessage = 'Signup failed: $e';
      AppLogger.error('Signup error: $e\n$stackTrace');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firebaseAuth.signOut();
      _currentUser = null;

      // Clear cache on logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_roleKey);
    } catch (e, stackTrace) {
      _errorMessage = 'Logout failed: $e';
      AppLogger.error('Logout error: $e\n$stackTrace');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Password reset
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      _errorMessage = AuthException.fromError(e, stackTrace).message;
    } catch (e, stackTrace) {
      _errorMessage = 'Password reset failed: $e';
      AppLogger.error('Password reset error: $e\n$stackTrace');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    List<AddressModel>? addresses,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Updating profile for user: ${_currentUser?.userId}');
      if (addresses != null) {
        print('Addresses to update: ${addresses.length}');
        for (var addr in addresses) {
          print('Address: ${addr.fullName}, ${addr.streetAddress}');
        }
      }

      // Update local state first
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          fullName: fullName,
          phone: phone,
          addresses: addresses,
        );
        print('Profile updated locally, addresses: ${_currentUser!.addresses.length}');
      }

      // Try to update Firebase display name
      if (fullName != null && _firebaseAuth.currentUser != null) {
        try {
          await _firebaseAuth.currentUser!.updateDisplayName(fullName);
        } catch (e) {
          AppLogger.warning('Failed to update Firebase display name: $e');
        }
      }

      // Try to update Firestore
      if (_currentUser != null) {
        try {
          await FirestoreService().updateUserProfile(
            userId: _currentUser!.userId,
            displayName: fullName,
            phone: phone,
            addresses: addresses?.map((a) => a.toJson()).toList(),
          );
        } catch (e) {
          AppLogger.warning('Failed to update Firestore profile: $e');
          // Don't fail the whole operation, local state is updated
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Profile update failed: $e';
      AppLogger.error('Profile update error: $e\n$stackTrace');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    _firebaseAuth.authStateChanges().listen((firebase_auth.User? user) async {
      if (user != null) {
        Map<String, dynamic>? profile;
        try {
          profile = await FirestoreService()
              .getUserProfile(user.uid)
              .timeout(const Duration(seconds: 5));
        } catch (e) {
          AppLogger.warning(
            'Background auth check Firestore fetch timed out/failed.',
          );
        }

        if (profile == null) {
          final cachedRole = await _getCachedRole();
          _currentUser = _createUser(
            user,
            cachedRole != null ? {'role': cachedRole} : null,
          );
        } else {
          _currentUser = _createUser(user, profile);
        }

        AppLogger.info(
          'Auth status updated: ${user.email} (Role: ${_currentUser?.role})',
        );
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
