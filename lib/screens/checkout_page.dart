// lib/screens/checkout_page.dart
import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../models/order.dart';
import 'order_confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  final CartProvider cartProvider;

  const CheckoutPage({
    super.key,
    required this.cartProvider,
  });

  static const Color primaryOrange = Color(0xFFFF6B00);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color primaryOrange = Color(0xFFFF6B00);

  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _instructionsController;

  String _selectedPaymentMethod = 'Cash on Delivery';

  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'GCash',
    'PayMaya',
  ];

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: '123 Mabini St., Barangay San Juan, Manila');
    _contactController = TextEditingController(text: '+63 917 123 4567');
    _instructionsController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _contactController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    if (_addressController.text.isEmpty || _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in delivery details')),
      );
      return;
    }

    // Generate order ID
    final orderId = '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}';

    // Create order items from cart
    final orderItems = widget.cartProvider.items
        .map((cartItem) => OrderItem(
              mealTitle: cartItem.meal.title,
              quantity: cartItem.quantity,
              pricePerUnit: cartItem.meal.price,
            ))
        .toList();

    // Create order
    final order = Order(
      orderId: orderId,
      orderDate: DateTime.now(),
      items: orderItems,
      totalAmount: widget.cartProvider.totalPrice + 50,
      status: OrderStatus.pending,
      deliveryAddress: _addressController.text,
      contactNumber: _contactController.text,
      paymentMethod: _selectedPaymentMethod,
      riderName: null,
      riderEta: null,
    );

    // Add order to OrdersProvider
    OrdersProvider().addOrder(order);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(
          orderId: orderId,
          totalAmount: widget.cartProvider.totalPrice + 50,
          deliveryAddress: _addressController.text,
          paymentMethod: _selectedPaymentMethod,
          estimatedDelivery: '30-45 minutes',
          cartItems: widget.cartProvider.items,
        ),
      ),
    );

    widget.cartProvider.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.cartProvider.totalPrice;
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
                color: isSelected ? primaryOrange.withOpacity(0.05) : Colors.white,
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
    return TextField(
      controller: _addressController,
      maxLines: 2,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.cartProvider.items.map((cartItem) {
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
              Text(
                '₱$subtotal',
                style: const TextStyle(fontSize: 14),
              ),
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
              Text(
                '₱$deliveryFee',
                style: const TextStyle(fontSize: 14),
              ),
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
