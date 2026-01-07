import 'package:flutter/material.dart';
import 'home_page.dart'; // Import HomePage to access static color constants
import '../models/meal_package.dart';
import '../providers/cart_provider.dart';

class MealCard extends StatelessWidget {
  final MealPackage meal;
  final CartProvider? cartProvider;
  final VoidCallback? onOrderAdded;

  const MealCard({
    super.key,
    required this.meal,
    this.cartProvider,
    this.onOrderAdded,
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: _buildImage(meal.imageUrl),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(meal.type),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      meal.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
=======
    // Access CartProvider from context if not provided
    final effectiveCartProvider = cartProvider ?? context.watch<CartProvider>();
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  meal.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: const BoxDecoration(
                    color: HomePage.primaryOrange,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
                    ),
                  ),
                  child: Text(
                    meal.type,
                    style: const TextStyle(
<<<<<<< HEAD
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      Text(
                        meal.vendor,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal.desc,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
=======
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          
          // Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
              children: [
                Text(
                  meal.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
<<<<<<< HEAD

                const SizedBox(height: 12),

                // 2. Enhanced Order Button
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: meal.isOutOfStock
                        ? null
                        : () {
                            // Navigate to order details page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailsPage(
                                  meal: meal,
                                  onOrderConfirmed: (quantity) {
                                    if (cartProvider != null) {
                                      cartProvider!.addToCart(meal, quantity);
                                      onOrderAdded?.call();
                                      // Show snackbar confirmation
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '$quantity x ${meal.title} added to cart',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: const Color(
                                            0xFFFF6B00,
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // More modern pill shape
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      meal.isOutOfStock ? "Sold Out" : "Order",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 3. Dynamic Stock Indicator
=======
                const SizedBox(height: 6),
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
                Row(
                  children: [
<<<<<<< HEAD
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 10,
                      color: meal.stockColor,
                    ),
=======
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
                    const SizedBox(width: 4),
                    Text(
                      meal.vendor,
                      style: TextStyle(
<<<<<<< HEAD
                        fontSize: 11,
                        color: meal.stockColor,
                        fontWeight: meal.isLowStock
                            ? FontWeight.bold
                            : FontWeight.normal,
=======
                        fontSize: 12, 
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  meal.desc,
                  style: TextStyle(
                    fontSize: 13, 
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Price, Stock and Button Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₱${meal.price}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: HomePage.primaryOrange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined, 
                                size: 12, 
                                color: meal.stockColor
                              ),
                              const SizedBox(width: 4),
                              Text(
                                meal.isOutOfStock ? 'No stock' : '${meal.left} left',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: meal.stockColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Order Button
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: meal.isOutOfStock ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(
                                meal: meal,
                                onOrderConfirmed: (quantity) {
                                  effectiveCartProvider.addToCart(meal, quantity);
                                  onOrderAdded?.call();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$quantity x ${meal.title} added to cart',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: HomePage.primaryOrange,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomePage.primaryOrange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          meal.isOutOfStock ? "Sold Out" : "Order",
                          style: const TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
>>>>>>> 8af53264263845ddf2425b7142ad594cf2f29802
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) return _buildPlaceholder();

    bool isNetwork = url.startsWith('http') || url.startsWith('https');

    if (isNetwork) {
      return Image.network(
        url,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      return Image.asset(
        url,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey.shade200,
      child: const Icon(Icons.restaurant, color: Colors.grey, size: 40),
    );
  }
}
