// lib/providers/vendor_provider.dart
import 'package:flutter/material.dart';
import '../models/order.dart' as order_models;
import '../models/meal_package.dart';
import '../services/firestore_service.dart';
import '../utils/logger.dart';

class VendorProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<order_models.Order> _orders = [];
  List<MealPackage> _meals = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<order_models.Order> get orders => _orders;
  List<MealPackage> get meals => _meals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Dashboard Metrics
  int get totalOrders => _orders.length;
  int get totalSales => _orders
      .where((o) => o.status == order_models.OrderStatus.delivered)
      .fold(0, (sum, o) => sum + o.totalAmount);
  int get activePackages => _meals.where((m) => m.left > 0).length;
  int get pendingOrders =>
      _orders.where((o) => o.status == order_models.OrderStatus.pending).length;

  static final List<MealPackage> _fallbackMeals = [
    const MealPackage(
      id: 'fallback_silog',
      type: 'Breakfast',
      title: 'Silog Special',
      vendor: 'Nanay\'s Kitchen',
      vendorId: 'vendor_nanay',
      desc: 'Top selling breakfast package.',
      price: 120,
      left: 15,
      imageUrl: 'https://images.unsplash.com/photo-1626074353765-517a681e40be',
    ),
  ];

  static final List<order_models.Order> _fallbackOrders = [
    order_models.Order(
      orderId: 'ORD-001',
      orderDate: DateTime.now().subtract(const Duration(hours: 2)),
      items: [
        order_models.OrderItem(
          mealTitle: 'Silog Special',
          quantity: 2,
          pricePerUnit: 120,
        ),
      ],
      totalAmount: 240,
      status: order_models.OrderStatus.pending,
      vendorId: 'vendor_nanay',
      vendorName: 'Nanay\'s Kitchen',
      customerName: 'Juan Dela Cruz',
      deliveryAddress: '123 Sampaguita St, Makati',
      contactNumber: '09171234567',
      paymentMethod: 'GCash',
    ),
  ];

  // Fetch all vendor data
  Future<void> refreshVendorData(String vendorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Run both fetches in parallel
      final results = await Future.wait([
        _firestoreService.getVendorOrders(vendorId),
        _firestoreService.getVendorMeals(vendorId),
      ]);

      final fetchedOrders = results[0] as List<order_models.Order>;
      final fetchedMeals = results[1] as List<MealPackage>;

      // If both are empty, use fallbacks for demo/offline purposes
      if (fetchedOrders.isEmpty && fetchedMeals.isEmpty) {
        _orders = List.from(_fallbackOrders);
        _meals = List.from(_fallbackMeals);
      } else {
        _orders = fetchedOrders;
        _meals = fetchedMeals;
      }

      AppLogger.info(
        'Fetched ${_orders.length} orders and ${_meals.length} meals for vendor $vendorId',
      );
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Error refreshing vendor data: $e');
      // Use fallbacks on error
      _orders = List.from(_fallbackOrders);
      _meals = List.from(_fallbackMeals);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(
    String orderId,
    order_models.OrderStatus status,
  ) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, status);

      // Update local state to avoid full refresh
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        final oldOrder = _orders[index];
        _orders[index] = order_models.Order(
          orderId: oldOrder.orderId,
          orderDate: oldOrder.orderDate,
          items: oldOrder.items,
          totalAmount: oldOrder.totalAmount,
          status: status,
          vendorId: oldOrder.vendorId,
          vendorName: oldOrder.vendorName,
          customerName: oldOrder.customerName,
          deliveryAddress: oldOrder.deliveryAddress,
          contactNumber: oldOrder.contactNumber,
          paymentMethod: oldOrder.paymentMethod,
          riderName: oldOrder.riderName,
          riderEta: oldOrder.riderEta,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      AppLogger.error('Error updating order status: $e');
      return false;
    }
  }
}
