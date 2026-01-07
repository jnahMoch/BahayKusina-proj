import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/address_model.dart';
import 'location_picker_page.dart';

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
    
    _isDefault = widget.address?.isDefault ?? widget.isDefaultInitially;
    _label = widget.address?.label ?? 'Home';
  }

  @override
  void dispose() {
    _nameController.dispose();

    _postalController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<Map<String, String?>>(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerPage()),
    );

    if (result != null) {
      setState(() {
        _selectedRegion = result['region'];
        _selectedProvince = result['province'];
        _selectedCity = result['city'];
        _selectedBarangay = result['barangay'];
      });
    }
  }

  void _submit() {
    if (_nameController.text.isEmpty || _selectedBarangay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
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
      latitude: widget.address?.latitude ?? 0.0,
      longitude: widget.address?.longitude ?? 0.0,
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
                  _buildTextField(_nameController, 'Full Name'),
                  const SizedBox(height: 16),

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
    final String locationText = _selectedBarangay != null
        ? '$_selectedRegion, $_selectedProvince, $_selectedCity, $_selectedBarangay'
        : 'Region, Province, City, Barangay';
        
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
                  color: _selectedBarangay != null ? Colors.black87 : Colors.grey.shade400,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
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
