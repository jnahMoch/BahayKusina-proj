import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../models/auth_user.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/signup_text_field.dart';
import 'home_page.dart';
import 'vendor_home_page.dart';

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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
    if (_nameController.text.isEmpty ||
        _emailPhoneController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final role = selectedRole == "Order Food" ? UserRole.customer : UserRole.vendor;

      final success = await authProvider.signup(
        fullName: _nameController.text,
        email: _emailPhoneController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        password: _passwordController.text,
        role: role,
      );

      if (success && mounted) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Signup failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
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
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("I want to"),
                    const SizedBox(height: 10),
                    _buildRoleSelector(),
                    const SizedBox(height: 25),
                    _buildLabel("Full Name"),
                    SignupTextField(
                      controller: _nameController,
                      hint: "Juan Dela Cruz",
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Email"),
                    SignupTextField(
                      controller: _emailPhoneController,
                      hint: "juan@example.com",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Phone Number"),
                    SignupTextField(
                      controller: _phoneController,
                      hint: "09171234567",
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Delivery Address"),
                    SignupTextField(
                      controller: _addressController,
                      hint: "123 Mabini St., Barangay San Juan, Manila",
                      keyboardType: TextInputType.streetAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Password"),
                    SignupTextField(
                      controller: _passwordController,
                      hint: "At least 8 characters",
                      isPassword: true,
                      obscureText: obscurePassword,
                      onToggleVisibility: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Confirm Password"),
                    SignupTextField(
                      controller: _confirmPasswordController,
                      hint: "Re-enter your password",
                      isPassword: true,
                      obscureText: obscureConfirmPassword,
                      onToggleVisibility: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                    ),
                    const SizedBox(height: 30),
                    _buildTermsAndConditions(),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
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
                    Text("Back", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Create Account",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
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
              color: isSelected ? AppColors.primaryOrange : const Color.fromARGB(255, 243, 241, 241),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) const Padding(
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
            text: "Terms & Conditions",
            style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Terms & Conditions")),
              ),
          ),
          const TextSpan(text: " and "),
          TextSpan(
            text: "Privacy Policy",
            style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Privacy Policy")),
              ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                "Create Account",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
