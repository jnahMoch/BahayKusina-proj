import 'package:flutter/material.dart';
import 'home_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _orderNotifications = true;
  bool _promoNotifications = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
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
            _buildSectionHeader('Notifications'),
            _buildSettingTile(
              title: 'Order Status',
              subtitle: 'Get notified about your meal updates',
              icon: Icons.receipt_long_rounded,
              trailing: Switch(
                value: _orderNotifications,
                onChanged: (v) => setState(() => _orderNotifications = v),
                activeColor: HomePage.primaryOrange,
              ),
            ),
            _buildSettingTile(
              title: 'Promotions',
              subtitle: 'Special offers and new package alerts',
              icon: Icons.local_offer_rounded,
              trailing: Switch(
                value: _promoNotifications,
                onChanged: (v) => setState(() => _promoNotifications = v),
                activeColor: HomePage.primaryOrange,
              ),
            ),
            
            _buildSectionHeader('Appearance'),
            _buildSettingTile(
              title: 'Dark Mode',
              subtitle: 'Easier on the eyes in low light',
              icon: Icons.dark_mode_rounded,
              trailing: Switch(
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
                activeColor: HomePage.primaryOrange,
              ),
            ),
            
            _buildSectionHeader('Safety & Legals'),
            _buildSettingTile(
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              icon: Icons.privacy_tip_rounded,
              onTap: () {},
            ),
            _buildSettingTile(
              title: 'Terms of Service',
              subtitle: 'App usage agreement',
              icon: Icons.description_rounded,
              onTap: () {},
            ),
            _buildSettingTile(
              title: 'App Version',
              subtitle: 'v1.0.0 (Stable)',
              icon: Icons.info_rounded,
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: HomePage.primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: HomePage.primaryOrange, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F3557)),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey) : null),
      ),
    );
  }
}
