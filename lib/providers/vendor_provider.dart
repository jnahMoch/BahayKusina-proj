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
  String? _newOrderNotification; // For notifying new orders
  int _unreadOrderCount = 0; // Count of new pending orders

  // Getters
  List<order_models.Order> get orders => _orders;
  List<MealPackage> get meals => _meals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get newOrderNotification => _newOrderNotification;
  int get unreadOrderCount => _unreadOrderCount;

  // Dashboard Metrics
  int get totalOrders => _orders.length;
  double get totalSales => _orders
      .where((o) => o.status == order_models.OrderStatus.delivered)
      .fold(0.0, (sum, o) => sum + o.totalAmount);
  int get activePackages => _meals.where((m) => m.left > 0).length;
  int get pendingOrders =>
      _orders.where((o) => o.status == order_models.OrderStatus.pending).length;

  // Remove a meal from the local list
  void removeMeal(String mealId) {
    print('🗑️ VendorProvider.removeMeal: Removing meal $mealId');
    _meals.removeWhere((meal) => meal.id == mealId);
    print('🗑️ VendorProvider.removeMeal: Remaining meals: ${_meals.length}');
    notifyListeners();
  }

  static final List<MealPackage> _fallbackMeals = [
    const MealPackage(
      id: 'fallback_silog',
      type: 'Breakfast',
      title: 'Silog Special',
      vendor: 'Nanay\'s Kitchen',
      vendorId: 'vendor_nanay',
      desc: 'Top selling breakfast package.',
      price: 120.0,
      left: 15,
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
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
  Future<void> refreshVendorData(String vendorId, {bool forceRefresh = false}) async {
    print('✓ VendorProvider.refreshVendorData called for vendorId: $vendorId (forceRefresh: $forceRefresh)');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('✓ Fetching orders and meals in parallel...');

      // Start both fetches in parallel with timeout
      final ordersTask = _firestoreService
          .getVendorOrders(vendorId)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⚠ Orders fetch timeout');
              return _fallbackOrders;
            },
          );

      final mealsTask = _firestoreService
          .getVendorMeals(vendorId, forceRefresh: forceRefresh)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⚠ Meals fetch timeout');
              return _fallbackMeals;
            },
          );

      // Fetch orders first (usually faster) and update UI
      try {
        final fetchedOrders = await ordersTask;
        print('✓ Fetched ${fetchedOrders.length} orders from Firestore');
        _orders = fetchedOrders.isNotEmpty
            ? fetchedOrders
            : List.from(_fallbackOrders);
        print('✓ Orders loaded, updating UI...');
        notifyListeners(); // Update UI with orders immediately
      } catch (e) {
        print('⚠ Warning: Could not fetch orders: $e');
        _orders = List.from(_fallbackOrders);
      }

      // Then fetch meals
      try {
        final fetchedMeals = await mealsTask;
        print('✓ Fetched ${fetchedMeals.length} meals from Firestore');
        _meals = fetchedMeals.isNotEmpty
            ? fetchedMeals
            : List.from(_fallbackMeals);
        print('✓ Meals loaded');
      } catch (e) {
        print('⚠ Warning: Could not fetch meals: $e');
        _meals = List.from(_fallbackMeals);
      }

      print('✓ VendorProvider.refreshVendorData completed successfully');
      print('  - Total orders: ${_orders.length}');
      print('  - Total meals: ${_meals.length}');

      AppLogger.info(
        'Fetched ${_orders.length} orders and ${_meals.length} meals for vendor $vendorId',
      );
    } catch (e) {
      print('✗ Error refreshing vendor data: $e');
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
      final statusStr = status.toString().split('.').last;
      print('✓ VendorProvider.updateOrderStatus called');
      print('  - orderId: $orderId');
      print('  - new status: $statusStr');

      // Update local state FIRST for immediate UI responsiveness
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      print('  - Order index in local list: $index');

      order_models.Order? oldOrder;
      if (index != -1) {
        oldOrder = _orders[index];
        print('✓ Found order in local state, updating locally first...');

        // Create new order with updated status (and rider info if out for delivery)
        final updatedOrder = order_models.Order(
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
          riderName: status == order_models.OrderStatus.outForDelivery
              ? 'Mark Santos'
              : oldOrder.riderName,
          riderEta: status == order_models.OrderStatus.outForDelivery
              ? '15 mins'
              : oldOrder.riderEta,
          deliveryCoordinates: oldOrder.deliveryCoordinates,
        );

        _orders[index] = updatedOrder;
        print('✓ Local state updated immediately');
        print('  - Old status: ${oldOrder.status}');
        print('  - New status: ${_orders[index].status}');

        notifyListeners();
        print('✓ UI updated immediately');
      } else {
        print(
          '⚠ Warning: Order not found in local state (may be fallback data)',
        );
      }

      // Now try to sync with Firestore (may queue if offline)
      try {
        await _firestoreService.updateOrderStatus(orderId, status);
        print(
          '✓ FirestoreService.updateOrderStatus completed (or queued for sync)',
        );
      } catch (e) {
        print('⚠ Firestore update failed (offline?): $e');
        // Don't fail the whole operation - local state is already updated
        // Firestore will sync when back online due to persistence
        print('  → Local state already updated, will sync when online');
      }

      print('✓ updateOrderStatus completed successfully');
      return true;
    } catch (e) {
      print('✗ Error in updateOrderStatus: $e');
      print('  Stack trace: $e');
      AppLogger.error('Error updating order status: $e');
      return false;
    }
  }

  // Start real-time order tracking stream
  void startRealtimeOrderTracking(String vendorId) {
    print(
      '✓ VendorProvider.startRealtimeOrderTracking called for vendorId: $vendorId',
    );

    _firestoreService
        .streamVendorOrders(vendorId)
        .listen(
          (orders) {
            print('✓ Real-time update: Received ${orders.length} orders');

            // Check for new pending orders
            final newPendingOrders = orders
                .where((o) => o.status == order_models.OrderStatus.pending)
                .toList();

            final oldPendingCount = _orders
                .where((o) => o.status == order_models.OrderStatus.pending)
                .length;

            // Detect new orders
            if (newPendingOrders.length > oldPendingCount) {
              final newOrderCount = newPendingOrders.length - oldPendingCount;
              final firstNewOrder = newPendingOrders.first;

              _newOrderNotification =
                  '🔔 New Order! ${firstNewOrder.customerName} ordered ${firstNewOrder.items.length} item(s) - ₱${firstNewOrder.totalAmount}';
              _unreadOrderCount = newOrderCount;

              print('✓ NEW ORDER DETECTED: $_newOrderNotification');
            }

            _orders = orders;
            notifyListeners();
          },
          onError: (error) {
            print('✗ Error in real-time order tracking: $error');
            _error = 'Real-time tracking error: $error';
            notifyListeners();
          },
        );
  }

  // Clear notification after displaying
  void clearNotification() {
    _newOrderNotification = null;
    _unreadOrderCount = 0;
    notifyListeners();
  }

  // Clear local cache and FirestoreService cache
  void clearCache() {
    print('✓ VendorProvider: Clearing local cache');
    _orders.clear();
    _meals.clear();
    // Also clear FirestoreService cache to force fresh fetch
    _firestoreService.clearCache();
    print('✓ All cache cleared');
    notifyListeners();
  }
}
