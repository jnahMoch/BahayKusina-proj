// lib/screens/track_order_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import '../models/order.dart' as order_models;
import 'dart:async';

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
  final FirestoreService _firestoreService = FirestoreService();
  late LatLng _riderLocation;
  late LatLng _deliveryLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  double _currentEtaMinutes = 0;
  order_models.Order? _currentOrder;
  StreamSubscription? _orderSubscription;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _initializeLocations();
    _setupLiveRiderSimulation();
    _listenToOrderUpdates();
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  void _listenToOrderUpdates() async {
    // Ensure proper orderId format
    String cleanOrderId = widget.orderId;
    
    // Remove any '#' symbols
    cleanOrderId = cleanOrderId.replaceAll('#', '').trim();
    
    // Ensure it starts with ORD- prefix
    if (!cleanOrderId.startsWith('ORD-')) {
      cleanOrderId = 'ORD-$cleanOrderId';
    }
    
    print('✓ Track Order - Listening to order: "$cleanOrderId"');
    print('✓ Track Order - Widget orderId was: "${widget.orderId}"');
    
    // Listen to real-time order updates from Firestore
    _orderSubscription = _firestoreService.streamOrder(cleanOrderId).listen(
      (order) {
        print('✓ Track Order - Stream received order: ${order?.orderId}');
        print('✓ Track Order - Order status: ${order?.status}');
        print('✓ Track Order - Rider name: ${order?.riderName}');
        
        if (mounted) {
          setState(() {
            _currentOrder = order;
            _isLoading = false;
            print('✓ Track Order - setState called with new order');
          });
        }
      },
      onError: (error, stackTrace) {
        print('✗ Track Order - Error streaming order: $error');
        print('✗ Stack trace: $stackTrace');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }


  void _initializeLocations() {
    // Default locations (Manila, Philippines)
    _riderLocation = widget.riderLocation ?? const LatLng(14.5994, 120.9842);
    _deliveryLocation = widget.deliveryLocation ?? const LatLng(14.6091, 120.9824);
    _addMarkers();
    _addPolyline();
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

  String _getEtaInfo() {
    if (_currentEtaMinutes < 1) return 'Arriving now';
    return '${_currentEtaMinutes.ceil()} min${_currentEtaMinutes.ceil() > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track Order',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Order #${widget.orderId}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Placeholder Card
            _buildMapPlaceholderCard(),
            const SizedBox(height: 24),
            // Order Status Section
            _buildOrderStatusSection(),
            const SizedBox(height: 24),
            // Delivery Info Section
            _buildDeliveryInfoSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholderCard() {
    // Get rider name and ETA from order data if available
    String riderName = _currentOrder?.riderName ?? widget.riderName;
    if (riderName.isEmpty || riderName == 'Pending Assignment') {
      riderName = 'Rider Assigned Soon';
    }
    
    String etaText = _currentOrder?.riderEta ?? widget.eta;
    if (etaText.isEmpty || etaText == 'Calculating...') {
      etaText = _getEtaInfo();
    }
    
    // Determine order status text
    String statusText = 'Rider Assigned Soon';
    if (_currentOrder != null) {
      final status = _currentOrder!.status;
      if (status == order_models.OrderStatus.confirmed) {
        statusText = 'Order Confirmed';
      } else if (status == order_models.OrderStatus.preparing) {
        statusText = 'Preparing Your Order';
      } else if (status == order_models.OrderStatus.outForDelivery) {
        statusText = 'Rider On The Way';
      } else if (status == order_models.OrderStatus.delivered) {
        statusText = 'Order Delivered';
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // ETA Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 18, color: TrackOrderPage.primaryOrange),
                const SizedBox(width: 8),
                Text(
                  'ETA: $etaText',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Rider Status Text
          Text(
            statusText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Rider Name
          Text(
            riderName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Map Icon Circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: TrackOrderPage.primaryOrange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: TrackOrderPage.primaryOrange.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          // Map Tracking Text
          const Text(
            'Real-time Map Tracking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Google Maps Integration',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusSection() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: TrackOrderPage.primaryOrange),
        ),
      );
    }

    if (_currentOrder == null) {
      // Show default status when order data is not available
      final statuses = [
        _OrderStatus(
          title: 'Order Placed',
          icon: Icons.receipt_long,
          completed: true,
          current: true,
        ),
        _OrderStatus(
          title: 'Confirmed',
          icon: Icons.check_circle,
        ),
        _OrderStatus(
          title: 'Preparing',
          icon: Icons.restaurant,
        ),
        _OrderStatus(
          title: 'Out for Delivery',
          icon: Icons.delivery_dining,
        ),
        _OrderStatus(
          title: 'Delivered',
          icon: Icons.done_all,
        ),
      ];

      return _buildStatusList(statuses);
    }

    final currentStatus = _currentOrder!.status;
    
    final statuses = [
      _OrderStatus(
        title: 'Order Placed',
        icon: Icons.receipt_long,
        completed: true,
      ),
      _OrderStatus(
        title: 'Confirmed',
        icon: Icons.check_circle,
        completed: currentStatus == order_models.OrderStatus.confirmed ||
                  currentStatus == order_models.OrderStatus.preparing ||
                  currentStatus == order_models.OrderStatus.outForDelivery ||
                  currentStatus == order_models.OrderStatus.delivered,
        current: currentStatus == order_models.OrderStatus.confirmed,
      ),
      _OrderStatus(
        title: 'Preparing',
        icon: Icons.restaurant,
        completed: currentStatus == order_models.OrderStatus.preparing ||
                  currentStatus == order_models.OrderStatus.outForDelivery ||
                  currentStatus == order_models.OrderStatus.delivered,
        current: currentStatus == order_models.OrderStatus.preparing,
      ),
      _OrderStatus(
        title: 'Out for Delivery',
        icon: Icons.delivery_dining,
        completed: currentStatus == order_models.OrderStatus.outForDelivery ||
                  currentStatus == order_models.OrderStatus.delivered,
        current: currentStatus == order_models.OrderStatus.outForDelivery,
      ),
      _OrderStatus(
        title: 'Delivered',
        icon: Icons.done_all,
        completed: currentStatus == order_models.OrderStatus.delivered,
        current: currentStatus == order_models.OrderStatus.delivered,
      ),
    ];

    return _buildStatusList(statuses);
  }

  Widget _buildStatusList(List<_OrderStatus> statuses) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: statuses.length,
            separatorBuilder: (context, index) => Container(
              margin: const EdgeInsets.only(left: 22),
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: statuses[index].completed
                    ? TrackOrderPage.primaryOrange
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            itemBuilder: (context, index) {
              final status = statuses[index];
              final isCompleted = status.completed;
              final isCurrent = status.current;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isCurrent
                          ? TrackOrderPage.primaryOrange
                          : Colors.grey.shade300,
                    ),
                    child: Icon(
                      status.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Status Text
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isCompleted || isCurrent
                                  ? Colors.black
                                  : Colors.grey.shade500,
                            ),
                          ),
                          if (isCurrent)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Current status',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Check Mark
                  if (isCompleted && !isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoSection() {
    // Get contact and address from order data if available
    String riderContact = widget.riderPhoneNumber ?? '0920-456-7890';
    String deliveryAddress = _currentOrder?.deliveryAddress ?? widget.deliveryAddress;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Info',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.phone,
                color: Colors.grey.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rider Contact',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    riderContact,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                color: Colors.grey.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deliveryAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderStatus {
  final String title;
  final IconData icon;
  final bool completed;
  final bool current;

  _OrderStatus({
    required this.title,
    required this.icon,
    this.completed = false,
    this.current = false,
  });
}