import 'package:flutter/material.dart';
import '../services/philippine_location_service.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final PhilippineLocationService _locationService = PhilippineLocationService();
  
  String? _selectedRegion;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedBarangay;

  List<String> _options = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    setState(() => _isLoading = true);
    _options = await _locationService.getRegions();
    setState(() => _isLoading = false);
  }

  Future<void> _loadProvinces() async {
    if (_selectedRegion == null) return;
    setState(() => _isLoading = true);
    _options = await _locationService.getProvinces(_selectedRegion!);
    setState(() => _isLoading = false);
  }

  Future<void> _loadCities() async {
    if (_selectedProvince == null) return;
    setState(() => _isLoading = true);
    _options = await _locationService.getCities(_selectedProvince!);
    setState(() => _isLoading = false);
  }

  Future<void> _loadBarangays() async {
    if (_selectedCity == null) return;
    setState(() => _isLoading = true);
    _options = await _locationService.getBarangays(_selectedCity!);
    setState(() => _isLoading = false);
  }

  void _handleOptionSelected(String option) {
    setState(() {
      if (_selectedRegion == null) {
        _selectedRegion = option;
        _loadProvinces();
      } else if (_selectedProvince == null) {
        _selectedProvince = option;
        _loadCities();
      } else if (_selectedCity == null) {
        _selectedCity = option;
        _loadBarangays();
      } else {
        _selectedBarangay = option;
        Navigator.pop(context, {
          'region': _selectedRegion,
          'province': _selectedProvince,
          'city': _selectedCity,
          'barangay': _selectedBarangay,
        });
      }
    });
  }

  void _reset() {
    setState(() {
      _selectedRegion = null;
      _selectedProvince = null;
      _selectedCity = null;
      _selectedBarangay = null;
    });
    _loadRegions();
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF6B00);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedRegion == null ? 'Select your region' : 'Select Location',
          style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_selectedRegion != null)
            TextButton(
              onPressed: _reset,
              child: const Text('Reset', style: TextStyle(color: primaryOrange)),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedRegion != null) _buildSelectedHierarchy(),
          if (_selectedRegion == null) _buildUseCurrentLocation(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryOrange))
                : ListView.separated(
                    itemCount: _options.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
                    itemBuilder: (context, index) {
                      final option = _options[index];
                      return ListTile(
                        title: Text(option),
                        onTap: () => _handleOptionSelected(option),
                        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedHierarchy() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHierarchyItem(_selectedRegion, true),
          if (_selectedRegion != null) _buildHierarchyConnector(),
          _buildHierarchyItem(_selectedProvince, _selectedRegion != null && _selectedProvince == null),
          if (_selectedProvince != null) _buildHierarchyConnector(),
          _buildHierarchyItem(_selectedCity, _selectedProvince != null && _selectedCity == null),
          if (_selectedCity != null) _buildHierarchyConnector(),
          _buildHierarchyItem(_selectedBarangay, _selectedCity != null && _selectedBarangay == null, label: 'Select Barangay'),
        ],
      ),
    );
  }

  Widget _buildHierarchyItem(String? value, bool isCurrent, {String? label}) {
    const primaryOrange = Color(0xFFFF6B00);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value != null ? Colors.grey.shade400 : (isCurrent ? primaryOrange : Colors.transparent),
            border: isCurrent && value == null ? Border.all(color: primaryOrange, width: 2) : null,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value ?? (isCurrent ? (label ?? 'Select...') : ''),
          style: TextStyle(
            color: isCurrent && value == null ? primaryOrange : (value != null ? Colors.black87 : Colors.grey),
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildHierarchyConnector() {
    return Container(
      margin: const EdgeInsets.only(left: 3.5),
      width: 1,
      height: 20,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildUseCurrentLocation() {
    return InkWell(
      onTap: () {
        // Implement current location logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Getting current location...')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: Color(0xFFFF6B00)),
            SizedBox(width: 8),
            Text('Use My Current Location', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
