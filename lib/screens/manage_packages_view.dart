// lib/screens/manage_packages_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_package_page.dart';
import '../providers/vendor_provider.dart';
import '../providers/auth_provider.dart';
import '../models/meal_package.dart';

class ManagePackagesView extends StatelessWidget {
  const ManagePackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Meal Packages",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Manage your meal package offerings",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddPackagePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text(
                  "Add Package",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<VendorProvider>(
            builder: (context, provider, child) {
              if (provider.meals.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final vendorId =
                      authProvider.currentUser?.userId ?? 'vendor_nanay';
                  provider.refreshVendorData(vendorId);
                },
                color: const Color(0xFFFF6B00),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.meals.length,
                  itemBuilder: (context, index) {
                    final meal = provider.meals[index];
                    return _VendorPackageCard(meal: meal);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No packages yet",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _VendorPackageCard extends StatelessWidget {
  final MealPackage meal;

  const _VendorPackageCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = meal.left > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildImage(),
              if (isAvailable)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Available",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(meal.type, style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(height: 15),
                _rowInfo("Price:", "₱${meal.price}", isPrice: true),
                _rowInfo("Stock:", "${meal.left} available"),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _actionBtn(
                        Icons.edit_outlined,
                        "Edit",
                        onPressed: () => _editPackage(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(
                        Icons.copy_outlined,
                        "Duplicate",
                        onPressed: () => _duplicatePackage(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(
                        Icons.delete_outline,
                        "Delete",
                        isDelete: true,
                        onPressed: () => _deletePackage(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (meal.imageUrl.startsWith('assets/')) {
      return Image.asset(
        meal.imageUrl,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (meal.imageUrl.isNotEmpty) {
      return Image.network(
        meal.imageUrl,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 160,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      return Container(
        height: 160,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }
  }

  Widget _rowInfo(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPrice ? const Color(0xFFFF6B00) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label, {
    bool isDelete = false,
    VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed ?? () {},
      icon: Icon(icon, size: 16, color: isDelete ? Colors.red : Colors.black87),
      label: Text(
        label,
        style: TextStyle(color: isDelete ? Colors.red : Colors.black87),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  void _editPackage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPackagePage(
          packageId: meal.id,
          initialTitle: meal.title,
          initialCategory: meal.type,
          initialPrice: meal.price.toString(),
          initialStock: meal.left.toString(),
          initialDesc: meal.desc,
        ),
      ),
    );
  }

  void _duplicatePackage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPackagePage(
          initialTitle: "${meal.title} (Copy)",
          initialCategory: meal.type,
          initialPrice: meal.price.toString(),
          initialStock: meal.left.toString(),
          initialDesc: meal.desc,
        ),
      ),
    );
  }

  void _deletePackage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Package"),
        content: Text("Are you sure you want to delete '${meal.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (meal.id.isNotEmpty && !meal.id.startsWith('fallback_')) {
                  await FirebaseFirestore.instance
                      .collection('meals')
                      .doc(meal.id)
                      .delete();
                }

                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final vendorId =
                    authProvider.currentUser?.userId ?? 'vendor_nanay';

                Provider.of<VendorProvider>(
                  context,
                  listen: false,
                ).refreshVendorData(vendorId);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${meal.title} deleted")),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error deleting: $e")));
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
