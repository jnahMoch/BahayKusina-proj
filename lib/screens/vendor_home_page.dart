// lib/screens/vendor_home_page.dart

import 'package:flutter/material.dart';
import 'manage_packages_view.dart';
import 'orders_view.dart';

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  int _selectedIndex = 0; // 0: Dashboard, 1: Manage, 2: Orders

  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color accentRed = Color(0xFFFF3D00);

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F9FA),
    body: Column(
      children: [
        _buildHeader(), // Your existing gradient header
        Expanded(
          child: Stack(
            children: [
              // SWITCHING LOGIC
              IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildDashboardMetrics(), // Move your existing ListView metrics here
                  const ManagePackagesView(),
                  const OrdersView(),
                ],
              ),
              
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(child: _buildFloatingToggle()),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Update your floating toggle to support 3 items
Widget _buildFloatingToggle() {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFE9EEF5),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _toggleItem("Dashboard", Icons.dashboard_outlined, 0),
        _toggleItem("Packages", Icons.inventory_2, 1),
        _toggleItem("Orders", Icons.shopping_bag_outlined, 2),
      ],
    ),
  );
}

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 25, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [accentRed, primaryOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text("Vendor Dashboard", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Nanay's Kitchen", style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const Icon(Icons.inventory_2, color: Colors.white, size: 22),
        ],
      ),
    );
  }

  Widget _buildDashboardMetrics() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _MetricCard(
          title: "Total Sales",
          value: "₱12,500",
          subtitle: "This month",
          icon: Icons.attach_money,
        ),
        _MetricCard(
          title: "Active Orders",
          value: "24",
          subtitle: "Pending delivery",
          icon: Icons.shopping_cart,
        ),
        _MetricCard(
          title: "Packages",
          value: "8",
          subtitle: "Available",
          icon: Icons.inventory,
        ),
        _MetricCard(
          title: "Customers",
          value: "156",
          subtitle: "Served",
          icon: Icons.people,
        ),
      ],
    );
  }

  Widget _toggleItem(String label, IconData icon, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.black : Colors.black54),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;

  const _MetricCard({required this.title, required this.value, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00))),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          Icon(icon, color: Colors.blueGrey.shade200, size: 24),
        ],
      ),
    );
  }
}