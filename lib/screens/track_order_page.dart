// lib/screens/track_order_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class TrackOrderPage extends StatefulWidget {
  final String orderId;
  final String riderName;
  final String eta;
  final String deliveryAddress;
  final LatLng? riderLocation;
  final LatLng? deliveryLocation;
  final String? riderPhoneNumber;

  const TrackOrderPage({
    super.key,
    required this.orderId,
    required this.riderName,
    required this.eta,
    required this.deliveryAddress,
    this.riderLocation,
    this.deliveryLocation,
    this.riderPhoneNumber,
  });

  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color successGreen = Color(0xFF4CAF50);

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}


class _TrackOrderPageState extends State<TrackOrderPage> {
  late GoogleMapController mapController;
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  late LatLng _riderLocation;
  late LatLng _deliveryLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  double _currentEtaMinutes = 0;


  @override
  void initState() {
    super.initState();
    _initializeLocations();
    _setupLiveRiderSimulation();
  }

  @override
  void dispose() {
    super.dispose();
  }


  void _initializeLocations() {
    // Default locations (Manila, Philippines)
    _riderLocation = widget.riderLocation ?? const LatLng(14.5994, 120.9842);
    _deliveryLocation = widget.deliveryLocation ?? const LatLng(14.6091, 120.9824);
    _addMarkers();
    _updateEta();
  }


  void _addMarkers() {
    _markers.clear();

    // Rider marker
    _markers.add(
      Marker(
        markerId: const MarkerId('rider'),
        position: _riderLocation,
        infoWindow: InfoWindow(
          title: widget.riderName,
          snippet: 'Delivery Rider',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Delivery location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: _deliveryLocation,
        infoWindow: const InfoWindow(
          title: 'Delivery Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  void _addPolyline() {
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        color: TrackOrderPage.primaryOrange,
        width: 5,
        points: [_riderLocation, _deliveryLocation],
      ),
    );
  }


  // Simulate live rider location updates (for demo)
  void _setupLiveRiderSimulation() {
    // Simulate the rider moving toward the delivery location every 2 seconds
    const int steps = 20;
    int currentStep = 0;
    void moveRider() async {
      if (!mounted) return;
      final latStep = (_deliveryLocation.latitude - _riderLocation.latitude) / steps;
      final lngStep = (_deliveryLocation.longitude - _riderLocation.longitude) / steps;
      if (currentStep < steps) {
        _riderLocation = LatLng(
          _riderLocation.latitude + latStep,
          _riderLocation.longitude + lngStep,
        );
        _addMarkers();
        _addPolyline();
        _updateEta();
        if (mounted) setState(() {});
        currentStep++;
        Future.delayed(const Duration(seconds: 2), moveRider);
      } else {
        // Arrived
        _riderLocation = _deliveryLocation;
        _addMarkers();
        _addPolyline();
        _updateEta();
        if (mounted) setState(() {});
        _notificationService.showNotification(
          'Order Arrived',
          'Your order #${widget.orderId} has arrived.',
        );
      }
    }
    moveRider();
  }

  void _updateEta() {
    final distance = _locationService.calculateDistance(_riderLocation, _deliveryLocation); // meters
    // Assume average speed 30km/h (8.33 m/s)
    final etaMinutes = distance / 500.0; // ~30km/h, 500m/min
    _currentEtaMinutes = etaMinutes;
  }

  void _centerMapOnRider() {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _riderLocation,
          zoom: 16,
        ),
      ),
    );
  }

  String _getDistanceInfo() {
    final distance = _locationService.calculateDistance(
      _riderLocation,
      _deliveryLocation,
    );
    final km = (distance / 1000).toStringAsFixed(2);
    return '$km km away';
  }

  String _getEtaInfo() {
    if (_currentEtaMinutes < 1) return 'Arriving now';
    return '${_currentEtaMinutes.ceil()} min${_currentEtaMinutes.ceil() > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order #${widget.orderId}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
              _centerMapOnRider();
            },
            initialCameraPosition: CameraPosition(
              target: _riderLocation,
              zoom: 16,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            zoomControlsEnabled: true,
          ),

          // Draggable Bottom Sheet with Live Order Status and ETA
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.22,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Live Order Location and ETA
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: TrackOrderPage.primaryOrange,
                              ),
                              child: const Icon(Icons.delivery_dining, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.riderName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getDistanceInfo(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: TrackOrderPage.successGreen,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'ETA: ${_getEtaInfo()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildOrderStatusSection(),
                        const SizedBox(height: 30),
                        _buildDeliveryInfoSection(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusSection() {
    final statuses = [
      _OrderStatus(title: 'Order Placed', completed: true),
      _OrderStatus(title: 'Confirmed', completed: true),
      _OrderStatus(title: 'Preparing', completed: true),
      _OrderStatus(title: 'Out for Delivery', completed: true, current: true),
      _OrderStatus(title: 'Delivered'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Status',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 18),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: statuses.length,
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Container(
              width: 2,
              height: 28,
              color: statuses[index].completed
                  ? TrackOrderPage.primaryOrange
                  : Colors.grey.shade300,
            ),
          ),
          itemBuilder: (context, index) {
            final status = statuses[index];
            final isCompleted = status.completed;
            final isCurrent = status.current;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted || isCurrent
                          ? TrackOrderPage.primaryOrange
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    color: isCompleted || isCurrent
                        ? TrackOrderPage.primaryOrange
                        : Colors.white,
                  ),
                  child: Center(
                    child: Icon(
                      isCompleted
                          ? Icons.check
                          : isCurrent
                              ? Icons.radio_button_checked
                              : Icons.circle_outlined,
                      color: isCompleted || isCurrent
                          ? Colors.white
                          : Colors.grey.shade400,
                      size: isCompleted ? 20 : 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    status.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent
                          ? TrackOrderPage.primaryOrange
                          : isCompleted
                              ? Colors.black
                              : Colors.grey.shade600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (isCurrent)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: TrackOrderPage.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'In Progress',
                      style: TextStyle(
                        color: TrackOrderPage.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeliveryInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Info',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.phone, color: TrackOrderPage.primaryOrange, size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rider Contact',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.riderPhoneNumber ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.location_on, color: TrackOrderPage.primaryOrange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Location',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.deliveryAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class _OrderStatus {
  final String title;
  final bool completed;
  final bool current;

  _OrderStatus({required this.title, this.completed = false, this.current = false});
}