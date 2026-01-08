import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address_model.dart';
import '../providers/auth_provider.dart';
import 'map_address_picker_page.dart';

class AddressSelectionPage extends StatelessWidget {
  const AddressSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final addresses = user?.addresses ?? [];
    const primaryOrange = Color(0xFFFF6B00);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryOrange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Address Selection',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade50,
            child: const Text('Address', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(
            child: addresses.isEmpty
                ? const Center(child: Text('No addresses saved yet'))
                : ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return _buildAddressItem(context, address, primaryOrange);
                    },
                  ),
          ),
          _buildAddAddressButton(context, primaryOrange),
        ],
      ),
    );
  }

  Widget _buildAddressItem(BuildContext context, AddressModel address, Color primaryOrange) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, address);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.radio_button_checked, color: primaryOrange, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.streetAddress,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${address.barangay}, ${address.city}, ${address.province},',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${address.region}, ${address.postalCode}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (address.isDefault)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryOrange),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'Default',
                        style: TextStyle(color: primaryOrange, fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _editAddress(context, address),
              child: const Text('Edit', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAddressButton(BuildContext context, Color primaryOrange) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: () => _addNewAddress(context),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primaryOrange),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: primaryOrange),
              const SizedBox(width: 8),
              Text('Add a new address', style: TextStyle(color: primaryOrange, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addNewAddress(BuildContext context) async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(builder: (context) => const MapAddressPickerPage()),
    );

    if (result != null) {
      print('Adding new address: ${result.fullName}');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user != null) {
        final updatedAddresses = List<AddressModel>.from(user.addresses);
        if (result.isDefault) {
          for (var i = 0; i < updatedAddresses.length; i++) {
            updatedAddresses[i] = updatedAddresses[i].copyWith(isDefault: false);
          }
        }
        updatedAddresses.add(result);
        print('Updating profile with ${updatedAddresses.length} addresses');
        await authProvider.updateProfile(addresses: updatedAddresses);
        print('Profile updated, addresses in provider: ${authProvider.currentUser?.addresses.length}');
        // Return the newly added address to the checkout page
        if (context.mounted) {
          Navigator.pop(context, result);
        }
      }
    }
  }

  Future<void> _editAddress(BuildContext context, AddressModel address) async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(builder: (context) => MapAddressPickerPage(initialAddress: address)),
    );

    if (result != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user != null) {
        final updatedAddresses = List<AddressModel>.from(user.addresses);
        final index = updatedAddresses.indexWhere((a) => a.id == result.id);
        if (index != -1) {
          if (result.isDefault) {
            for (var i = 0; i < updatedAddresses.length; i++) {
              updatedAddresses[i] = updatedAddresses[i].copyWith(isDefault: false);
            }
          }
          updatedAddresses[index] = result;
          await authProvider.updateProfile(addresses: updatedAddresses);
          // Return the edited address to the checkout page
          if (context.mounted) {
            Navigator.pop(context, result);
          }
        }
      }
    }
  }
}
