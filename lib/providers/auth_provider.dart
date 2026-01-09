import 'dart:convert';
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
  bool _loginInProgress = false; // Flag to prevent auth listener from overwriting during login

  static const String _roleKey = 'user_role';
  static const String _profileKey = 'cached_user_profile';

  // Getters
  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userRole =>
      _currentUser?.role == UserRole.vendor ? 'Vendor' : 'Customer';

  /// Helper to convert Firestore data and Firebase User to AuthUser
  AuthUser _createUser(firebase_auth.User user, Map<String, dynamic>? profile) {
    print('👤 _createUser called for: ${user.email}');
    print('   profile = $profile');
    
    final rawRole = profile?['role'];
    final roleStr = rawRole?.toString().toLowerCase().trim() ?? 'customer';
    final role = roleStr == 'vendor' ? UserRole.vendor : UserRole.customer;
    
    print('   rawRole = $rawRole');
    print('   roleStr = "$roleStr"');
    print('   UserRole = $role');
    
    AppLogger.info('_createUser: rawRole=$rawRole, roleStr=$roleStr, finalRole=$role');

    // Cache the role whenever we have a confirmed profile
    if (profile != null && profile.containsKey('role')) {
      AppLogger.info('Caching role: $roleStr for user: ${user.email}');
      _cacheRole(roleStr);
    }

    var addressList = <AddressModel>[];
    if (profile?['addresses'] != null) {
      AppLogger.info(
        'Found addresses in profile: ${(profile!['addresses'] as List).length}',
      );
      addressList = (profile['addresses'] as List)
          .map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
          .toList();
    } else if (profile?['address'] != null && profile!['address'] is String) {
      AppLogger.info('Found legacy string address, converting to AddressModel');
      addressList.add(
        AddressModel(
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
        ),
      );
    } else {
      AppLogger.warning('No addresses found in profile for ${user.email}');
    }

    final phoneNumber = profile?['phone']?.toString() ?? '';
    AppLogger.info(
      'Creating AuthUser - Phone: $phoneNumber, Addresses: ${addressList.length}',
    );

    final authUser = AuthUser(
      userId: user.uid,
      email: user.email ?? profile?['email'] ?? '',
      fullName: profile?['displayName'] ?? user.displayName ?? 'User',
      phone: phoneNumber,
      addresses: addressList,
      role: role,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );

    // Cache the profile for offline/fast fallback
    _cacheProfile({
      'email': authUser.email,
      'displayName': authUser.fullName,
      'phone': authUser.phone,
      'role': roleStr,
      'addresses': addressList.map((a) => a.toJson()).toList(),
    });

    return authUser;
  }

  Future<void> _cacheRole(String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_roleKey, role.toLowerCase());
    } catch (e) {
      AppLogger.error('Error caching role: $e');
    }
  }

  Future<void> _cacheProfile(Map<String, dynamic> profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, jsonEncode(profile));
      AppLogger.info('Profile cached locally');
    } catch (e) {
      AppLogger.error('Error caching profile: $e');
    }
  }

  Future<Map<String, dynamic>?> _getCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_profileKey);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      AppLogger.info('Loaded cached profile from local storage');
      return map;
    } catch (e) {
      AppLogger.error('Error reading cached profile: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> _mergeWithCachedProfile(
    Map<String, dynamic> profile,
  ) async {
    final cached = await _getCachedProfile();
    if (cached == null) return profile;

    final merged = Map<String, dynamic>.from(profile);
    final phone = (merged['phone'] ?? '').toString();
    final cachedPhone = (cached['phone'] ?? '').toString();
    if (phone.isEmpty && cachedPhone.isNotEmpty) {
      merged['phone'] = cachedPhone;
      AppLogger.info('Merged phone from cache');
    }

    final mergedAddresses = merged['addresses'];
    final cachedAddresses = cached['addresses'];
    if (mergedAddresses is List && cachedAddresses is List) {
      if (mergedAddresses.isEmpty && cachedAddresses.isNotEmpty) {
        merged['addresses'] = cachedAddresses;
        AppLogger.info('Merged addresses from cache');
      }
    }

    return merged;
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
  /// Returns the role string if successful, null if failed
  Future<String?> login(
    String email,
    String password, {
    String? expectedRole,
  }) async {
    try {
      _isLoading = true;
      _loginInProgress = true; // Prevent auth listener from interfering
      _errorMessage = null;
      notifyListeners();

      print('🔐 LOGIN STARTED for: $email');

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
        print('🔐 Firebase auth successful for: ${userCredential.user!.email}');
        
        // Try to fetch profile from Firestore with timeout
        Map<String, dynamic>? profile;
        try {
          profile = await FirestoreService()
              .getUserProfile(userCredential.user!.uid)
              .timeout(const Duration(seconds: 10));

          if (profile != null) {
            print('🔐 Firestore profile loaded: role=${profile['role']}');
            AppLogger.info(
              'Login: Profile loaded successfully with ${(profile['addresses'] as List?)?.length ?? 0} addresses',
            );
          } else {
            print('🔐 Firestore returned null profile');
          }
        } catch (e) {
          print('🔐 Firestore profile fetch failed: $e');
          AppLogger.warning(
            'Firestore profile fetch timed out/failed during login. Using role selection/cache: $e',
          );
        }

        String finalRole;
        
        if (profile != null && profile['role'] != null) {
          // USE FIRESTORE ROLE - this is the source of truth
          finalRole = profile['role'].toString().toLowerCase().trim();
          print('🔐 Using Firestore role: $finalRole');
          
          final mergedProfile = await _mergeWithCachedProfile(profile);
          _currentUser = _createUser(userCredential.user!, mergedProfile);
          AppLogger.info('Login: Using Firestore profile data');
        } else {
          // Fallback: No Firestore profile, use expectedRole from login screen
          finalRole = expectedRole?.toLowerCase() ?? 'customer';
          print('🔐 No Firestore profile, using expectedRole: $finalRole');
          
          _currentUser = _createUser(userCredential.user!, {
            'role': finalRole,
            'email': userCredential.user!.email,
            'displayName': userCredential.user!.displayName,
          });
          AppLogger.warning('Login: Using fallback role (no Firestore profile)');
        }

        // Cache profile data for faster subsequent loads
        if (_currentUser != null) {
          await _cacheProfile({
            'email': _currentUser!.email,
            'displayName': _currentUser!.fullName,
            'phone': _currentUser!.phone,
            'role': finalRole,
            'addresses': _currentUser!.addresses
                .map((a) => a.toJson())
                .toList(),
          });
        }

        print('🔐 LOGIN COMPLETE - Final role: $finalRole');
        AppLogger.info('Login successful: ${_currentUser?.email} (Role: $finalRole)');

        _isLoading = false;
        _loginInProgress = false;
        notifyListeners();
        return finalRole;
      }
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      print('🔐 LOGIN FAILED: ${e.message}');
      _loginInProgress = false;
      _errorMessage = AuthException.fromError(e, stackTrace).message;
    } catch (e, stackTrace) {
      _loginInProgress = false;
      _errorMessage = 'Login failed: $e';
      AppLogger.error('Login error: $e\n$stackTrace');
    }

    _isLoading = false;
    _loginInProgress = false; // Ensure flag is reset on any exit
    notifyListeners();
    return null;
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
          AppLogger.info(
            'Creating user profile - Name: $fullName, Phone: $phone, Addresses: ${addresses.length}',
          );

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

          AppLogger.info('User profile created successfully in Firestore');
        } catch (e) {
          AppLogger.warning(
            'Firestore profile creation failed or timed out: $e',
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

        AppLogger.info(
          'Current user set - Phone: ${_currentUser?.phone}, Addresses: ${_currentUser?.addresses.length}',
        );

        // Cache profile
        await _cacheProfile({
          'email': _currentUser!.email,
          'displayName': _currentUser!.fullName,
          'phone': _currentUser!.phone,
          'role': _currentUser!.role.toString().split('.').last,
          'addresses': _currentUser!.addresses.map((a) => a.toJson()).toList(),
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
      // Preserve cached profile to assist re-login if Firestore is slow/missing
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
        print(
          'Profile updated locally, addresses: ${_currentUser!.addresses.length}',
        );
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

          // Cache the updated profile locally
          await _cacheProfile({
            'email': _currentUser!.email,
            'displayName': _currentUser!.fullName,
            'phone': _currentUser!.phone,
            'role': _currentUser!.role.toString().split('.').last,
            'addresses': _currentUser!.addresses
                .map((a) => a.toJson())
                .toList(),
          });
          AppLogger.info('Profile updated and cached successfully');
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
    _isLoading = true;
    notifyListeners();

    _firebaseAuth.authStateChanges().listen((firebase_auth.User? user) async {
      // Skip processing if login is in progress to avoid overwriting user set by login()
      if (_loginInProgress) {
        AppLogger.info('Auth state changed but login in progress, skipping');
        return;
      }
      
      if (user != null) {
        Map<String, dynamic>? profile;
        try {
          profile = await FirestoreService()
              .getUserProfile(user.uid)
              .timeout(const Duration(seconds: 10));

          if (profile != null) {
            AppLogger.info(
              'Profile loaded from Firestore: ${profile['displayName']}',
            );
          }
        } catch (e) {
          AppLogger.warning(
            'Background auth check Firestore fetch timed out/failed: $e',
          );
        }

        if (profile == null) {
          final cachedRole = await _getCachedRole();
          final cachedProfile = await _getCachedProfile();

          if (cachedProfile != null) {
            AppLogger.warning('Using cached profile for ${user.email}');
            _currentUser = _createUser(user, {
              'role': cachedRole ?? cachedProfile['role'] ?? 'customer',
              'email': cachedProfile['email'] ?? user.email,
              'displayName': cachedProfile['displayName'] ?? user.displayName,
              'phone': cachedProfile['phone'] ?? '',
              'addresses': cachedProfile['addresses'] is List
                  ? cachedProfile['addresses']
                  : [],
            });
          } else {
            _currentUser = _createUser(
              user,
              cachedRole != null ? {'role': cachedRole} : null,
            );
            AppLogger.warning(
              'Using cached/default role only for ${user.email}',
            );
          }
        } else {
          final mergedProfile = await _mergeWithCachedProfile(profile);
          _currentUser = _createUser(user, mergedProfile);
          AppLogger.info(
            'Profile fully loaded from Firestore (merged with cache if needed)',
          );
        }

        AppLogger.info(
          'Auth status updated: ${user.email} (Role: ${_currentUser?.role}, Addresses: ${_currentUser?.addresses.length})',
        );
      } else {
        _currentUser = null;
        AppLogger.info('User logged out');
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Force refresh the profile from Firestore (used when data looks missing)
  Future<void> refreshUserProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      AppLogger.warning('refreshUserProfile called but no firebase user');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final profile = await FirestoreService()
          .getUserProfile(user.uid)
          .timeout(const Duration(seconds: 10));

      if (profile != null) {
        final mergedProfile = await _mergeWithCachedProfile(profile);
        _currentUser = _createUser(user, mergedProfile);
        AppLogger.info('Profile refreshed from Firestore for ${user.email}');
      } else {
        // fallback to cached profile if available
        final cached = await _getCachedProfile();
        if (cached != null) {
          _currentUser = _createUser(user, {
            'role': cached['role'] ?? 'customer',
            'email': cached['email'] ?? user.email,
            'displayName': cached['displayName'] ?? user.displayName,
            'phone': cached['phone'] ?? '',
            'addresses': cached['addresses'] is List ? cached['addresses'] : [],
          });
          AppLogger.warning(
            'refreshUserProfile: Using cached profile for ${user.email}',
          );
        } else {
          AppLogger.warning(
            'refreshUserProfile: No profile found for ${user.email}',
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('refreshUserProfile error: $e\n$stackTrace');
    }

    _isLoading = false;
    notifyListeners();
  }
}
