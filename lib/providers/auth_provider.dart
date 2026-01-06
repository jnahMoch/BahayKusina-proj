import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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

  AuthProvider._internal();

  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userRole => _currentUser?.role == UserRole.vendor ? 'Vendor' : 'Customer';

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Fetch user profile from Firestore
        final userProfile = await FirestoreService().getUserProfile(userCredential.user!.uid);

        _currentUser = AuthUser(
          userId: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          fullName: userCredential.user!.displayName ?? email.split('@')[0],
          phone: userProfile?['phone'] ?? userCredential.user!.phoneNumber ?? '',
          address: userProfile?['address'] ?? '',
          role: userProfile?['role'] == 'vendor' ? UserRole.vendor : UserRole.customer,
          createdAt: userCredential.user!.metadata.creationTime ?? DateTime.now(),
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
    required String address,
    required UserRole role,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(fullName);

        // Create user profile in Firestore
        await FirestoreService().createUserProfile(
          userId: userCredential.user!.uid,
          email: email,
          displayName: fullName,
          phone: phone,
          address: address,
          role: role.toString().split('.').last,
        );

        _currentUser = AuthUser(
          userId: userCredential.user!.uid,
          email: email,
          fullName: fullName,
          phone: phone,
          address: address,
          role: role,
          createdAt: DateTime.now(),
        );

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
    String? address,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (fullName != null && _firebaseAuth.currentUser != null) {
        await _firebaseAuth.currentUser!.updateDisplayName(fullName);
      }

      if (_currentUser != null) {
        // Update in Firestore
        await FirestoreService().updateUserProfile(
          userId: _currentUser!.userId,
          displayName: fullName,
          phone: phone,
          address: address,
        );

        // Update local state
        _currentUser = AuthUser(
          userId: _currentUser!.userId,
          email: _currentUser!.email,
          fullName: fullName ?? _currentUser!.fullName,
          phone: phone ?? _currentUser!.phone,
          address: address ?? _currentUser!.address,
          role: _currentUser!.role,
          createdAt: _currentUser!.createdAt,
        );
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
    try {
      _firebaseAuth.authStateChanges().listen((firebase_auth.User? user) async {
        if (user != null) {
          // Fetch user profile from Firestore
          final userProfile = await FirestoreService().getUserProfile(user.uid);

          _currentUser = AuthUser(
            userId: user.uid,
            email: user.email ?? '',
            fullName: user.displayName ?? 'User',
            phone: userProfile?['phone'] ?? user.phoneNumber ?? '',
            address: userProfile?['address'] ?? '',
            role: userProfile?['role'] == 'vendor' ? UserRole.vendor : UserRole.customer,
            createdAt: user.metadata.creationTime ?? DateTime.now(),
          );
        } else {
          _currentUser = null;
        }
        notifyListeners();
      });
    } catch (e) {
      AppLogger.error('Auth status check error: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
