import 'package:flutter/material.dart';
import '../models/order.dart';

class OrdersProvider with ChangeNotifier {
  static final OrdersProvider _instance = OrdersProvider._internal();

  factory OrdersProvider() {
    return _instance;
  }

  OrdersProvider._internal();

  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((order) => order.orderId == orderId);
    if (index != -1) {
      final updatedOrder = Order(
        orderId: _orders[index].orderId,
        orderDate: _orders[index].orderDate,
        items: _orders[index].items,
        totalAmount: _orders[index].totalAmount,
        status: status,
        deliveryAddress: _orders[index].deliveryAddress,
        contactNumber: _orders[index].contactNumber,
        paymentMethod: _orders[index].paymentMethod,
        riderName: _orders[index].riderName,
        riderEta: _orders[index].riderEta,
      );
      _orders[index] = updatedOrder;
      notifyListeners();
    }
  }

  void clearAllOrders() {
    _orders.clear();
    notifyListeners();
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.orderId == orderId);
    } catch (e) {
      return null;
    }
  }
}
