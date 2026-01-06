// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
          .map((doc) => MealPackage(
                type: doc['type'] ?? 'General',
                title: doc['title'] ?? '',
                vendor: doc['vendor'] ?? '',
                desc: doc['desc'] ?? '',
                price: (doc['price'] ?? 0).toInt(),
                left: (doc['left'] ?? 0).toInt(),
                imageUrl: doc['imageUrl'] ?? '',
              ))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching meals: $e');
      return [];
    }
  }

  Future<MealPackage?> getMealById(String mealId) async {
    try {
      final doc = await _db.collection('meals').doc(mealId).get();
      if (doc.exists) {
        return MealPackage(
          type: doc['type'] ?? 'General',
          title: doc['title'] ?? '',
          vendor: doc['vendor'] ?? '',
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
      await _db.collection('users').doc(userId).collection('orders').add({
        'orderId': orderData.orderId,
        'orderDate': orderData.orderDate,
        'items': orderData.items
            .map((item) => {
                  'mealTitle': item.mealTitle,
                  'quantity': item.quantity,
                  'pricePerUnit': item.pricePerUnit,
                })
            .toList(),
        'totalAmount': orderData.totalAmount,
        'status': orderData.status.toString().split('.').last,
        'deliveryAddress': orderData.deliveryAddress,
        'contactNumber': orderData.contactNumber,
        'paymentMethod': orderData.paymentMethod,
        'riderName': orderData.riderName,
        'riderEta': orderData.riderEta,
      });
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

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return order_models.Order(
              orderId: data['orderId'] ?? '',
              orderDate: (data['orderDate'] as Timestamp).toDate(),
              items: (data['items'] as List)
                  .map((item) => order_models.OrderItem(
                        mealTitle: item['mealTitle'] ?? '',
                        quantity: (item['quantity'] ?? 0).toInt(),
                        pricePerUnit: (item['pricePerUnit'] ?? 0).toInt(),
                      ))
                  .toList(),
              totalAmount: (data['totalAmount'] ?? 0).toInt(),
              status: _parseOrderStatus(data['status'] ?? 'pending'),
              deliveryAddress: data['deliveryAddress'] ?? '',
              contactNumber: data['contactNumber'] ?? '',
              paymentMethod: data['paymentMethod'] ?? '',
              riderName: data['riderName'],
              riderEta: data['riderEta'],
            );
          })
          .toList();
    } catch (e) {
      if (e is FirebaseException) {
        AppLogger.error('Firebase error: ${e.message}');
      } else {
        AppLogger.error('Error: $e');
      }
      return [];
    }
  }

  Future<void> updateOrderStatus(
    String userId,
    String orderId,
    order_models.OrderStatus newStatus,
  ) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('orders')
          .where('orderId', isEqualTo: orderId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'status': newStatus.toString().split('.').last,
        });
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
    required String address,
    required String role,
  }) async {
    try {
      await _db.collection('users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'phone': phone,
        'address': address,
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
    String? address,
    String? email,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;
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
