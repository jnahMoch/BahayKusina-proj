// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/meal_package.dart';
import '../models/order.dart' as order_models;
import '../utils/logger.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
              price: (doc['price'] ?? 0).toInt(),
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

  Future<List<MealPackage>> getVendorMeals(String vendorId) async {
    try {
      final snapshot = await _db
          .collection('meals')
          .where('vendorId', isEqualTo: vendorId)
          .get();
      return snapshot.docs
          .map(
            (doc) => MealPackage(
              id: doc.id,
              type: doc['type'] ?? 'General',
              title: doc['title'] ?? '',
              vendor: doc['vendor'] ?? '',
              vendorId: doc['vendorId'] ?? 'unknown_vendor',
              desc: doc['desc'] ?? '',
              price: (doc['price'] ?? 0).toInt(),
              left: (doc['left'] ?? 0).toInt(),
              imageUrl: doc['imageUrl'] ?? '',
            ),
          )
          .toList();
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
          price: (doc['price'] ?? 0).toInt(),
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
    print('✓ FirestoreService.streamOrder - Starting stream for orderId: "$orderId"');
    
    try {
      return _db
          .collection('orders')
          .doc(orderId)
          .snapshots()
          .map((snapshot) {
            print('✓ FirestoreService.streamOrder - Snapshot received, exists: ${snapshot.exists}');
            
            if (!snapshot.exists) {
              print('✗ FirestoreService.streamOrder - Order "$orderId" not found in Firestore');
              return null;
            }
            
            final data = snapshot.data() as Map<String, dynamic>;
            print('✓ FirestoreService.streamOrder - Order data keys: ${data.keys.toList()}');
            
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
                print('✗ FirestoreService.streamOrder - Could not parse orderDate: $e');
              }
            }
            
            final order = order_models.Order(
              orderId: data['orderId'] ?? '',
              orderDate: orderDate,
              items: (data['items'] as List?)
                  ?.map(
                    (item) => order_models.OrderItem(
                      mealTitle: item['mealTitle'] ?? '',
                      quantity: (item['quantity'] ?? 0).toInt(),
                      pricePerUnit: (item['pricePerUnit'] ?? 0).toInt(),
                    ),
                  )
                  .toList() ?? [],
              totalAmount: (data['totalAmount'] ?? 0).toInt(),
              status: _parseOrderStatus(data['status'] ?? 'pending'),
              vendorId: data['vendorId'] ?? '',
              vendorName: data['vendorName'] ?? '',
              customerName: data['customerName'] ?? 'Customer',
              deliveryAddress: data['deliveryAddress'] ?? '',
              contactNumber: data['contactNumber'] ?? '',
              paymentMethod: data['paymentMethod'] ?? '',
              riderName: data['riderName']?.toString().isEmpty == true ? null : data['riderName'],
              riderEta: data['riderEta']?.toString().isEmpty == true ? null : data['riderEta'],
              deliveryCoordinates: deliveryCoordinates,
            );
            
            print('✓ FirestoreService.streamOrder - Order parsed successfully: ${order.orderId}, status: ${order.status}');
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
      final snapshot = await _db
          .collection('orders')
          .where('vendorId', isEqualTo: vendorId)
          .orderBy('orderDate', descending: true)
          .get();

      return _snapshotToOrderList(snapshot);
    } catch (e) {
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

  Future<void> updateOrderStatus(
    String orderId,
    order_models.OrderStatus newStatus, {
    String? customerId,
  }) async {
    try {
      final statusStr = newStatus.toString().split('.').last;

      // Update in top-level orders
      await _db.collection('orders').doc(orderId).update({'status': statusStr});

      // Update in user's subcollection if customerId is known
      if (customerId != null) {
        await _db
            .collection('users')
            .doc(customerId)
            .collection('orders')
            .doc(orderId)
            .update({'status': statusStr});
      } else {
        // Find the order to get customerId
        final orderDoc = await _db.collection('orders').doc(orderId).get();
        if (orderDoc.exists) {
          final cid = orderDoc.data()?['customerId'];
          if (cid != null) {
            await _db
                .collection('users')
                .doc(cid)
                .collection('orders')
                .doc(orderId)
                .update({'status': statusStr});
          }
        }
      }
    } catch (e) {
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
      await _db.collection('users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'phone': phone,
        'addresses': addresses,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
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
}
