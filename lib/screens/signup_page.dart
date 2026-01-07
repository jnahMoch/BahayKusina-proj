import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../models/auth_user.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/signup_text_field.dart';
import '../utils/logger.dart';
import 'home_page.dart';
import 'vendor_home_page.dart';
import '../models/address_model.dart';
import 'map_address_picker_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String selectedRole = "Order Food";
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isLoading = false;
  List<AddressModel> _selectedAddresses = [];
  
  // Field error states
  bool _nameError = false;
  bool _emailError = false;
  bool _phoneError = false;
  bool _addressError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;

  // Password strength states
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  void _validatePassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasNumber = value.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _passwordError = value.isEmpty;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^(09|\+639)\d{9}$').hasMatch(phone);
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailPhoneController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    final name = _nameController.text;
    final email = _emailPhoneController.text;
    final phone = _phoneController.text;
    // final address = _addressController.text; // Removed as we use _selectedAddresses now
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _nameError = name.isEmpty;
      _emailError = email.isEmpty || !_isValidEmail(email);
      _phoneError = phone.isEmpty || !_isValidPhone(phone);
      _addressError = _selectedAddresses.isEmpty;
      _passwordError = password.isEmpty || !_hasMinLength || !_hasUppercase || !_hasLowercase || !_hasNumber;
      _confirmPasswordError = confirmPassword.isEmpty || confirmPassword != password;
    });

    if (_nameError || _emailError || _phoneError || _addressError || _passwordError || _confirmPasswordError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form (ensure address is selected)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);
    AppLogger.info('Sign up initiated for: ${_emailPhoneController.text}');

    try {
      final authProvider = context.read<AuthProvider>();
      final role = selectedRole == "Order Food"
          ? UserRole.customer
          : UserRole.vendor;

      final success = await authProvider.signup(
        fullName: name,
        email: email,
        phone: phone,
        addresses: _selectedAddresses,
        password: password,
        role: role,
      );

      if (success && mounted) {
        AppLogger.info('Signup successful. Redirecting user...');
        if (role == UserRole.vendor) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VendorHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else if (mounted) {
        final error =
            authProvider.errorMessage ?? 'Signup failed. Please try again.';
        AppLogger.error('Signup failed in UI: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      AppLogger.error('Unexpected error in Signup UI: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("I want to"),
                    const SizedBox(height: 10),
                    _buildRoleSelector(),
                    const SizedBox(height: 25),
                    _buildLabel(selectedRole == "Sell Food" ? "Full Name" : "Full Name"),
                    SignupTextField(
                      controller: _nameController,
                      hint: selectedRole == "Sell Food" 
                          ? "Your business name or personal name" 
                          : "Juan Dela Cruz",
                      keyboardType: TextInputType.name,
                      hasError: _nameError,
                      onChanged: (val) => setState(() => _nameError = val.isEmpty),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Email"),
                    SignupTextField(
                      controller: _emailPhoneController,
                      hint: "juan@example.com",
                      keyboardType: TextInputType.emailAddress,
                      hasError: _emailError,
                      onChanged: (val) => setState(() => _emailError = val.isEmpty || !_isValidEmail(val)),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Phone Number"),
                    SignupTextField(
                      controller: _phoneController,
                      hint: "09171234567",
                      keyboardType: TextInputType.phone,
                      hasError: _phoneError,
                      onChanged: (val) => setState(() => _phoneError = val.isEmpty || !_isValidPhone(val)),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel(selectedRole == "Sell Food" ? "Business Address" : "Delivery Address"),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final result = await Navigator.push<AddressModel>(
                          context,
                          MaterialPageRoute(builder: (context) => const MapAddressPickerPage()),
                        );
                        if (result != null) {
                          setState(() {
                            _selectedAddresses = [result.copyWith(isDefault: true)];
                            _addressController.text = result.fullAddress;
                            _addressError = false;
                          });
                        }
                      },
                      child: IgnorePointer(
                        child: SignupTextField(
                          controller: _addressController,
                          hint: "Tap to select address on map",
                          keyboardType: TextInputType.streetAddress,
                          hasError: _addressError,
                          onChanged: (val) {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Password"),
                    SignupTextField(
                      controller: _passwordController,
                      hint: "At least 8 characters",
                      isPassword: true,
                      obscureText: obscurePassword,
                      onToggleVisibility: () => setState(() => obscurePassword = !obscurePassword),
                      hasError: _passwordError,
                      onChanged: _validatePassword,
                    ),
                    const SizedBox(height: 10),
                    _buildPasswordStrength(),
                    const SizedBox(height: 10),
                    _buildLabel("Confirm Password"),
                    SignupTextField(
                      controller: _confirmPasswordController,
                      hint: "Re-enter your password",
                      isPassword: true,
                      obscureText: obscureConfirmPassword,
                      onToggleVisibility: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                      hasError: _confirmPasswordError,
                      onChanged: (val) => setState(() => _confirmPasswordError = val.isEmpty || val != _passwordController.text),
                    ),
                    const SizedBox(height: 30),
                    _buildTermsAndConditions(),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                    const SizedBox(height: 15),
                    _buildLoginLink(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: const BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    SizedBox(width: 5),
                    Text(
                      "Back",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrength() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStrengthItem("At least 8 characters", _hasMinLength),
        _buildStrengthItem("Uppercase letter", _hasUppercase),
        _buildStrengthItem("Lowercase letter", _hasLowercase),
        _buildStrengthItem("Contains a number", _hasNumber),
        _buildStrengthItem("Special character (Optional)", _hasSpecialChar),
      ],
    );
  }

  Widget _buildStrengthItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        _buildRoleButton("Order Food", "Order Food"),
        const SizedBox(width: 15),
        _buildRoleButton("Sell Food", "Sell Food"),
      ],
    );
  }

  Widget _buildRoleButton(String label, String value) {
    bool isSelected = selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = value),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.selectorBackground : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryOrange
                  : const Color.fromARGB(255, 243, 241, 241),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.circle, size: 8, color: Colors.black),
                ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black54, fontSize: 12),
        children: [
          const TextSpan(text: "By signing up, you agree to our "),
          TextSpan(
            text: "Terms of Service",
            style: const TextStyle(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Terms of Service")),
              ),
          ),
          const TextSpan(text: " and "),
          TextSpan(
            text: "Privacy Policy",
            style: const TextStyle(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Privacy Policy"))),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrangeLight,
          disabledBackgroundColor: Colors.grey.shade400,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black54, fontSize: 14),
          children: [
            const TextSpan(text: "Already have an account? "),
            TextSpan(
              text: "Log In",
              style: const TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
