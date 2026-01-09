import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart';
import '../services/notification_service.dart';
import 'order_confirmation_page.dart';
import 'address_selection_page.dart';
import '../services/firestore_service.dart';
import '../models/address_model.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  static const Color primaryOrange = Color(0xFFFF6B00);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color primaryOrange = Color(0xFFFF6B00);

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _instructionsController;

  String _selectedPaymentMethod = 'Cash on Delivery';
  AddressModel? _selectedAddress;

  final List<String> _paymentMethods = ['Cash on Delivery', 'GCash', 'PayMaya'];

  @override
  void initState() {
    super.initState();

    // Load user data from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    _nameController = TextEditingController(
      text: user?.fullName ?? 'Juan Dela Cruz',
    );
    _addressController = TextEditingController(
      text: user?.primaryAddress ?? '123 Mabini St., Barangay San Juan, Manila',
    );
    _contactController = TextEditingController(
      text: user?.phone ?? '+63 917 123 4567',
    );
    _instructionsController = TextEditingController();

    if (user != null && user.addresses.isNotEmpty) {
      _selectedAddress = user.addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => user.addresses.first,
      );
      _addressController.text = _selectedAddress?.fullAddress ?? '';
    }
  }

  Future<void> _pickNewAddress() async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(builder: (context) => const AddressSelectionPage()),
    );

    if (result != null) {
      setState(() {
        _selectedAddress = result;
        _addressController.text = result.fullAddress;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    final cartProvider = context.read<CartProvider>();

    // Check if cart is empty
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all delivery details')),
      );
      return;
    }

    // Generate order ID
    final orderId =
        '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}';

    // Create order items from cart
    final orderItems = cartProvider.items
        .map(
          (cartItem) => OrderItem(
            mealTitle: cartItem.meal.title,
            quantity: cartItem.quantity,
            pricePerUnit: cartItem.meal.price,
          ),
        )
        .toList();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Get vendor info from the first item in the cart
    final firstItem = cartProvider.items[0].meal;
    
    print('📦 Creating order:');
    print('   - Order ID: $orderId');
    print('   - Vendor ID: ${firstItem.vendorId}');
    print('   - Vendor Name: ${firstItem.vendor}');
    print('   - Customer: ${_nameController.text}');

    // Create order
    final order = Order(
      orderId: orderId,
      orderDate: DateTime.now(),
      items: orderItems,
      totalAmount: cartProvider.totalPrice + 50,
      status: OrderStatus.pending,
      vendorId: firstItem.vendorId,
      vendorName: firstItem.vendor,
      customerName: _nameController.text,
      deliveryAddress: _addressController.text,
      contactNumber: _contactController.text,
      paymentMethod: _selectedPaymentMethod,
      riderName: null,
      riderEta: null,
      deliveryCoordinates: _selectedAddress?.latitude != null
          ? LatLng(_selectedAddress!.latitude, _selectedAddress!.longitude)
          : null,
    );

    // Save to Firestore
    if (user != null) {
      print('📦 Saving order to Firestore for user: ${user.userId}');
      FirestoreService()
          .createOrder(user.userId, order)
          .then((_) {
            print('✅ Order saved to Firestore successfully');
            debugPrint('Order saved to Firestore successfully');
          })
          .catchError((e) {
            print('❌ Error saving order to Firestore: $e');
            debugPrint('Error saving order to Firestore: $e');
          });
    } else {
      print('⚠️ No user logged in, order not saved to Firestore');
      debugPrint('Warning: No user logged in, order not saved to Firestore');
    }

    // Add order to OrdersProvider
    OrdersProvider().addOrder(order);

    // Trigger Notification
    NotificationService().addNotification(
      NotificationModel(
        title: 'Order Placed!',
        message:
            'Your order $orderId has been successfully placed and is being processed.',
        time: 'Just now',
        icon: Icons.shopping_bag_rounded,
        iconColor: primaryOrange,
      ),
    );

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
          deliveryCoordinates: _selectedAddress?.latitude != null
              ? LatLng(_selectedAddress!.latitude, _selectedAddress!.longitude)
              : null,
        ),
      ),
    );

    cartProvider.clearCart();
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

              // Full Name
              _buildSectionTitle('Full Name'),
              const SizedBox(height: 12),
              _buildNameField(),
              const SizedBox(height: 15),

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
    final user = context.watch<AuthProvider>().currentUser;
    final addresses = user?.addresses ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (addresses.isNotEmpty) ...[
          const Text(
            'Choose from saved addresses:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
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
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the field to pick a precise location on the map',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        hintText: 'Enter your full name',
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

  Widget _buildContactField() {
    return TextField(
      controller: _contactController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: 'Enter your contact number',
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

  Widget _buildPricingBreakdown(
    double subtotal,
    int deliveryFee,
    double total,
  ) {
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
              Text(
                _selectedAddress?.conciseAddress ?? 'Select delivery address',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
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
