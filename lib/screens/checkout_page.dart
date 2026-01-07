import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:google_maps_flutter/google_maps_flutter.dart';
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import '../services/notification_service.dart';
import 'order_confirmation_page.dart';
import '../services/firestore_service.dart';

class CheckoutPage extends StatefulWidget {
<<<<<<< HEAD
  final CartProvider cartProvider;

  const CheckoutPage({super.key, required this.cartProvider});
=======
  const CheckoutPage({super.key});
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802

  static const Color primaryOrange = Color(0xFFFF6B00);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color primaryOrange = Color(0xFFFF6B00);

  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _instructionsController;

  // Map-related state
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  final LocationService _locationService = LocationService();
  final GeocodingService _geocodingService = GeocodingService();
  bool _isLoadingLocation = false;
  bool _isGeocodingAddress = false;
  final Set<Marker> _markers = {};

  String _selectedPaymentMethod = 'Cash on Delivery';
  String _addressLabel = 'Home'; // New field for marking address

  final List<String> _paymentMethods = ['Cash on Delivery', 'GCash', 'PayMaya'];

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: '123 Mabini St., Barangay San Juan, Manila',
    );
    _contactController = TextEditingController(text: '+63 917 123 4567');
    _instructionsController = TextEditingController();
    
    // Initialize location after a short delay to allow map to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geocodeAddress();
    });
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('delivery_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            _reverseGeocode(newPosition);
          },
        ),
      );
    });
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  Future<void> _geocodeAddress() async {
    if (_addressController.text.isEmpty) return;
    
    setState(() => _isGeocodingAddress = true);
    
    final location = await _geocodingService.getCoordinatesFromAddress(_addressController.text);
    
    if (location != null) {
      _updateMarker(location);
    }
    
    setState(() => _isGeocodingAddress = false);
  }

  Future<void> _reverseGeocode(LatLng position) async {
    setState(() => _isGeocodingAddress = true);
    
    final address = await _geocodingService.getAddressFromCoordinates(position);
    
    if (address != null) {
      _addressController.text = address;
    }
    
    _updateMarker(position);
    setState(() => _isGeocodingAddress = false);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    final location = await _locationService.getCurrentLocation();
    
    if (location != null) {
      final address = await _geocodingService.getAddressFromCoordinates(location);
      if (address != null) {
        _addressController.text = address;
      }
      _updateMarker(location);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get current location. Please check permissions.')),
      );
    }
    
    setState(() => _isLoadingLocation = false);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _contactController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    final cartProvider = context.read<CartProvider>();
    if (_addressController.text.isEmpty || _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in delivery details')),
      );
      return;
    }

    // Generate order ID
    final orderId =
        '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}';

    // Create order items from cart
<<<<<<< HEAD
    final orderItems = widget.cartProvider.items
        .map(
          (cartItem) => OrderItem(
            mealTitle: cartItem.meal.title,
            quantity: cartItem.quantity,
            pricePerUnit: cartItem.meal.price,
          ),
        )
=======
    final orderItems = cartProvider.items
        .map((cartItem) => OrderItem(
              mealTitle: cartItem.meal.title,
              quantity: cartItem.quantity,
              pricePerUnit: cartItem.meal.price,
            ))
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
        .toList();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Get vendor info from the first item in the cart
    final firstItem = widget.cartProvider.items[0].meal;

    // Create order
    final order = Order(
      orderId: orderId,
      orderDate: DateTime.now(),
      items: orderItems,
      totalAmount: cartProvider.totalPrice + 50,
      status: OrderStatus.pending,
      vendorId: firstItem.vendorId,
      vendorName: firstItem.vendor,
      customerName: user?.fullName ?? 'Guest Customer',
      deliveryAddress: _addressController.text,
      contactNumber: _contactController.text,
      paymentMethod: _selectedPaymentMethod,
      riderName: null,
      riderEta: null,
      deliveryCoordinates: _selectedLocation,
    );

    // Save to Firestore
    if (user != null) {
      FirestoreService().createOrder(user.userId, order);
    }

    // Add order to OrdersProvider
    OrdersProvider().addOrder(order);

    // Trigger Notification
    NotificationService().addNotification(NotificationModel(
      title: 'Order Placed!',
      message: 'Your order $orderId has been successfully placed and is being processed.',
      time: 'Just now',
      icon: Icons.shopping_bag_rounded,
      iconColor: primaryOrange,
    ));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(
          orderId: orderId,
          totalAmount: cartProvider.totalPrice + 50,
          deliveryAddress: _addressController.text,
          paymentMethod: _selectedPaymentMethod,
          estimatedDelivery: '30-45 minutes',
          cartItems: cartProvider.items,
          deliveryCoordinates: _selectedLocation,
        ),
      ),
    );

    cartProvider.clearCart();
    cartProvider.clearCart(); // Clear from local too (redundant but safe)
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final subtotal = cartProvider.totalPrice;
    final deliveryFee = 50;
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Section
              _buildSectionTitle('Payment Method'),
              const SizedBox(height: 12),
              _buildPaymentMethods(),
              const SizedBox(height: 30),

              // Delivery Address Section
              _buildSectionTitle('Delivery Address'),
              const SizedBox(height: 12),
              _buildAddressField(),
              const SizedBox(height: 15),

              // Contact Number
              _buildSectionTitle('Contact Number'),
              const SizedBox(height: 12),
              _buildContactField(),
              const SizedBox(height: 15),

              // Special Instructions
              _buildSectionTitle('Special Instructions (Optional)'),
              const SizedBox(height: 12),
              _buildInstructionsField(),
              const SizedBox(height: 30),

              // Order Summary
              _buildSectionTitle('Order Summary'),
              const SizedBox(height: 12),
              _buildOrderSummary(),
              const SizedBox(height: 30),

              // Subtotal, Delivery Fee, Total
              _buildPricingBreakdown(subtotal, deliveryFee, total),
              const SizedBox(height: 30),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Place Order - ₱$total',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Icon(
          title == 'Delivery Address'
              ? Icons.location_on
              : title == 'Payment Method'
              ? Icons.payment
              : title == 'Contact Number'
              ? Icons.phone
              : title == 'Order Summary'
              ? Icons.receipt
              : Icons.edit,
          color: primaryOrange,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: _paymentMethods.map((method) {
        final isSelected = _selectedPaymentMethod == method;
        IconData icon;
        String desc;

        if (method == 'Cash on Delivery') {
          icon = Icons.money;
          desc = 'Pay when you receive';
        } else if (method == 'GCash') {
          icon = Icons.account_balance_wallet;
          desc = 'Pay via GCash';
        } else {
          icon = Icons.payment;
          desc = 'Pay via PayMaya';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = method),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? primaryOrange : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? primaryOrange.withOpacity(0.05)
                    : Colors.white,
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: method,
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPaymentMethod = value);
                      }
                    },
                    activeColor: primaryOrange,
                  ),
                  Icon(icon, color: primaryOrange, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddressField() {
    return Column(
      children: [
        TextField(
          controller: _addressController,
          maxLines: 2,
          onSubmitted: (_) => _geocodeAddress(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            hintText: 'Enter your delivery address',
            suffixIcon: IconButton(
              icon: _isLoadingLocation 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location, color: primaryOrange),
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              tooltip: 'Use current location',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
<<<<<<< HEAD
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
=======
        const SizedBox(height: 12),
        _buildAddressLabels(),
        const SizedBox(height: 12),
        Container(
          height: 220,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation ?? const LatLng(14.5995, 120.9842),
                  zoom: 15,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: _markers,
                onCameraIdle: () async {
                  final latLng = await _mapController?.getVisibleRegion();
                  if (latLng != null) {
                    final center = LatLng(
                      (latLng.northeast.latitude + latLng.southwest.latitude) / 2,
                      (latLng.northeast.longitude + latLng.southwest.longitude) / 2,
                    );
                    _reverseGeocode(center);
                  }
                },
                onTap: (position) => _reverseGeocode(position),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
              // Center Pin Overlay
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 35),
                  child: Icon(
                    Icons.location_on,
                    color: primaryOrange,
                    size: 40,
                  ),
                ),
              ),
              if (_isGeocodingAddress)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(color: primaryOrange),
                  ),
                ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'center_map',
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.center_focus_strong, color: primaryOrange),
                      onPressed: () {
                        if (_selectedLocation != null) {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLng(_selectedLocation!),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'confirm_pin',
                      backgroundColor: primaryOrange,
                      child: const Icon(Icons.check, color: Colors.white),
                      onPressed: () async {
                        final latLng = await _mapController?.getVisibleRegion();
                        if (latLng != null) {
                          final center = LatLng(
                            (latLng.northeast.latitude + latLng.southwest.latitude) / 2,
                            (latLng.northeast.longitude + latLng.southwest.longitude) / 2,
                          );
                          _reverseGeocode(center);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Move map and tap checkmark to mark exact location',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressLabels() {
    final labels = ['Home', 'Office', 'Other'];
    return Row(
      children: labels.map((label) {
        final isSelected = _addressLabel == label;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _addressLabel = label);
              }
            },
            selectedColor: primaryOrange.withOpacity(0.2),
            labelStyle: TextStyle(
              color: isSelected ? primaryOrange : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? primaryOrange : Colors.transparent,
              ),
            ),
          ),
        );
      }).toList(),
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
    );
  }

  Widget _buildContactField() {
    return TextField(
      controller: _contactController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildInstructionsField() {
    return TextField(
      controller: _instructionsController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'e.g., Ring doorbell, leave at gate',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final cartProvider = context.read<CartProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cartProvider.items.map((cartItem) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.meal.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${cartItem.quantity}x @ ₱${cartItem.meal.price}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₱${cartItem.totalPrice}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryOrange,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPricingBreakdown(int subtotal, int deliveryFee, int total) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text('₱$subtotal', style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Fee',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text('₱$deliveryFee', style: const TextStyle(fontSize: 14)),
            ],
          ),
          Divider(height: 20, color: Colors.grey.shade300),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '₱$total',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
