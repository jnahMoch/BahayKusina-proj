import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const Color primaryOrange = Color(0xFFFF6B00);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
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
                _buildSectionHeader('NOTIFICATIONS'),
                _buildSettingTile(
                  context,
                  title: 'Order Status',
                  subtitle: 'Get notified about your meal updates',
                  icon: Icons.receipt_long,
                  iconColor: primaryOrange,
                  trailing: Switch(
                    value: settings.orderNotifications,
                    onChanged: (v) => settings.setOrderNotifications(v),
                    activeColor: primaryOrange,
                  ),
                ),
                _buildSettingTile(
                  context,
                  title: 'Promotions',
                  subtitle: 'Special offers and new package alerts',
                  icon: Icons.local_offer,
                  iconColor: primaryOrange,
                  trailing: Switch(
                    value: settings.promoNotifications,
                    onChanged: (v) => settings.setPromoNotifications(v),
                    activeColor: primaryOrange,
                  ),
                ),
                
                _buildSectionHeader('SAFETY & LEGALS'),
                _buildSettingTile(
                  context,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  icon: Icons.shield,
                  iconColor: primaryOrange,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy Policy - Coming Soon')),
                    );
                  },
                ),
                _buildSettingTile(
                  context,
                  title: 'Terms of Service',
                  subtitle: 'App usage agreement',
                  icon: Icons.description,
                  iconColor: primaryOrange,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Terms of Service - Coming Soon')),
                    );
                  },
                ),
                _buildSettingTile(
                  context,
                  title: 'App Version',
                  subtitle: 'v1.0.0 (Stable)',
                  icon: Icons.info,
                  iconColor: primaryOrange,
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
}
