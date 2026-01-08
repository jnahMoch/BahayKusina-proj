import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/address_model.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';

class MapAddressPickerPage extends StatefulWidget {
  final AddressModel? initialAddress;

  const MapAddressPickerPage({super.key, this.initialAddress});

  @override
  State<MapAddressPickerPage> createState() => _MapAddressPickerPageState();
}

class _MapAddressPickerPageState extends State<MapAddressPickerPage> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(7.0736, 125.6128); // Default to Davao City
  bool _isLoading = false;
  
  final _labelController = TextEditingController(text: 'Home');
  final _fullNameController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _barangayController = TextEditingController();
  final _streetController = TextEditingController();
  final _postalController = TextEditingController();

  final GeocodingService _geocodingService = GeocodingService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _currentPosition = widget.initialAddress!.coordinates;
      _labelController.text = widget.initialAddress!.label;
      _fullNameController.text = widget.initialAddress!.fullName;
      _provinceController.text = widget.initialAddress!.province;
      _cityController.text = widget.initialAddress!.city;
      _barangayController.text = widget.initialAddress!.barangay;
      _streetController.text = widget.initialAddress!.streetAddress;
      _postalController.text = widget.initialAddress!.postalCode;
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    final pos = await _locationService.getCurrentLocation();
    if (pos != null) {
      _currentPosition = pos;
      _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
      await _reverseGeocode(pos);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _isLoading = true);
    final placemark = await _geocodingService.getPlaceMarkFromCoordinates(pos);
    if (placemark != null) {
      setState(() {
        _provinceController.text = placemark.administrativeArea ?? '';
        _cityController.text = placemark.locality ?? '';
        _barangayController.text = placemark.subLocality ?? '';
        _streetController.text = placemark.street ?? placemark.thoroughfare ?? '';
        _postalController.text = placemark.postalCode ?? '';
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Delivery Address'),
        backgroundColor: AppColors.primaryOrange,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  onCameraIdle: () {
                    // Update location and reverse geocode when user stops moving map
                  },
                  onTap: (pos) {
                    setState(() => _currentPosition = pos);
                    _reverseGeocode(pos);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _currentPosition,
                      draggable: true,
                      onDragEnd: (pos) {
                        setState(() => _currentPosition = pos);
                        _reverseGeocode(pos);
                      },
                    ),
                  },
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _getCurrentLocation,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: AppColors.primaryOrange),
                  ),
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryOrange),
                  ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Selected Location',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_currentPosition.latitude.toStringAsFixed(6)}, ${_currentPosition.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: AppColors.primaryOrange, size: 18),
                            SizedBox(width: 8),
                            Text('Location Summary', style: TextStyle(fontSize: 12, color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_streetController.text.isNotEmpty)
                          Text(
                            _streetController.text,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        if (_streetController.text.isNotEmpty) const SizedBox(height: 4),
                        if (_barangayController.text.isNotEmpty)
                          Text(
                            'Barangay ${_barangayController.text}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        if (_barangayController.text.isNotEmpty) const SizedBox(height: 2),
                        Text(
                          '${_cityController.text}, ${_provinceController.text}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        if (_postalController.text.isNotEmpty)
                          Text(
                            'Postal Code: ${_postalController.text}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '📍 ${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                   _buildTextField(_labelController, 'Address Label (e.g. Home, Office)', Icons.label),
                   const SizedBox(height: 12),
                   _buildTextField(_fullNameController, 'Full Name', Icons.person),
                   const SizedBox(height: 12),
                   Row(
                     children: [
                       Expanded(child: _buildTextField(_provinceController, 'Province', Icons.map)),
                       const SizedBox(width: 12),
                       Expanded(child: _buildTextField(_cityController, 'City', Icons.location_city)),
                     ],
                   ),
                   const SizedBox(height: 12),
                   _buildTextField(_barangayController, 'Barangay', Icons.location_on),
                   const SizedBox(height: 12),
                   _buildTextField(_streetController, 'Street Address / Building / House No.', Icons.home),
                   const SizedBox(height: 12),
                   _buildTextField(_postalController, 'Postal Code', Icons.mark_as_unread, keyboardType: TextInputType.number),
                   const SizedBox(height: 24),
                   SizedBox(
                     width: double.infinity,
                     height: 55,
                     child: ElevatedButton(
                       onPressed: _saveAddress,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.primaryOrange,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       ),
                       child: const Text('Save Address', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                     ),
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryOrange, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _saveAddress() {
    if (_fullNameController.text.isEmpty || _streetController.text.isEmpty || _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in full name, street and city')),
      );
      return;
    }

    final address = AddressModel(
      id: widget.initialAddress?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text,
      fullName: _fullNameController.text,
      phoneNumber: '',
      region: '',
      province: _provinceController.text,
      city: _cityController.text,
      barangay: _barangayController.text,
      streetAddress: _streetController.text,
      postalCode: _postalController.text,
      latitude: _currentPosition.latitude,
      longitude: _currentPosition.longitude,
      isDefault: widget.initialAddress?.isDefault ?? false,
    );

    print('Saving address: ${address.fullName}, ${address.streetAddress}');
    print('Barangay: ${address.barangay}');
    print('Coordinates: Lat ${address.latitude}, Lng ${address.longitude}');
    Navigator.pop(context, address);
  }
}
