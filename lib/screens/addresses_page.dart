import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address_model.dart';
import '../providers/auth_provider.dart';
import 'map_address_picker_page.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  bool _isLoading = false;

  Future<void> _updateAddresses(List<AddressModel> newAddresses) async {
    print('Updating addresses: ${newAddresses.length} addresses');
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(addresses: newAddresses);
    setState(() => _isLoading = false);
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Failed to update addresses')),
      );
    } else {
      print('Addresses updated successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final addresses = user?.addresses ?? [];

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
            onPressed: () => _addOrEditAddress(null, addresses),
            child: const Text(
              'Add New',
              style: TextStyle(
                color: Color(0xFFFF6B00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
        : addresses.isEmpty 
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _buildAddressCard(address, addresses);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No addresses saved yet',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _addOrEditAddress(null, []),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add Your First Address', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _addOrEditAddress(AddressModel? initialAddress, List<AddressModel> currentAddresses) async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(
        builder: (context) => MapAddressPickerPage(initialAddress: initialAddress),
      ),
    );

    if (result != null && mounted) {
      List<AddressModel> newAddresses = List.from(currentAddresses);
      if (initialAddress == null) {
        // Adding new
        if (newAddresses.isEmpty) {
          newAddresses.add(result.copyWith(isDefault: true));
        } else {
          newAddresses.add(result);
        }
      } else {
        // Editing
        final index = newAddresses.indexWhere((a) => a.id == initialAddress.id);
        if (index != -1) {
          newAddresses[index] = result;
        }
      }
      _updateAddresses(newAddresses);
    }
  }

  Widget _buildAddressCard(AddressModel address, List<AddressModel> currentAddresses) {
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
            color: const Color(0xFFFF6B00).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            address.label.toLowerCase() == 'work' ? Icons.work_rounded : Icons.home_rounded, 
            color: const Color(0xFFFF6B00)
          ),
        ),
        title: Row(
          children: [
            Text(
              address.label,
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
            address.fullAddress,
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              List<AddressModel> newAddresses = List.from(currentAddresses);
              newAddresses.removeWhere((a) => a.id == address.id);
              // If we deleted the default, make another one default if available
              if (address.isDefault && newAddresses.isNotEmpty) {
                 newAddresses[0] = newAddresses[0].copyWith(isDefault: true);
              }
              _updateAddresses(newAddresses);
            } else if (value == 'edit') {
              _addOrEditAddress(address, currentAddresses);
            } else if (value == 'default') {
              List<AddressModel> newAddresses = currentAddresses.map((a) {
                return a.copyWith(isDefault: a.id == address.id);
              }).toList();
              _updateAddresses(newAddresses);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            if (!address.isDefault)
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
}
