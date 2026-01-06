// lib/screens/cart_page.dart
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  final CartProvider cartProvider;
  final Function() onCheckout;

  const CartPage({
    super.key,
    required this.cartProvider,
    required this.onCheckout,
  });

  static const Color primaryOrange = Color(0xFFFF6B00);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.cartProvider.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: CartPage.primaryOrange,
          elevation: 0,
          title: const Text('Shopping Cart'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 20),
              const Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Add some delicious meals to get started',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CartPage.primaryOrange,
        elevation: 0,
        title: const Text('Shopping Cart'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Cart Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: widget.cartProvider.items.length,
              itemBuilder: (context, index) {
                final cartItem = widget.cartProvider.items[index];
                return _CartItemWidget(
                  cartItem: cartItem,
                  onQuantityChanged: (newQuantity) {
                    widget.cartProvider.updateQuantity(
                      cartItem.meal.title,
                      newQuantity,
                    );
                    setState(() {});
                  },
                  onRemove: () {
                    widget.cartProvider.removeFromCart(cartItem.meal.title);
                    setState(() {});
                  },
                );
              },
            ),
          ),

          // Summary and Checkout
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '₱${widget.cartProvider.totalPrice}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Delivery Fee',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '₱50',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₱${widget.cartProvider.totalPrice + 50}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CartPage.primaryOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(cartProvider: widget.cartProvider),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CartPage.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Checkout',
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
        ],
      ),
    );
  }
}

class _CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemWidget({
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final meal = cartItem.meal;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                meal.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported),
                    ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${meal.price} each',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF6B00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity and Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₱${cartItem.totalPrice}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFFF6B00),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: Row(
                    children: [
                      _SmallButton(
                        icon: Icons.remove,
                        onPressed: cartItem.quantity > 1
                            ? () => onQuantityChanged(cartItem.quantity - 1)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          cartItem.quantity.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _SmallButton(
                        icon: Icons.add,
                        onPressed: () => onQuantityChanged(cartItem.quantity + 1),
                      ),
                      const SizedBox(width: 4),
                      _SmallButton(
                        icon: Icons.close,
                        onPressed: onRemove,
                        isDelete: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDelete;

  const _SmallButton({
    required this.icon,
    this.onPressed,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDelete ? Colors.red.shade100 : Colors.grey.shade200,
          foregroundColor: isDelete ? Colors.red : Colors.black,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
