import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color primaryOrange = Color(0xFFFF6B00);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      if (authProvider.currentUser?.role == 'vendor') {
        final vendorId = authProvider.currentUser?.userId ?? 'vendor_nanay';
        settingsProvider.initVendorSettings(vendorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isVendor = authProvider.currentUser?.role == 'vendor';
        final vendorId = authProvider.currentUser?.userId ?? 'vendor_nanay';

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.black87, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: isWideScreen ? 600 : double.infinity),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? 24 : 16,
                  vertical: 16,
                ),
                children: [
                  // VENDOR STORE SETTINGS (only show for vendors)
                  if (isVendor) ...[
                    _buildSectionHeader('STORE SETTINGS'),
                    _buildCard([
                      _buildSettingRow(
                        icon: Icons.store,
                        iconColor:
                            settings.isStoreOpen ? Colors.green : Colors.red,
                        title: 'Store Status',
                        subtitle:
                            settings.isStoreOpen ? 'Open for orders' : 'Closed',
                        trailing: Switch(
                          value: settings.isStoreOpen,
                          onChanged: (v) {
                            settings.setStoreOpen(v, vendorId: vendorId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(v
                                    ? '✓ Store is now OPEN'
                                    : '✓ Store is now CLOSED'),
                                backgroundColor: v ? Colors.green : Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          activeColor: Colors.green,
                        ),
                      ),
                      _buildDivider(),
                      _buildSettingRow(
                        icon: Icons.timer_outlined,
                        iconColor: Colors.blue,
                        title: 'Preparation Time',
                        subtitle: '${settings.preparationTime} minutes',
                        trailing: const Icon(Icons.chevron_right,
                            color: Colors.grey),
                        onTap: () => _showPreparationTimeDialog(
                            context, settings, vendorId),
                      ),
                      _buildDivider(),
                      _buildSettingRow(
                        icon: Icons.flash_auto,
                        iconColor: Colors.amber.shade700,
                        title: 'Auto-Accept Orders',
                        subtitle:
                            settings.autoAcceptOrders ? 'Enabled' : 'Disabled',
                        trailing: Switch(
                          value: settings.autoAcceptOrders,
                          onChanged: (v) {
                            settings.setAutoAcceptOrders(v, vendorId: vendorId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(v
                                    ? '✓ Auto-accept enabled'
                                    : '✓ Manual review enabled'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          activeColor: primaryOrange,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                  ],

                  // NOTIFICATIONS SECTION
                  _buildSectionHeader('NOTIFICATIONS'),
                  _buildCard([
                    _buildSettingRow(
                      icon: Icons.notifications_active_outlined,
                      iconColor: primaryOrange,
                      title: 'Order Notifications',
                      subtitle:
                          isVendor ? 'New order alerts' : 'Order status updates',
                      trailing: Switch(
                        value: settings.orderNotifications,
                        onChanged: (v) => settings.setOrderNotifications(v),
                        activeColor: primaryOrange,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),

                  // DATA & STORAGE SECTION
                  _buildSectionHeader('DATA & STORAGE'),
                  _buildCard([
                    _buildSettingRow(
                      icon: Icons.cached_outlined,
                      iconColor: Colors.teal,
                      title: 'Clear Cache',
                      subtitle: 'Free up storage space',
                      trailing:
                          const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => _showClearCacheDialog(context, settings),
                    ),
                  ]),
                  const SizedBox(height: 8),

                  // ABOUT SECTION
                  _buildSectionHeader('ABOUT'),
                  _buildCard([
                    _buildSettingRow(
                      icon: Icons.shield_outlined,
                      iconColor: Colors.blueGrey,
                      title: 'Privacy Policy',
                      subtitle: 'How we handle your data',
                      trailing:
                          const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => _showComingSoon(context, 'Privacy Policy'),
                    ),
                    _buildDivider(),
                    _buildSettingRow(
                      icon: Icons.article_outlined,
                      iconColor: Colors.blueGrey,
                      title: 'Terms of Service',
                      subtitle: 'App usage agreement',
                      trailing:
                          const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => _showComingSoon(context, 'Terms of Service'),
                    ),
                    _buildDivider(),
                    _buildSettingRow(
                      icon: Icons.info_outline,
                      iconColor: Colors.grey,
                      title: 'App Version',
                      subtitle: 'v1.0.0',
                    ),
                  ]),
                  const SizedBox(height: 8),

                  // ACCOUNT SECTION
                  _buildSectionHeader('ACCOUNT'),
                  _buildCard([
                    _buildSettingRow(
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      title: 'Log Out',
                      subtitle: 'Sign out of your account',
                      trailing:
                          const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => _showLogoutDialog(context, authProvider),
                      isDestructive: true,
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 56, color: Colors.grey.shade200);
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? Colors.red
                          : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPreparationTimeDialog(
      BuildContext context, SettingsProvider settings, String vendorId) {
    int selectedTime = settings.preparationTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Preparation Time',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Average time to prepare an order',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeButton(
                    icon: Icons.remove,
                    onPressed: selectedTime > 10
                        ? () => setDialogState(() => selectedTime -= 5)
                        : null,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$selectedTime min',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ),
                  ),
                  _buildTimeButton(
                    icon: Icons.add,
                    onPressed: selectedTime < 120
                        ? () => setDialogState(() => selectedTime += 5)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [15, 30, 45, 60]
                    .map(
                      (time) => ChoiceChip(
                        label: Text('$time min'),
                        selected: selectedTime == time,
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() => selectedTime = time);
                          }
                        },
                        selectedColor: primaryOrange.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: selectedTime == time
                              ? primaryOrange
                              : Colors.grey.shade700,
                          fontWeight: selectedTime == time
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                settings.setPreparationTime(selectedTime, vendorId: vendorId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('✓ Preparation time set to $selectedTime minutes'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton({required IconData icon, VoidCallback? onPressed}) {
    return Material(
      color: onPressed != null
          ? primaryOrange.withOpacity(0.1)
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onPressed != null ? primaryOrange : Colors.grey.shade400,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cache',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'This will clear all cached data. You may need to reload some data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              FirestoreService().clearAllCache();
              await settings.resetSettings();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Cache cleared successfully'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
