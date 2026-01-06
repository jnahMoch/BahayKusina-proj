// lib/screens/manage_packages_view.dart

import 'package:flutter/material.dart';
import 'add_package_page.dart';

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
              // Inside ManagePackagesView
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
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: const [
              _VendorPackageCard(
                title: "Ultimate Breakfast Package",
                category: "Breakfast",
                price: 150,
                stock: 20,
                items: 4,
                imageUrl: 'assets/images/breakfast.jpg',
                isAvailable: true,
              ),
              // Add more cards here...
            ],
          ),
        ),
      ],
    );
  }
}

class _VendorPackageCard extends StatelessWidget {
  final String title, category, imageUrl;
  final int price, stock, items;
  final bool isAvailable;

  const _VendorPackageCard({
    required this.title,
    required this.category,
    required this.price,
    required this.stock,
    required this.items,
    required this.imageUrl,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
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
              Image.asset(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
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
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(category, style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(height: 15),
                _rowInfo("Price:", "₱$price", isPrice: true),
                _rowInfo("Stock:", "$stock available"),
                _rowInfo("Items:", "$items items"),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _actionBtn(Icons.edit_outlined, "Edit", onPressed: () => _editPackage(context))),
                    const SizedBox(width: 8),
                    Expanded(child: _actionBtn(Icons.copy_outlined, "Duplicate", onPressed: () => _duplicatePackage(context))),
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

  Widget _actionBtn(IconData icon, String label, {bool isDelete = false, VoidCallback? onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed ?? () {},
      icon: Icon(icon, size: 16, color: isDelete ? Colors.red : Colors.black87),
      label: Text(
        label,
        style: TextStyle(color: isDelete ? Colors.red : Colors.black87),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  void _editPackage(BuildContext context) {
    // Navigate to edit page (for now, just show a snackbar)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Edit $title")),
    );
  }

  void _duplicatePackage(BuildContext context) {
    // Navigate to add page with pre-filled data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPackagePage(
          initialTitle: "$title (Copy)",
          initialCategory: category,
          initialPrice: price.toString(),
          initialStock: stock.toString(),
          initialDesc: "Copy of $title",
        ),
      ),
    );
  }

  void _deletePackage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Package"),
        content: Text("Are you sure you want to delete '$title'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Delete logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$title deleted")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
