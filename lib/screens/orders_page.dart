// lib/screens/orders_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart' as order_models;
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import 'track_order_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color successGreen = Color(0xFF4CAF50);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<order_models.Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final orders = await _firestoreService.getUserOrders(
        authProvider.currentUser!.userId,
      );
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: OrdersPage.primaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${_orders.length} orders',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: OrdersPage.primaryOrange),
            )
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              color: OrdersPage.primaryOrange,
              child: _orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) =>
                          _buildOrderCard(_orders[index]),
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            'No orders yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by placing your first order',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(order_models.Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderId,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3557),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: order.statusColor.withOpacity(0.15),
                    border: Border.all(color: order.statusColor, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: order.statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(order.orderDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(vertical: 12),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.mealTitle,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Qty: ${item.quantity}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₱${item.totalPrice}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: OrdersPage.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(vertical: 12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  '₱${order.totalAmount}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: OrdersPage.primaryOrange,
                  ),
                ),
              ],
            ),
            if (order.status == order_models.OrderStatus.outForDelivery &&
                order.riderName != null) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rider: ${order.riderName}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ETA: ${order.riderEta}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackOrderPage(
                        orderId: order.orderId
                            .replaceAll('#', '')
                            .replaceAll('ORD-', ''),
                        riderName: order.riderName ?? 'Pending Assignment',
                        eta: order.riderEta ?? 'Calculating...',
                        deliveryAddress: order.deliveryAddress,
                        deliveryLocation: order.deliveryCoordinates,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrdersPage.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.location_on, size: 18),
                label: const Text(
                  'Track Order',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dateTime.month - 1];
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final hour = dateTime.hour % 12 == 12
        ? 12
        : (dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month ${dateTime.day}, ${dateTime.year} $hour:$minute $period';
  }
}
