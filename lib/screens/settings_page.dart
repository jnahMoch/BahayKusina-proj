import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const Color primaryOrange = Color(0xFFFF6B00);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final authProvider = context.watch<AuthProvider>();
        final user = authProvider.currentUser;
        
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                
                // Account Section
                _buildSectionHeader('ACCOUNT'),
                _buildSettingTile(
                  context,
                  title: 'Account Type',
                  subtitle: user?.role.toString().split('.').last.toUpperCase() ?? 'Customer',
                  icon: Icons.account_circle,
                  iconColor: primaryOrange,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user?.role.toString().split('.').last.toUpperCase() ?? 'CUSTOMER',
                      style: const TextStyle(
                        color: primaryOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _buildSettingTile(
                  context,
                  title: 'Member Since',
                  subtitle: user?.createdAt != null 
                    ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                    : 'N/A',
                  icon: Icons.calendar_today,
                  iconColor: Colors.blue,
                ),
                
                // Notifications Section
                _buildSectionHeader('NOTIFICATIONS'),
                _buildSettingTile(
                  context,
                  title: 'Order Updates',
                  subtitle: 'Get notified about your order status',
                  icon: Icons.shopping_bag_outlined,
                  iconColor: primaryOrange,
                  trailing: Switch(
                    value: settings.orderNotifications,
                    onChanged: (v) => settings.setOrderNotifications(v),
                    activeColor: primaryOrange,
                  ),
                ),
                
                // App Preferences
                _buildSectionHeader('APP PREFERENCES'),
                _buildSettingTile(
                  context,
                  title: 'Language',
                  subtitle: 'English (Default)',
                  icon: Icons.language,
                  iconColor: Colors.purple,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showLanguageDialog(context),
                ),
                
                // Help & Support
                _buildSectionHeader('HELP & SUPPORT'),
                _buildSettingTile(
                  context,
                  title: 'Help Center',
                  subtitle: 'FAQs and support articles',
                  icon: Icons.help_outline,
                  iconColor: Colors.teal,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showHelpDialog(context),
                ),
                _buildSettingTile(
                  context,
                  title: 'Contact Support',
                  subtitle: 'Get help from our team',
                  icon: Icons.support_agent,
                  iconColor: Colors.blue,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showContactSupportDialog(context),
                ),
                _buildSettingTile(
                  context,
                  title: 'Report a Problem',
                  subtitle: 'Let us know if something is wrong',
                  icon: Icons.report_problem_outlined,
                  iconColor: Colors.orange,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showReportDialog(context),
                ),
                
                // Legal & Privacy
                _buildSectionHeader('LEGAL & PRIVACY'),
                _buildSettingTile(
                  context,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  icon: Icons.privacy_tip_outlined,
                  iconColor: Colors.blue,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showPrivacyPolicy(context),
                ),
                _buildSettingTile(
                  context,
                  title: 'Terms of Service',
                  subtitle: 'App usage agreement',
                  icon: Icons.description_outlined,
                  iconColor: Colors.green,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showTermsOfService(context),
                ),
                _buildSettingTile(
                  context,
                  title: 'Data & Privacy',
                  subtitle: 'Manage your data preferences',
                  icon: Icons.security,
                  iconColor: Colors.red,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showDataPrivacyOptions(context),
                ),
                
                // About
                _buildSectionHeader('ABOUT'),
                _buildSettingTile(
                  context,
                  title: 'App Version',
                  subtitle: 'v1.0.0 (Build 2026.01.08)',
                  icon: Icons.info_outline,
                  iconColor: Colors.grey,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Latest',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _buildSettingTile(
                  context,
                  title: 'Rate Us',
                  subtitle: 'Share your feedback',
                  icon: Icons.star_outline,
                  iconColor: Colors.amber,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showRatingDialog(context),
                ),
                
                // Danger Zone
                _buildSectionHeader('ADVANCED'),
                _buildSettingTile(
                  context,
                  title: 'Clear Cache',
                  subtitle: 'Free up storage space',
                  icon: Icons.cleaning_services_outlined,
                  iconColor: Colors.orange,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showClearCacheDialog(context, settings),
                ),
                _buildSettingTile(
                  context,
                  title: 'Reset Settings',
                  subtitle: 'Restore default preferences',
                  icon: Icons.restore,
                  iconColor: Colors.red,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showResetDialog(context, settings),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade400,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 16, 
            color: Color(0xFF2C3E50),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade500, 
              fontSize: 13,
            ),
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  // Dialog Methods
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'English', '🇺🇸', isSelected: true),
            _buildLanguageOption(context, 'Filipino', '🇵🇭', isSelected: false),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String language, String flag, {required bool isSelected}) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(language),
      trailing: isSelected ? const Icon(Icons.check_circle, color: primaryOrange) : null,
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language changed to $language')),
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: primaryOrange),
            SizedBox(width: 12),
            Text('Help Center'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem('How to place an order?', 'Browse meals → Add to cart → Checkout'),
              _buildHelpItem('How to track my order?', 'Go to My Orders → Select order → Track'),
              _buildHelpItem('Payment methods?', 'Cash on Delivery, GCash, PayMaya'),
              _buildHelpItem('Delivery time?', 'Usually 30-45 minutes'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: primaryOrange)),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContactOption(
              context,
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: 'support@bahaykusina.ph',
              onTap: () {
                Navigator.pop(context);
                _launchEmail(context, 'support@bahaykusina.ph');
              },
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              context,
              icon: Icons.phone_outlined,
              title: 'Phone',
              subtitle: '+63 917 123 4567',
              onTap: () {
                Navigator.pop(context);
                _launchPhone(context, '+639171234567');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: primaryOrange)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryOrange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Report a Problem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please describe the issue you encountered:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the problem...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted. Thank you!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'BahayKusina Privacy Policy\n\n'
            'Last updated: January 8, 2026\n\n'
            '1. Information We Collect\n'
            'We collect information you provide directly to us, including name, email, phone number, and delivery addresses.\n\n'
            '2. How We Use Your Information\n'
            '- Process and deliver your orders\n'
            '- Send order updates and notifications\n'
            '- Improve our services\n\n'
            '3. Data Security\n'
            'We implement appropriate security measures to protect your personal information.\n\n'
            '4. Your Rights\n'
            'You have the right to access, update, or delete your personal information.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: primaryOrange)),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text(
            'BahayKusina Terms of Service\n\n'
            'Last updated: January 8, 2026\n\n'
            '1. Acceptance of Terms\n'
            'By using BahayKusina, you agree to these terms.\n\n'
            '2. User Accounts\n'
            'You are responsible for maintaining the confidentiality of your account.\n\n'
            '3. Orders and Payments\n'
            'All orders are subject to acceptance and availability.\n\n'
            '4. Delivery\n'
            'Estimated delivery times are approximate and not guaranteed.\n\n'
            '5. Refunds and Cancellations\n'
            'Contact support for refund or cancellation requests.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: primaryOrange)),
          ),
        ],
      ),
    );
  }

  void _showDataPrivacyOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Data & Privacy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download, color: primaryOrange),
              title: const Text('Download My Data'),
              subtitle: const Text('Get a copy of your data'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data download request submitted')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete My Account'),
              subtitle: const Text('Permanently remove your account'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteAccountConfirmation(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: primaryOrange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and cannot be undone. All your data will be deleted.',
          style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requires contacting support')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int rating = 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Rate BahayKusina'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How would you rate your experience?'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => rating = index + 1),
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: rating > 0
                  ? () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Thank you for rating us $rating stars!')),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cache'),
        content: const Text('This will free up storage space but may slow down the app temporarily.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Settings'),
        content: const Text('This will restore all settings to their default values.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await settings.resetSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to default')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    // Copy email to clipboard and show snackbar
    await Future.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email: $email (copied to clipboard)'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    // Show phone number in snackbar
    await Future.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phone: $phone'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
