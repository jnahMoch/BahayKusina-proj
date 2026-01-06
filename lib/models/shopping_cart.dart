// lib/models/shopping_cart.dart
import 'cart_item.dart';

class ShoppingCart {
  final List<CartItem> _items = [];

  // Get all items
  List<CartItem> get items => List.unmodifiable(_items);

  // Get total items count
  int get itemCount => _items.length;

  // Get total quantity
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  // Get total price
  int get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  // Add item to cart
  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.meal.title == item.meal.title);
    
    if (existingIndex >= 0) {
      // Update quantity if item already exists
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
  }

  // Remove item from cart
  void removeItem(String mealTitle) {
    _items.removeWhere((item) => item.meal.title == mealTitle);
  }

  // Update item quantity
  void updateQuantity(String mealTitle, int quantity) {
    final index = _items.indexWhere((item) => item.meal.title == mealTitle);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
    }
  }

  // Clear all items
  void clear() {
    _items.clear();
  }

  // Check if cart is empty
  bool get isEmpty => _items.isEmpty;

  // Get item by meal title
  CartItem? getItemByMealTitle(String mealTitle) {
    try {
      return _items.firstWhere((item) => item.meal.title == mealTitle);
    } catch (e) {
      return null;
    }
  }
}
