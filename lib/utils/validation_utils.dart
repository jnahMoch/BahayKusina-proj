/// Input validation utilities for the BahayKusina app
class ValidationUtils {
  // Email regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates email format
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (email.length > 100) {
      return 'Email is too long';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (password.length > 50) {
      return 'Password is too long';
    }
    return null;
  }

  /// Validates strong password (for signup)
  static String? validateStrongPassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    if (!password.contains(RegExp(r'\d'))) {
      return 'Password must contain a number';
    }
    if (!password.contains(RegExp(r'[@$!%*?&]'))) {
      return 'Password must contain a special character (@\$!%*?&)';
    }
    return null;
  }

  /// Validates phone number (Philippine format)
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (cleanPhone.length > 12) {
      return 'Phone number is too long';
    }
    return null;
  }

  /// Validates full name
  static String? validateFullName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Full name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (name.length > 100) {
      return 'Name is too long';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(name)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    return null;
  }

  /// Validates address
  static String? validateAddress(String? address) {
    if (address == null || address.isEmpty) {
      return 'Address is required';
    }
    if (address.length < 5) {
      return 'Address must be at least 5 characters';
    }
    if (address.length > 200) {
      return 'Address is too long';
    }
    return null;
  }

  /// Validates password confirmation
  static String? validatePasswordMatch(String? password, String? confirm) {
    if (confirm == null || confirm.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirm) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length == 10) {
      return '${cleanPhone.substring(0, 3)}-${cleanPhone.substring(3, 6)}-${cleanPhone.substring(6)}';
    }
    if (cleanPhone.length == 11) {
      return '${cleanPhone.substring(0, 4)}-${cleanPhone.substring(4, 7)}-${cleanPhone.substring(7)}';
    }
    return phone;
  }

  /// Sanitize email (trim and lowercase)
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Sanitize text input
  static String sanitizeText(String text) {
    return text.trim();
  }
}
