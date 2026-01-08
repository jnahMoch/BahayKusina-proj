import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../models/address_model.dart';
import '../providers/auth_provider.dart';
import 'map_address_picker_page.dart';

class AddEditAddressPage extends StatefulWidget {
  final AddressModel? address;
  final bool isDefaultInitially;

  const AddEditAddressPage({super.key, this.address, this.isDefaultInitially = false});

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  late TextEditingController _nameController;
  late TextEditingController _postalController;
  late TextEditingController _streetController;

  String? _selectedRegion;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedBarangay;
  double? _latitude;
  double? _longitude;
  
  bool _isDefault = false;
  String _label = 'Home';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.fullName ?? '');
    _postalController = TextEditingController(text: widget.address?.postalCode ?? '');
    _streetController = TextEditingController(text: widget.address?.streetAddress ?? '');
    
    _selectedRegion = widget.address?.region;
    _selectedProvince = widget.address?.province;
    _selectedCity = widget.address?.city;
    _selectedBarangay = widget.address?.barangay;
    _latitude = widget.address?.latitude;
    _longitude = widget.address?.longitude;
    
    _isDefault = widget.address?.isDefault ?? widget.isDefaultInitially;
    _label = widget.address?.label ?? 'Home';

    // Auto-fill the name from current user if available; field not shown
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if ((_nameController.text.isEmpty) && user != null && user.fullName.isNotEmpty) {
        _nameController.text = user.fullName;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();

    _postalController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(
        builder: (context) => MapAddressPickerPage(initialAddress: widget.address),
      ),
    );

    if (result != null) {
      setState(() {
        _nameController.text = result.fullName;
        _selectedRegion = result.region;
        _selectedProvince = result.province;
        _selectedCity = result.city;
        _selectedBarangay = result.barangay;
        _streetController.text = result.streetAddress;
        _postalController.text = result.postalCode;
        _latitude = result.latitude;
        _longitude = result.longitude;
        _label = result.label;
      });
    }
  }

  void _submit() {
    if (_streetController.text.isEmpty || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields and pick location from map')),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select location from map to get coordinates')),
      );
      return;
    }

    final address = AddressModel(
      id: widget.address?.id ?? const Uuid().v4(),
      label: _label,
      fullName: _nameController.text,
      phoneNumber: '',
      region: _selectedRegion ?? '',
      province: _selectedProvince ?? '',
      city: _selectedCity ?? '',
      barangay: _selectedBarangay ?? '',
      streetAddress: _streetController.text,
      postalCode: _postalController.text,
      latitude: _latitude ?? 0.0,
      longitude: _longitude ?? 0.0,
      isDefault: _isDefault,
    );

    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF6B00);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryOrange),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.address == null ? 'New Address' : 'Edit Address',
          style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 20),
                  // Name field removed (redundant with account name)

                  const SizedBox(height: 16),
                  _buildLocationSelector(),
                  const SizedBox(height: 16),
                  _buildTextField(_postalController, 'Postal Code', keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField(_streetController, 'Street Name, Building, House No.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Set as Default Address', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _isDefault,
                    onChanged: (val) => setState(() => _isDefault = val),
                    activeColor: primaryOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 1),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Text('Label As:', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 20),
                  _buildLabelChip('Work'),
                  const SizedBox(width: 12),
                  _buildLabelChip('Home'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('Submit', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF6B00))),
      ),
    );
  }

  Widget _buildLocationSelector() {
    final String locationText = _selectedCity != null
        ? '$_selectedRegion, $_selectedProvince, $_selectedCity, $_selectedBarangay'
        : 'Tap to select location on map';
        
    return InkWell(
      onTap: _pickLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                locationText,
                style: TextStyle(
                  color: _selectedCity != null ? Colors.black87 : Colors.grey.shade400,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.map_outlined, color: Color(0xFFFF6B00)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelChip(String label) {
    final isSelected = _label == label;
    const primaryOrange = Color(0xFFFF6B00);
    
    return InkWell(
      onTap: () => setState(() => _label = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade50,
          border: Border.all(color: isSelected ? primaryOrange : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? primaryOrange : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
