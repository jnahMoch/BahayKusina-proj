// lib/models/order.dart
import 'package:flutter/material.dart';

enum OrderStatus {
  outForDelivery,
  delivered,
  pending,
  cancelled
}

class OrderItem {
  final String mealTitle;
  final int quantity;
  final int pricePerUnit;

  const OrderItem({
    required this.mealTitle,
    required this.quantity,
    required this.pricePerUnit,
  });

  int get totalPrice => pricePerUnit * quantity;
}

class Order {
  final String orderId;
  final DateTime orderDate;
  final List<OrderItem> items;
  final int totalAmount;
  final OrderStatus status;
  final String? riderName;
  final String? riderEta;
  final String deliveryAddress;
  final String contactNumber;
  final String paymentMethod;

  const Order({
    required this.orderId,
    required this.orderDate,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.contactNumber,
    required this.paymentMethod,
    this.riderName,
    this.riderEta,
  });

  Color get statusColor {
    switch (status) {
      case OrderStatus.delivered:
        return const Color(0xFF4CAF50);
      case OrderStatus.outForDelivery:
        return const Color(0xFFFF6B00);
      case OrderStatus.pending:
        return Colors.blue;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String get statusText {
    switch (status) {
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
