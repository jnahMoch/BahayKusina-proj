// lib/screens/orders_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vendor_provider.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart' as order_models;
import 'package:intl/intl.dart';
import 'vendor_order_details_page.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Active Orders",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "Track and manage incoming meal requests",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<VendorProvider>(
            builder: (context, provider, child) {
              if (provider.orders.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final vendorId =
                      authProvider.currentUser?.userId ?? 'vendor_nanay';
                  provider.refreshVendorData(vendorId);
                },
                color: const Color(0xFFFF6B00),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.orders.length,
                  itemBuilder: (context, index) {
                    final order = provider.orders[index];
                    return _OrderCard(order: order);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No orders yet",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final order_models.Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(order.orderDate);
    final dateStr = DateFormat('MMM dd').format(order.orderDate);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorOrderDetailsPage(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    // Show "NEW" badge for orders less than 5 minutes old
                    if (DateTime.now().difference(order.orderDate).inMinutes <
                        5)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(order.status),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (order.contactNumber.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.phone_outlined,
                      color: Colors.blue,
                      size: 20,
                    ),
                    onPressed: () {
                      // In a real app, uses url_launcher to dial
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...order.items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${item.quantity}x ${item.mealTitle}",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          "₱${item.totalPrice}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$dateStr at $timeStr",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 150,
                          child: Text(
                            order.deliveryAddress,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  "₱${order.totalAmount}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B00),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTrackingActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(order_models.OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case order_models.OrderStatus.pending:
        color = Colors.orange;
        text = "Pending";
        break;
      case order_models.OrderStatus.confirmed:
        color = const Color(0xFF2196F3);
        text = "Confirmed";
        break;
      case order_models.OrderStatus.preparing:
        color = const Color(0xFFFF8C3B);
        text = "Preparing";
        break;
      case order_models.OrderStatus.outForDelivery:
        color = Colors.blue;
        text = "Out for Delivery";
        break;
      case order_models.OrderStatus.delivered:
        color = Colors.green;
        text = "Delivered";
        break;
      case order_models.OrderStatus.cancelled:
        color = Colors.red;
        text = "Cancelled";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    String label,
    Color color,
    order_models.OrderStatus nextStatus,
  ) {
    return ElevatedButton(
      onPressed: () async {
        print('✓ Button pressed: $label');
        print('  Current order status: ${order.status}');
        print('  Target status: $nextStatus');

        try {
          final vendorProvider = Provider.of<VendorProvider>(
            context,
            listen: false,
          );
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          print('✓ VendorProvider obtained');

          // Show loading snackbar
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Updating order...'),
                duration: Duration(seconds: 60),
              ),
            );
          }

          // Execute with timeout of 30 seconds for network operations
          final success = await vendorProvider
              .updateOrderStatus(order.orderId, nextStatus)
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () {
                  print('✗ updateOrderStatus timeout after 30 seconds');
                  return false;
                },
              );

          print('✓ updateOrderStatus returned: $success');

          // Refresh vendor data to ensure UI is in sync
          if (success && context.mounted) {
            final vendorId = authProvider.currentUser?.userId ?? 'vendor_nanay';
            await vendorProvider.refreshVendorData(vendorId);
            print('✓ Vendor data refreshed after status update');
          }

          if (context.mounted) {
            // Clear loading snackbar
            ScaffoldMessenger.of(context).clearSnackBars();

            // Show result snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? '✓ Order ${nextStatus.toString().split('.').last}!'
                      : '⚠ Update may have failed. Check your connection and try again.',
                ),
                backgroundColor: success ? Colors.green : Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          print('✗ Exception in button: $e');
          print('  Stack trace: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Connection error: ${e.toString().length > 50 ? "Check your internet" : e.toString()}',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTrackingActions(BuildContext context) {
    if (order.status == order_models.OrderStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: _actionButton(
              context,
              "Accept Order",
              const Color(0xFFFF6B00),
              order_models.OrderStatus.confirmed,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _actionButton(
              context,
              "Decline",
              Colors.red,
              order_models.OrderStatus.cancelled,
            ),
          ),
        ],
      );
    } else if (order.status == order_models.OrderStatus.confirmed) {
      return Row(
        children: [
          Expanded(
            child: _actionButton(
              context,
              "Start Preparing",
              const Color(0xFFFF8C3B),
              order_models.OrderStatus.preparing,
            ),
          ),
        ],
      );
    } else if (order.status == order_models.OrderStatus.preparing) {
      return Row(
        children: [
          Expanded(
            child: _actionButton(
              context,
              "Mark Ready for Delivery",
              const Color(0xFFFF6B00),
              order_models.OrderStatus.outForDelivery,
            ),
          ),
        ],
      );
    } else if (order.status == order_models.OrderStatus.outForDelivery) {
      return Row(
        children: [
          Expanded(
            child: _actionButton(
              context,
              "Mark Delivered",
              Colors.green,
              order_models.OrderStatus.delivered,
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
