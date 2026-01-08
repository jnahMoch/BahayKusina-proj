import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'manage_packages_view.dart';
import 'orders_view.dart';
import 'edit_profile_page.dart';
import 'addresses_page.dart';
import 'notifications.dart';
import 'settings_page.dart';
import '../providers/vendor_provider.dart';
import '../providers/auth_provider.dart';

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  int _selectedIndex = 0; // 0: Dashboard, 1: Manage Packages, 2: Orders

  static const Color primaryOrange = Color(0xFFFF6B00);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRealtimeTracking();
      _refreshData();
    });
  }

  void _refreshData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    final vendorId = authProvider.currentUser?.userId ?? 'vendor_nanay';

    print('✓ Vendor Home: Starting data refresh for $vendorId');
    vendorProvider
        .refreshVendorData(vendorId)
        .then((_) {
          print('✓ Vendor Home: Data refresh completed');
        })
        .catchError((e) {
          print('⚠ Vendor Home: Data refresh error: $e');
        });
  }

  void _startRealtimeTracking() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    final vendorId = authProvider.currentUser?.userId ?? 'vendor_nanay';

    // Start listening for real-time order updates (non-blocking)
    print('✓ Vendor Home: Starting real-time order tracking');
    vendorProvider.startRealtimeOrderTracking(vendorId);
  }

  void _openProfileDrawer() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.currentUser;
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.orange.shade100,
                      child: const Icon(
                        Icons.store,
                        color: Colors.deepOrange,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? "Vendor Name",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          user?.email ?? "vendor@email.com",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('My Addresses'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressesPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help Center'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help Center - Coming Soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy Policy - Coming Soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    await authProvider.logout();
                    if (mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final vendorName = currentUser?.fullName ?? 'Vendor Dashboard';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              // Top bar with back, title, profile
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        _selectedIndex == 0 ? Icons.logout : Icons.arrow_back,
                        color: _selectedIndex == 0 ? Colors.red : Colors.black,
                      ),
                      onPressed: () async {
                        if (_selectedIndex == 0) {
                          // On Dashboard - logout
                          await authProvider.logout();
                          if (mounted) {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          }
                        } else {
                          // On other tabs - go back to Dashboard
                          setState(() {
                            _selectedIndex = 0;
                          });
                        }
                      },
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.store,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Vendor Dashboard',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              vendorName,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.black,
                      ),
                      onPressed: _openProfileDrawer,
                      tooltip: 'Profile',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<VendorProvider>(
        builder: (context, vendorProvider, child) {
          // Show notification when new order arrives
          if (vendorProvider.newOrderNotification != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    vendorProvider.newOrderNotification!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'View',
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() => _selectedIndex = 2); // Go to Orders tab
                      vendorProvider.clearNotification();
                    },
                  ),
                ),
              );
              vendorProvider.clearNotification();
            });
          }

          return Column(
            children: [
              // Tab navigation at TOP
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        "Dashboard",
                        Icons.dashboard_outlined,
                        0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTabButton(
                        "Packages",
                        Icons.inventory_2_outlined,
                        1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTabButton(
                        "Orders",
                        Icons.assignment_outlined,
                        2,
                      ),
                    ),
                  ],
                ),
              ),

              // Dashboard tab - show metric cards
              if (_selectedIndex == 0)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildMetricCard(
                        "Total Packages",
                        "${vendorProvider.activePackages}",
                        "Active packages",
                        Icons.inventory_2_outlined,
                        Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      _buildMetricCard(
                        "Total Orders",
                        "${vendorProvider.totalOrders}",
                        "${vendorProvider.pendingOrders} active",
                        Icons.shopping_bag_outlined,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildMetricCard(
                        "Total Revenue",
                        "₱${vendorProvider.totalSales}",
                        "All time",
                        Icons.trending_up_outlined,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildMetricCard(
                        "Avg. Order Value",
                        vendorProvider.totalOrders > 0
                            ? "₱${(vendorProvider.totalSales / vendorProvider.totalOrders).toStringAsFixed(0)}"
                            : "₱0",
                        "Per order",
                        Icons.analytics_outlined,
                        primaryOrange,
                      ),
                    ],
                  ),
                )
              else
                // Manage Packages or Orders tabs
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: IndexedStack(
                          index: _selectedIndex - 1,
                          children: const [ManagePackagesView(), OrdersView()],
                        ),
                      ),
                      if (vendorProvider.isLoading)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            color: primaryOrange,
                            minHeight: 3,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? primaryOrange : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? primaryOrange : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
