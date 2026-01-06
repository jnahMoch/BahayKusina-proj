// lib/screens/place_order_modal.dart
import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';

class PlaceOrderModal extends StatefulWidget {
  final CartProvider cartProvider;
  final Function(Map<String, String>) onOrderPlaced;

  const PlaceOrderModal({
    super.key,
    required this.cartProvider,
    required this.onOrderPlaced,
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

  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'GCash',
    'PayMaya',
  ];

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

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.cartProvider.totalPrice;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quantity Section
              const Text(
                'Quantity',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onPressed: _quantity > 1
                        ? () => _updateQuantity(_quantity - 1)
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _quantity.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add,
                    onPressed: _quantity < _maxQuantity
                        ? () => _updateQuantity(_quantity + 1)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Max: $_maxQuantity',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Delivery Details Section
              const Text(
                'Delivery Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Full Name
              const Text(
                'Full Name',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              _buildTextField(_nameController),
              const SizedBox(height: 15),

              // Address
              const Text(
                'Address',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              _buildTextField(_addressController, maxLines: 2),
              const SizedBox(height: 15),

              // Contact Number
              const Text(
                'Contact Number',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              _buildTextField(_contactController),
              const SizedBox(height: 25),

              // Payment Method Section
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Column(
                children: _paymentMethods.map((method) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedPaymentMethod == method
                              ? primaryOrange
                              : Colors.grey.shade300,
                          width: _selectedPaymentMethod == method ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: RadioListTile<String>(
                        value: method,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedPaymentMethod = value);
                          }
                        },
                        title: Text(
                          method,
                          style: const TextStyle(fontSize: 14),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        activeColor: primaryOrange,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),

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
              const SizedBox(height: 20),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onOrderPlaced({
                      'fullName': _nameController.text,
                      'address': _addressController.text,
                      'contactNumber': _contactController.text,
                      'paymentMethod': _selectedPaymentMethod,
                      'totalAmount': totalAmount.toString(),
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
            ],
          ),
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
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey.shade100,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
