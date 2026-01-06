// lib/screens/meal_card.dart

import 'package:flutter/material.dart';
import 'home_page.dart'; // Import HomePage to access static color constants
import 'order_details_page.dart';
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Breakfast':
        return Colors.green;
      case 'Lunch':
        return Colors.blue;
      case 'Dinner':
        return Colors.purple;
      case 'Merienda':
        // Access static color from the imported HomePage class
        return HomePage.primaryOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: Image.asset(
                meal.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 15),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    meal.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                      Text(
                        meal.vendor,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
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
              children: [
                // 1. Formatted Price
                Text(
                  '₱${meal.price}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFFF6B00), // Primary Orange
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: 12),

                // 2. Enhanced Order Button
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: meal.isOutOfStock ? null : () {
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$quantity x ${meal.title} added to cart',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: const Color(0xFFFF6B00),
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
                        borderRadius: BorderRadius.circular(20), // More modern pill shape
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      meal.isOutOfStock ? "Sold Out" : "Order",
                      style: const TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 3. Dynamic Stock Indicator
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined, 
                      size: 10, 
                      color: meal.stockColor
                    ),
                    const SizedBox(width: 4),
                    Text(
                      meal.isOutOfStock ? 'No stock' : '${meal.left} left',
                      style: TextStyle(
                        fontSize: 11,
                        color: meal.stockColor,
                        fontWeight: meal.isLowStock ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}