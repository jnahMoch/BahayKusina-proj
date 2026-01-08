// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/meal_package.dart';
import '../models/order.dart' as order_models;
import '../utils/logger.dart';

class FirestoreService {
  // Singleton pattern
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Simple cache for vendor data
  final Map<String, List<order_models.Order>> _ordersCache = {};
  final Map<String, List<MealPackage>> _mealsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Clear all caches - call this after adding/updating packages
  void clearCache([String? vendorId]) {
    if (vendorId != null) {
      _ordersCache.remove(vendorId);
      _mealsCache.remove(vendorId);
      _cacheTimestamps.remove('orders_$vendorId');
      _cacheTimestamps.remove('meals_$vendorId');
      print('✓ FirestoreService: Cleared cache for vendor $vendorId');
    } else {
      _ordersCache.clear();
      _mealsCache.clear();
      _cacheTimestamps.clear();
      print('✓ FirestoreService: Cleared all caches');
    }
  }

  // ===== MEALS COLLECTION =====
  Future<List<MealPackage>> getMealPackages() async {
    try {
      final snapshot = await _db.collection('meals').get();
      return snapshot.docs
          .map(
            (doc) => MealPackage(
              id: doc.id,
              type: doc['type'] ?? 'General',
              title: doc['title'] ?? '',
              vendor: doc['vendor'] ?? '',
              vendorId: doc['vendorId'] ?? 'unknown_vendor',
              desc: doc['desc'] ?? '',
              price: (doc['price'] ?? 0).toDouble(),
              left: (doc['left'] ?? 0).toInt(),
              imageUrl: doc['imageUrl'] ?? '',
            ),
          )
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching meals: $e');
      return [];
    }
  }

  // Real-time stream of all meals (for customers to see new packages instantly)
  Stream<List<MealPackage>> streamAllMeals() {
    print('✓ FirestoreService.streamAllMeals - Starting stream');

    try {
      return _db
          .collection('meals')
          .snapshots()
          .map((snapshot) {
            print(
              '✓ FirestoreService.streamAllMeals - Received ${snapshot.docs.length} meals',
            );

            return snapshot.docs
                .map(
                  (doc) => MealPackage(
                    id: doc.id,
                    type: doc['type'] ?? 'General',
                    title: doc['title'] ?? '',
                    vendor: doc['vendor'] ?? '',
                    vendorId: doc['vendorId'] ?? 'unknown_vendor',
                    desc: doc['desc'] ?? '',
                    price: (doc['price'] ?? 0).toDouble(),
                    left: (doc['left'] ?? 0).toInt(),
                    imageUrl: doc['imageUrl'] ?? '',
                  ),
                )
                .toList();
          })
          .handleError((error) {
            print('✗ FirestoreService.streamAllMeals - Error: $error');
            AppLogger.error('Error streaming meals: $error');
          });
    } catch (e) {
      print('✗ FirestoreService.streamAllMeals - Error: $e');
      AppLogger.error('Error setting up meals stream: $e');
      return Stream.error(e);
    }
  }

  Future<List<MealPackage>> getVendorMeals(String vendorId, {bool forceRefresh = false}) async {
    try {
      // Check cache first (unless force refresh)
      if (!forceRefresh && _mealsCache.containsKey(vendorId)) {
        final cacheTime = _cacheTimestamps['meals_$vendorId'];
        if (cacheTime != null &&
            DateTime.now().difference(cacheTime) < _cacheDuration) {
          print('✓ Returning cached meals for vendorId: $vendorId');
          return _mealsCache[vendorId]!;
        }
      }

      if (forceRefresh) {
        print('✓ Force refreshing meals for vendorId: $vendorId');
        // Clear the cache for this vendor
        _mealsCache.remove(vendorId);
        _cacheTimestamps.remove('meals_$vendorId');
      }

      print('✓ Fetching vendor meals for vendorId: $vendorId (not cached)');

      // Try to get from server first, fall back to cache if offline
      QuerySnapshot snapshot;
      try {
        snapshot = await _db
            .collection('meals')
            .where('vendorId', isEqualTo: vendorId)
            .get(const GetOptions(source: Source.serverAndCache));
      } catch (e) {
        print('⚠ Server fetch failed, trying cache: $e');
        snapshot = await _db
            .collection('meals')
            .where('vendorId', isEqualTo: vendorId)
            .get(const GetOptions(source: Source.cache));
      }

      final meals = snapshot.docs
          .map(
            (doc) => MealPackage(
              id: doc.id,
              type: doc['type'] ?? 'General',
              title: doc['title'] ?? '',
              vendor: doc['vendor'] ?? '',
              vendorId: doc['vendorId'] ?? 'unknown_vendor',
              desc: doc['desc'] ?? '',
              price: (doc['price'] ?? 0).toDouble(),
              left: (doc['left'] ?? 0).toInt(),
              imageUrl: doc['imageUrl'] ?? '',
            ),
          )
          .toList();

      // Cache the results
      _mealsCache[vendorId] = meals;
      _cacheTimestamps['meals_$vendorId'] = DateTime.now();
      print('✓ Cached ${meals.length} meals for future requests');

      return meals;
    } catch (e) {
      AppLogger.error('Error fetching vendor meals: $e');
      return [];
    }
  }

  Future<MealPackage?> getMealById(String mealId) async {
    try {
      final doc = await _db.collection('meals').doc(mealId).get();
      if (doc.exists) {
        return MealPackage(
          id: doc.id,
          type: doc['type'] ?? 'General',
          title: doc['title'] ?? '',
          vendor: doc['vendor'] ?? '',
          vendorId: doc['vendorId'] ?? 'unknown_vendor',
          desc: doc['desc'] ?? '',
          price: (doc['price'] ?? 0).toDouble(),
          left: (doc['left'] ?? 0).toInt(),
          imageUrl: doc['imageUrl'] ?? '',
        );
      }
    } catch (e) {
      AppLogger.error('Error fetching meal: $e');
    }
    return null;
  }

  // ===== ORDERS COLLECTION =====
  Future<void> createOrder(String userId, order_models.Order orderData) async {
    try {
      final orderMap = {
        'orderId': orderData.orderId,
        'orderDate': orderData.orderDate,
        'items': orderData.items
            .map(
              (item) => {
                'mealTitle': item.mealTitle,
                'quantity': item.quantity,
                'pricePerUnit': item.pricePerUnit,
              },
            )
            .toList(),
        'totalAmount': orderData.totalAmount,
        'status': orderData.status.toString().split('.').last,
        'vendorId': orderData.vendorId,
        'vendorName': orderData.vendorName,
        'customerName': orderData.customerName,
        'customerId': userId,
        'deliveryAddress': orderData.deliveryAddress,
        'contactNumber': orderData.contactNumber,
        'paymentMethod': orderData.paymentMethod,
        'riderName': orderData.riderName ?? '',
        'riderEta': orderData.riderEta ?? '',
        'deliveryCoordinates': orderData.deliveryCoordinates != null
            ? {
                'latitude': orderData.deliveryCoordinates!.latitude,
                'longitude': orderData.deliveryCoordinates!.longitude,
              }
            : null,
      };

      // Save to user's orders subcollection
      await _db
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderData.orderId)
          .set(orderMap);

      // Save to top-level orders collection for vendor access
      await _db.collection('orders').doc(orderData.orderId).set(orderMap);
    } catch (e) {
      AppLogger.error('Error creating order: $e');
      rethrow;
    }
  }

  Future<List<order_models.Order>> getUserOrders(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();

      return _snapshotToOrderList(snapshot);
    } catch (e) {
      AppLogger.error('Error fetching user orders: $e');
      return [];
    }
  }

  Stream<order_models.Order?> streamOrder(String orderId) {
    print(
      '✓ FirestoreService.streamOrder - Starting stream for orderId: "$orderId"',
    );

    try {
      return _db.collection('orders').doc(orderId).snapshots().map((snapshot) {
        print(
          '✓ FirestoreService.streamOrder - Snapshot received, exists: ${snapshot.exists}',
        );

        if (!snapshot.exists) {
          print(
            '✗ FirestoreService.streamOrder - Order "$orderId" not found in Firestore',
          );
          return null;
        }

        final data = snapshot.data() as Map<String, dynamic>;
        print(
          '✓ FirestoreService.streamOrder - Order data keys: ${data.keys.toList()}',
        );

        // Parse delivery coordinates if available
        LatLng? deliveryCoordinates;
        if (data['deliveryCoordinates'] != null) {
          final coords = data['deliveryCoordinates'] as Map<String, dynamic>;
          deliveryCoordinates = LatLng(
            coords['latitude'] as double,
            coords['longitude'] as double,
          );
        }

        // Safe date parsing
        DateTime orderDate = DateTime.now();
        if (data['orderDate'] != null) {
          try {
            orderDate = (data['orderDate'] as Timestamp).toDate();
          } catch (e) {
            print(
              '✗ FirestoreService.streamOrder - Could not parse orderDate: $e',
            );
          }
        }

        final order = order_models.Order(
          orderId: data['orderId'] ?? '',
          orderDate: orderDate,
          items:
              (data['items'] as List?)
                  ?.map(
                    (item) => order_models.OrderItem(
                      mealTitle: item['mealTitle'] ?? '',
                      quantity: (item['quantity'] ?? 0).toInt(),
                      pricePerUnit: (item['pricePerUnit'] ?? 0).toInt(),
                    ),
                  )
                  .toList() ??
              [],
          totalAmount: (data['totalAmount'] ?? 0).toInt(),
          status: _parseOrderStatus(data['status'] ?? 'pending'),
          vendorId: data['vendorId'] ?? '',
          vendorName: data['vendorName'] ?? '',
          customerName: data['customerName'] ?? 'Customer',
          deliveryAddress: data['deliveryAddress'] ?? '',
          contactNumber: data['contactNumber'] ?? '',
          paymentMethod: data['paymentMethod'] ?? '',
          riderName: data['riderName']?.toString().isEmpty == true
              ? null
              : data['riderName'],
          riderEta: data['riderEta']?.toString().isEmpty == true
              ? null
              : data['riderEta'],
          deliveryCoordinates: deliveryCoordinates,
        );

        print(
          '✓ FirestoreService.streamOrder - Order parsed successfully: ${order.orderId}, status: ${order.status}',
        );
        return order;
      });
    } catch (e) {
      AppLogger.error('Error streaming order: $e');
      print('✗ FirestoreService.streamOrder - Error: $e');
      return Stream.error(e);
    }
  }

  Future<List<order_models.Order>> getVendorOrders(String vendorId) async {
    try {
      // Check cache first
      if (_ordersCache.containsKey(vendorId)) {
        final cacheTime = _cacheTimestamps['orders_$vendorId'];
        if (cacheTime != null &&
            DateTime.now().difference(cacheTime) < _cacheDuration) {
          print('✓ Returning cached orders for vendorId: $vendorId');
          return _ordersCache[vendorId]!;
        }
      }

      print('✓ Fetching vendor orders for vendorId: $vendorId (not cached)');
      // Query without orderBy to avoid composite index requirement
      final snapshot = await _db
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      print('✓ Fetched ${snapshot.docs.length} orders from Firestore');
      final orders = _snapshotToOrderList(snapshot);

      // Sort by orderDate in memory (descending - newest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      // Cache the results
      _ordersCache[vendorId] = orders;
      _cacheTimestamps['orders_$vendorId'] = DateTime.now();
      print('✓ Cached ${orders.length} orders for future requests');

      print('✓ Parsed and sorted ${orders.length} orders successfully');
      return orders;
    } catch (e) {
      print('✗ Error fetching vendor orders: $e');
      AppLogger.error('Error fetching vendor orders: $e');
      return [];
    }
  }

  List<order_models.Order> _snapshotToOrderList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return order_models.Order(
        orderId: data['orderId'] ?? '',
        orderDate: (data['orderDate'] as Timestamp).toDate(),
        items: (data['items'] as List)
            .map(
              (item) => order_models.OrderItem(
                mealTitle: item['mealTitle'] ?? '',
                quantity: (item['quantity'] ?? 0).toInt(),
                pricePerUnit: (item['pricePerUnit'] ?? 0).toInt(),
              ),
            )
            .toList(),
        totalAmount: (data['totalAmount'] ?? 0).toInt(),
        status: _parseOrderStatus(data['status'] ?? 'pending'),
        vendorId: data['vendorId'] ?? '',
        vendorName: data['vendorName'] ?? '',
        customerName: data['customerName'] ?? 'Customer',
        deliveryAddress: data['deliveryAddress'] ?? '',
        contactNumber: data['contactNumber'] ?? '',
        paymentMethod: data['paymentMethod'] ?? '',
        riderName: data['riderName'],
        riderEta: data['riderEta'],
      );
    }).toList();
  }

  // Real-time stream for vendor orders (for live updates when customer places order)
  Stream<List<order_models.Order>> streamVendorOrders(String vendorId) {
    print(
      '✓ FirestoreService.streamVendorOrders - Starting stream for vendorId: "$vendorId"',
    );

    try {
      return _db
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .orderBy('orderDate', descending: true)
          .snapshots()
          .map((snapshot) {
            print(
              '✓ FirestoreService.streamVendorOrders - Received ${snapshot.docs.length} orders',
            );

            return snapshot.docs.map((doc) {
              final data = doc.data();

              try {
                final orderDateTimestamp = data['orderDate'];
                DateTime parsedOrderDate;

                if (orderDateTimestamp is Timestamp) {
                  parsedOrderDate = orderDateTimestamp.toDate();
                } else if (orderDateTimestamp is String) {
                  parsedOrderDate = DateTime.parse(orderDateTimestamp);
                } else {
                  parsedOrderDate = DateTime.now();
                }

                final statusStr = (data['status'] ?? 'pending')
                    .toString()
                    .toLowerCase();
                order_models.OrderStatus status =
                    order_models.OrderStatus.pending;

                switch (statusStr) {
                  case 'confirmed':
                    status = order_models.OrderStatus.confirmed;
                    break;
                  case 'preparing':
                    status = order_models.OrderStatus.preparing;
                    break;
                  case 'outfordelivery':
                  case 'out_for_delivery':
                    status = order_models.OrderStatus.outForDelivery;
                    break;
                  case 'delivered':
                    status = order_models.OrderStatus.delivered;
                    break;
                  case 'cancelled':
                    status = order_models.OrderStatus.cancelled;
                    break;
                  default:
                    status = order_models.OrderStatus.pending;
                }

                final itemsList =
                    (data['items'] as List?)?.map((item) {
                      return order_models.OrderItem(
                        mealTitle: item['mealTitle'] ?? 'Unknown Meal',
                        quantity: (item['quantity'] ?? 1).toInt(),
                        pricePerUnit: (item['pricePerUnit'] ?? 0).toInt(),
                      );
                    }).toList() ??
                    [];

                final deliveryCoordinates = data['deliveryCoordinates'] != null
                    ? LatLng(
                        data['deliveryCoordinates']['latitude'] ?? 0.0,
                        data['deliveryCoordinates']['longitude'] ?? 0.0,
                      )
                    : null;

                return order_models.Order(
                  orderId: doc.id,
                  orderDate: parsedOrderDate,
                  items: itemsList,
                  totalAmount: (data['totalAmount'] ?? 0).toInt(),
                  status: status,
                  vendorId: data['vendorId'] ?? vendorId,
                  vendorName: data['vendorName'] ?? 'Unknown Vendor',
                  customerName: data['customerName'] ?? 'Unknown Customer',
                  deliveryAddress: data['deliveryAddress'] ?? 'No address',
                  contactNumber: data['contactNumber'] ?? 'No contact',
                  paymentMethod: data['paymentMethod'] ?? 'Unknown',
                  riderName: data['riderName'],
                  riderEta: data['riderEta'],
                  deliveryCoordinates: deliveryCoordinates,
                );
              } catch (e) {
                print('✗ Error parsing order ${doc.id}: $e');
                rethrow;
              }
            }).toList();
          })
          .handleError((error) {
            print('✗ FirestoreService.streamVendorOrders - Error: $error');
            AppLogger.error('Error streaming vendor orders: $error');
          });
    } catch (e) {
      print('✗ FirestoreService.streamVendorOrders - Error: $e');
      AppLogger.error('Error setting up vendor orders stream: $e');
      return Stream.error(e);
    }
  }

  Future<void> updateOrderStatus(
    String orderId,
    order_models.OrderStatus newStatus, {
    String? customerId,
  }) async {
    try {
      final statusStr = newStatus.toString().split('.').last;
      print(
        '✓ FirestoreService.updateOrderStatus: Updating order $orderId to status: $statusStr',
      );

      // Prepare update data
      final updateData = <String, dynamic>{
        'status': statusStr,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Auto-assign rider info when status changes to Out for Delivery
      if (newStatus == order_models.OrderStatus.outForDelivery) {
        updateData['riderName'] = 'Mark Santos';
        updateData['riderEta'] = '15 mins';
      }

      // Update in top-level orders collection directly (works offline with Firestore persistence)
      print('  → Updating top-level orders collection...');
      await _db.collection('orders').doc(orderId).update(updateData);
      print(
        '  ✓ Top-level order updated successfully (may be queued if offline)',
      );

      // Try to get customerId from cache or provided value
      if (customerId == null || customerId.isEmpty) {
        // Try to get from local cache without network requirement
        try {
          final orderDoc = await _db
              .collection('orders')
              .doc(orderId)
              .get(const GetOptions(source: Source.cache));
          customerId = orderDoc.data()?['customerId'];
          print('  → Found customerId from cache: $customerId');
        } catch (e) {
          print('  ⚠ Could not get customerId from cache: $e');
        }
      }

      // Update in user's subcollection if customerId is available
      if (customerId != null && customerId.isNotEmpty) {
        print('  → Updating user subcollection for customerId: $customerId');
        try {
          await _db
              .collection('users')
              .doc(customerId)
              .collection('orders')
              .doc(orderId)
              .update(updateData);
          print('  ✓ User subcollection updated successfully');
        } catch (e) {
          print('  ⚠ Warning: Could not update user subcollection: $e');
          // Don't rethrow - the main order update succeeded
        }
      } else {
        print('  ⚠ No customerId available for user subcollection update');
      }

      print('✓ FirestoreService.updateOrderStatus completed successfully');

      // Clear orders cache to force refresh on next request
      _clearOrdersCache();
    } catch (e) {
      print('✗ FirestoreService.updateOrderStatus Error: $e');
      AppLogger.error('Error updating order status: $e');
      rethrow;
    }
  }

  // ===== USER PROFILE =====
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String displayName,
    required String phone,
    required List<Map<String, dynamic>> addresses,
    required String role,
  }) async {
    try {
      AppLogger.info('FirestoreService.createUserProfile - Creating profile for: $email');
      AppLogger.info('Phone: $phone, Addresses count: ${addresses.length}, Role: $role');
      
      final profileData = {
        'email': email,
        'displayName': displayName,
        'phone': phone,
        'addresses': addresses,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _db.collection('users').doc(userId).set(profileData);
      AppLogger.info('Profile created successfully in Firestore for user: $userId');
    } catch (e) {
      AppLogger.error('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      AppLogger.info('FirestoreService.getUserProfile - Fetching profile for: $userId');
      
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        AppLogger.info('Profile found - Phone: ${data?['phone']}, Addresses: ${(data?['addresses'] as List?)?.length ?? 0}');
        return data;
      } else {
        AppLogger.warning('No profile found in Firestore for user: $userId');
      }
    } catch (e) {
      AppLogger.error('Error fetching user profile: $e');
    }
    return null;
  }

  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? phone,
    List<Map<String, dynamic>>? addresses,
    String? email,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (phone != null) updates['phone'] = phone;
      if (addresses != null) updates['addresses'] = addresses;
      if (email != null) updates['email'] = email;

      await _db.collection('users').doc(userId).update(updates);
    } catch (e) {
      AppLogger.error('Error updating user profile: $e');
      rethrow;
    }
  }

  // ===== HELPER METHOD =====
  order_models.OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return order_models.OrderStatus.pending;
      case 'confirmed':
        return order_models.OrderStatus.confirmed;
      case 'preparing':
        return order_models.OrderStatus.preparing;
      case 'outfordelivery':
        return order_models.OrderStatus.outForDelivery;
      case 'delivered':
        return order_models.OrderStatus.delivered;
      case 'cancelled':
        return order_models.OrderStatus.cancelled;
      default:
        return order_models.OrderStatus.pending;
    }
  }

  // ===== CACHE MANAGEMENT =====
  void _clearOrdersCache() {
    _ordersCache.clear();
    _cacheTimestamps.removeWhere((key, value) => key.startsWith('orders_'));
    print('✓ Orders cache cleared');
  }

  void clearAllCache() {
    _ordersCache.clear();
    _mealsCache.clear();
    _cacheTimestamps.clear();
    print('✓ All cache cleared');
  }
}
