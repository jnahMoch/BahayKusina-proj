// lib/screens/place_order_modal.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/meal_package.dart';
import '../models/order.dart';
import 'order_confirmation_page.dart';
import 'address_selection_page.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../models/address_model.dart';

class PlaceOrderModal extends StatefulWidget {
  final CartProvider cartProvider;
  final Function(Map<String, String>) onOrderPlaced;
  final MealPackage? singlePackage;

  const PlaceOrderModal({
    super.key,
    required this.cartProvider,
    required this.onOrderPlaced,
    this.singlePackage,
  });

  @override
  State<PlaceOrderModal> createState() => _PlaceOrderModalState();
}

class _PlaceOrderModalState extends State<PlaceOrderModal> {
  static const Color primaryOrange = Color(0xFFFF6B00);

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  AddressModel? _selectedAddress;

  String _selectedPaymentMethod = 'Cash on Delivery';
  int _quantity = 1;
  final int _maxQuantity = 20;

  @override
  void initState() {
    super.initState();
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    _nameController = TextEditingController(
      text: user?.fullName ?? 'Juan Dela Cruz',
    );
    _addressController = TextEditingController(
      text: user?.primaryAddress ?? '123 Sampaguita St., Quezon City',
    );
    _contactController = TextEditingController(
      text: user?.phone ?? '0919-345-6789',
    );

    if (user != null && user.addresses.isNotEmpty) {
      _selectedAddress = user.addresses.firstWhere((a) => a.isDefault, orElse: () => user.addresses.first);
      _addressController.text = _selectedAddress?.fullAddress ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity >= 1 && newQuantity <= _maxQuantity) {
      setState(() {
        _quantity = newQuantity;
      });
    }
  }

  Future<void> _pickNewAddress() async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressSelectionPage(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedAddress = result;
        _addressController.text = result.fullAddress;
      });
    }
  }

  Future<void> _handlePlaceOrder(BuildContext context, double totalAmount) async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: primaryOrange),
      ),
    );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final firestoreService = FirestoreService();
      final userId = authProvider.currentUser?.userId ?? 'guest';

      final orderItems = widget.singlePackage != null
          ? [
              OrderItem(
                mealTitle: widget.singlePackage!.title,
                quantity: _quantity,
                pricePerUnit: widget.singlePackage!.price,
              )
            ]
          : widget.cartProvider.items
              .map((item) => OrderItem(
                    mealTitle: item.meal.title,
                    quantity: item.quantity,
                    pricePerUnit: item.meal.price,
                  ))
              .toList();

      final order = Order(
        orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        customerName: _nameController.text,
        vendorId: widget.singlePackage?.vendorId ?? 'vendor_nanay',
        vendorName: widget.singlePackage?.vendor ?? 'Aling Nena\'s Kitchen',
        items: orderItems,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        deliveryAddress: _addressController.text,
        contactNumber: _contactController.text,
        paymentMethod: _selectedPaymentMethod,
        status: OrderStatus.pending,
        deliveryCoordinates: _selectedAddress?.latitude != null ? LatLng(_selectedAddress!.latitude, _selectedAddress!.longitude) : null,
      );

      await firestoreService.createOrder(userId, order);

      // Send notification to vendor
      final notificationService = NotificationService();
      await notificationService.addNotification(NotificationModel(
        title: 'New Order Received',
        message: '${_nameController.text} placed an order for ₱$totalAmount',
        time: 'Just now',
        timestamp: DateTime.now(),
        icon: Icons.shopping_bag,
        iconColor: primaryOrange,
        type: NotificationType.order,
        orderId: order.orderId,
      ));

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close modal
        
        widget.onOrderPlaced({
          'orderId': order.orderId,
          'name': _nameController.text,
          'address': _addressController.text,
          'contact': _contactController.text,
          'payment': _selectedPaymentMethod,
          'quantity': _quantity.toString(),
          'total': totalAmount.toString(),
        });

        final estimated = DateTime.now().add(const Duration(hours: 1));
        final estimatedTime = '${estimated.hour}:${estimated.minute.toString().padLeft(2, '0')}';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationPage(
              orderId: order.orderId,
              totalAmount: totalAmount,
              deliveryAddress: _addressController.text,
              paymentMethod: _selectedPaymentMethod,
              estimatedDelivery: estimatedTime,
              cartItems: widget.cartProvider.items,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final packagePrice = widget.singlePackage?.price ?? 150;
    final totalAmount = packagePrice * _quantity;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 22, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Package Info Card
                    if (widget.singlePackage != null) ...[
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.singlePackage!.imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.restaurant, size: 30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.singlePackage!.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.singlePackage!.vendor,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '₱${widget.singlePackage!.price}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: primaryOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Quantity Selector
                      Row(
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: _quantity > 1 
                                      ? () => _updateQuantity(_quantity - 1)
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: _quantity > 1 
                                          ? Colors.black 
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 50,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    _quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: _quantity < _maxQuantity
                                      ? () => _updateQuantity(_quantity + 1)
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: _quantity < _maxQuantity
                                          ? Colors.black
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Max $_maxQuantity',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Delivery Details Section
                    const Text(
                      'Delivery Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Full Name
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(_nameController),
                    const SizedBox(height: 14),

                    // Address
                    const Text(
                      'Address',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildAddressPicker(),
                    const SizedBox(height: 14),

                    // Contact Number
                    const Text(
                      'Contact Number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(_contactController),
                    const SizedBox(height: 20),

                    // Payment Method Section
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildPaymentOption('Cash on Delivery'),
                    const SizedBox(height: 10),
                    _buildPaymentOption('GCash'),
                    const SizedBox(height: 20),

                    // Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '₱$totalAmount',
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
              ),
            ),

            // Place Order Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _handlePlaceOrder(context, totalAmount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressPicker() {
    final user = context.watch<AuthProvider>().currentUser;
    final addresses = user?.addresses ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (addresses.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: addresses.map((addr) {
                final isSelected = _selectedAddress?.id == addr.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(addr.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedAddress = addr;
                          _addressController.text = addr.fullAddress;
                        });
                      }
                    },
                    selectedColor: primaryOrange.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? primaryOrange : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: _addressController,
          maxLines: 2,
          readOnly: true,
          onTap: _pickNewAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'Select delivery address',
            suffixIcon: const Icon(Icons.map_outlined, color: primaryOrange),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryOrange),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryOrange),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildPaymentOption(String method) {
    bool isSelected = _selectedPaymentMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? primaryOrange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryOrange : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryOrange,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              method,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
