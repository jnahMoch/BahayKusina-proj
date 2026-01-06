// lib/models/cart_item.dart
import 'meal_package.dart';

class CartItem {
  final MealPackage meal;
  int quantity;

  CartItem({
    required this.meal,
    this.quantity = 1,
  });

  // Calculate total price for this cart item
  int get totalPrice => meal.price * quantity;

  // Copy with method for immutability
  CartItem copyWith({int? quantity}) {
    return CartItem(
      meal: meal,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.meal == meal;
  }

  @override
  int get hashCode => meal.hashCode;
}
