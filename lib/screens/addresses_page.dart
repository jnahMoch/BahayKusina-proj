import 'package:flutter/material.dart';
import 'home_page.dart';

class AddressModel {
  final String title;
  final String address;
  final IconData icon;
  final bool isDefault;

  AddressModel({
    required this.title,
    required this.address,
    required this.icon,
    this.isDefault = false,
  });
}

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  final List<AddressModel> _addresses = [
    AddressModel(
      title: 'Home',
      address: '123 Mahogany St, Ecoland, Davao City, 8000',
      icon: Icons.home_rounded,
      isDefault: true,
    ),
    AddressModel(
      title: 'Work',
      address: 'UM Matina Campus, Gen. Douglas MacArthur Hwy, Davao City',
      icon: Icons.work_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'My Addresses',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => _showAddAddressDialog(),
            child: const Text(
              'Add New',
              style: TextStyle(
                color: HomePage.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final address = _addresses[index];
          return _buildAddressCard(address);
        },
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: HomePage.primaryOrange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(address.icon, color: HomePage.primaryOrange),
        ),
        title: Row(
          children: [
            Text(
              address.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (address.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            address.address,
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              setState(() {
                _addresses.remove(address);
              });
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'default', child: Text('Set as Default')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
          icon: const Icon(Icons.more_vert, color: Colors.grey),
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Address',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(label: 'Address Title (e.g., Home, Office)', hint: 'Enter title'),
            const SizedBox(height: 16),
            _buildTextField(label: 'Full Address', hint: 'Enter your detailed address', maxLines: 3),
            const SizedBox(height: 16),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomePage.primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Save Address',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }
}
