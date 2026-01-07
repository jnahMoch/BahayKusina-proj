// lib/screens/place_order_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/meal_package.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/firestore_service.dart';
import 'order_confirmation_page.dart';

class PlaceOrderModal extends StatefulWidget {
  final CartProvider cartProvider;
  final Function(Map<String, String>) onOrderPlaced;
  final MealPackage? singlePackage; // For single package orders

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
  late TextEditingController _quantityController;

  String _selectedPaymentMethod = 'Cash on Delivery';
  int _quantity = 1;
  final int _maxQuantity = 20;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Juan Dela Cruz');
    _addressController = TextEditingController(text: '123 Sampaguita St., Quezon City');
    _contactController = TextEditingController(text: '0919-345-6789');
    _quantityController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity >= 1 && newQuantity <= _maxQuantity) {
      setState(() {
        _quantity = newQuantity;
        _quantityController.text = newQuantity.toString();
      });
    }
  }

  Future<void> _handlePlaceOrder(BuildContext context, int totalAmount) async {
    // Validate fields
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: primaryOrange),
      ),
    );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.userId ?? 'guest_user';
      
      // Generate order ID
      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      
      // Prepare cart items
      List<CartItem> orderItems = [];
      if (widget.singlePackage != null) {
        orderItems.add(CartItem(
          meal: widget.singlePackage!,
          quantity: _quantity,
        ));
      } else {
        orderItems = widget.cartProvider.items;
      }

      // Convert CartItem to OrderItem
      final items = orderItems.map((item) => OrderItem(
        mealTitle: item.meal.title,
        quantity: item.quantity,
        pricePerUnit: item.meal.price,
      )).toList();

      // Get vendor info from first item
      final vendorName = orderItems.isNotEmpty 
          ? orderItems.first.meal.vendor 
          : 'Unknown Vendor';
      final vendorId = orderItems.isNotEmpty 
          ? orderItems.first.meal.vendorId 
          : 'unknown_vendor';

      // Create order object
      final order = Order(
        orderId: orderId,
        orderDate: DateTime.now(),
        items: items,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        vendorId: vendorId,
        vendorName: vendorName,
        customerName: _nameController.text,
        deliveryAddress: _addressController.text,
        contactNumber: _contactController.text,
        paymentMethod: _selectedPaymentMethod,
      );

      // Save to Firestore
      final firestoreService = FirestoreService();
      await firestoreService.createOrder(userId, order);

      // Clear cart if not single package
      if (widget.singlePackage == null) {
        widget.cartProvider.clearCart();
      }

      // Call the callback
      widget.onOrderPlaced({
        'fullName': _nameController.text,
        'address': _addressController.text,
        'contactNumber': _contactController.text,
        'paymentMethod': _selectedPaymentMethod,
        'totalAmount': totalAmount.toString(),
        'quantity': _quantity.toString(),
        'orderId': orderId,
      });

      // Close loading and modal
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close modal

        // Navigate to confirmation page with receipt
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationPage(
              orderId: orderId,
              totalAmount: totalAmount,
              deliveryAddress: _addressController.text,
              paymentMethod: _selectedPaymentMethod,
              estimatedDelivery: 'Today, ${_getEstimatedTime()}',
              cartItems: orderItems,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    }
  }

  String _getEstimatedTime() {
    final now = DateTime.now();
    final estimated = now.add(const Duration(hours: 1));
    return '${estimated.hour}:${estimated.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final packagePrice = widget.singlePackage?.price ?? 150;
    final totalAmount = packagePrice * _quantity;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
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
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              widget.singlePackage!.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.restaurant),
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.singlePackage!.vendor,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₱${widget.singlePackage!.price}',
                                  style: const TextStyle(
                                    fontSize: 14,
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
                    ],

                    // Quantity Section
                    const Text(
                      'Quantity',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _QuantityButton(
                          icon: Icons.remove,
                          onPressed: _quantity > 1
                              ? () => _updateQuantity(_quantity - 1)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 60,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            _quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _QuantityButton(
                          icon: Icons.add,
                          onPressed: _quantity < _maxQuantity
                              ? () => _updateQuantity(_quantity + 1)
                              : null,
                        ),
                        const Spacer(),
                        Text(
                          'Max: $_maxQuantity',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Delivery Details Section
                    const Text(
                      'Delivery Details',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // Full Name
                    const Text(
                      'Full Name',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(_nameController),
                    const SizedBox(height: 12),

                    // Address
                    const Text(
                      'Address',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(_addressController, maxLines: 2),
                    const SizedBox(height: 12),

                    // Contact Number
                    const Text(
                      'Contact Number',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(_contactController),
                    const SizedBox(height: 20),

                    // Payment Method Section
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption('Cash on Delivery'),
                    const SizedBox(height: 8),
                    _buildPaymentOption('GCash'),
                    const SizedBox(height: 20),

                    // Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

  Widget _buildPaymentOption(String method) {
    bool isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryOrange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade100,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onPressed != null ? Colors.black87 : Colors.grey.shade400,
        ),
      ),
    );
  }
}
