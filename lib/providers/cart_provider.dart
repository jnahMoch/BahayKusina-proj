// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/shopping_cart.dart';
import '../models/meal_package.dart';

class CartProvider extends ChangeNotifier {
  final ShoppingCart _cart = ShoppingCart();

  // Getters
  List<CartItem> get items => _cart.items;
  int get itemCount => _cart.itemCount;
  int get totalQuantity => _cart.totalQuantity;
  int get totalPrice => _cart.totalPrice;
  bool get isEmpty => _cart.isEmpty;

  // Add item to cart
  void addToCart(MealPackage meal, int quantity) {
    if (quantity <= 0) return;
    
    final cartItem = CartItem(meal: meal, quantity: quantity);
    _cart.addItem(cartItem);
    notifyListeners();
  }

  // Remove item from cart
  void removeFromCart(String mealTitle) {
    _cart.removeItem(mealTitle);
    notifyListeners();
  }

  // Update quantity
  void updateQuantity(String mealTitle, int quantity) {
    _cart.updateQuantity(mealTitle, quantity);
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // Check if item is in cart
  CartItem? getCartItem(String mealTitle) {
    return _cart.getItemByMealTitle(mealTitle);
  }

  // Increment quantity
  void incrementQuantity(String mealTitle) {
    final item = _cart.getItemByMealTitle(mealTitle);
    if (item != null) {
      updateQuantity(mealTitle, item.quantity + 1);
    }
  }

  // Decrement quantity
  void decrementQuantity(String mealTitle) {
    final item = _cart.getItemByMealTitle(mealTitle);
    if (item != null && item.quantity > 1) {
      updateQuantity(mealTitle, item.quantity - 1);
    }
  }
}
