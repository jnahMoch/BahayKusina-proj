import 'package:flutter/material.dart';
import 'logger.dart';

/// Custom exception classes for the app
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });

  factory AuthException.fromError(dynamic error, StackTrace? stackTrace) {
    final message = _parseAuthError(error);
    return AuthException(
      message: message,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static String _parseAuthError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('user-not-found') || errorString.contains('invalid-credential')) {
      return "You don't have an account. Please Sign Up!";
    }
    if (errorString.contains('wrong-password')) {
      return 'Invalid password. Please try again.';
    }
    if (errorString.contains('user-disabled')) {
      return 'This user account has been disabled.';
    }
    if (errorString.contains('too-many-requests')) {
      return 'Too many login attempts. Please try again later.';
    }
    if (errorString.contains('operation-not-allowed')) {
      return 'This operation is not allowed.';
    }
    if (errorString.contains('invalid-email')) {
      return 'Invalid email format.';
    }
    if (errorString.contains('weak-password')) {
      return 'Password is too weak. Please use a stronger password.';
    }
    if (errorString.contains('email-already-in-use')) {
      return 'This email is already registered.';
    }
    if (errorString.contains('network')) {
      return 'Network error. Please check your connection.';
    }
    
    return 'Authentication failed: $errorString';
  }
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.fromError(dynamic error, StackTrace? stackTrace) {
    return NetworkException(
      message: 'Network error: Unable to connect. Please check your internet connection.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// Firestore/Database exceptions
class DatabaseException extends AppException {
  DatabaseException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });

  factory DatabaseException.fromError(dynamic error, StackTrace? stackTrace) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('permission')) {
      return DatabaseException(
        message: 'Permission denied. You do not have access to this resource.',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    if (errorString.contains('not-found')) {
      return DatabaseException(
        message: 'Data not found.',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    if (errorString.contains('already-exists')) {
      return DatabaseException(
        message: 'This item already exists.',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    return DatabaseException(
      message: 'Database error. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Global error handler for the app
class ErrorHandler {
  static void handleError(
    dynamic error,
    StackTrace? stackTrace, {
    required BuildContext? context,
    bool showDialog = true,
  }) {
    // Log the error
    AppLogger.error('Error: $error\nStackTrace: $stackTrace');

    // Parse the error
    final message = _getErrorMessage(error);

    // Show error to user if context is provided
    if (context != null && showDialog) {
      showErrorDialog(context, message, error);
    }
  }

  /// Show error dialog
  static void showErrorDialog(
    BuildContext context,
    String message,
    dynamic error,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Get user-friendly error message
  static String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    if (error is ValidationException) {
      return error.message;
    }
    if (error is NetworkException) {
      return error.message;
    }
    if (error is DatabaseException) {
      return error.message;
    }
    if (error is FormatException) {
      return 'Invalid data format.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  /// Safely execute async function with error handling
  static Future<T?> safeExecute<T>(
    Future<T> Function() function, {
    required BuildContext? context,
    bool showDialog = true,
  }) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      handleError(error, stackTrace, context: context, showDialog: showDialog);
      return null;
    }
  }
}
