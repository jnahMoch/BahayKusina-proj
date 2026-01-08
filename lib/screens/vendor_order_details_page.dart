// lib/screens/vendor_order_details_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/order.dart' as order_models;
import '../providers/vendor_provider.dart';
import '../providers/auth_provider.dart';

class VendorOrderDetailsPage extends StatefulWidget {
  final order_models.Order order;

  const VendorOrderDetailsPage({super.key, required this.order});

  static const Color primaryOrange = Color(0xFFFF6B00);

  @override
  State<VendorOrderDetailsPage> createState() => _VendorOrderDetailsPageState();
}

class _VendorOrderDetailsPageState extends State<VendorOrderDetailsPage> {
  late order_models.OrderStatus _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  Future<void> _updateOrderStatus(order_models.OrderStatus newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final statusStr = newStatus.toString().split('.').last;
      print(
        '✓ VendorOrderDetailsPage: Updating order ${widget.order.orderId} to $statusStr',
      );

      final updateData = <String, dynamic>{
        'status': statusStr,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Auto-assign rider info when status changes to Out for Delivery
      if (newStatus == order_models.OrderStatus.outForDelivery) {
        updateData['riderName'] = 'Mark Santos';
        updateData['riderEta'] = '15 mins';
      }

      // First, get the order document to find customerId
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.orderId)
          .get();

      final customerId = orderDoc.data()?['customerId'] as String?;
      print('✓ Found customerId: $customerId');

      // Update in main orders collection
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.orderId)
          .update(updateData);
      print('✓ Main orders collection updated');

      // Also update in user's subcollection if customerId exists
      if (customerId != null && customerId.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(customerId)
              .collection('orders')
              .doc(widget.order.orderId)
              .update(updateData);
          print('✓ User subcollection updated for customer: $customerId');
        } catch (e) {
          print('⚠ Warning: Could not update user subcollection: $e');
          // Don't fail the whole operation if subcollection update fails
        }
      }

      // Update VendorProvider state so UI updates immediately
      if (mounted) {
        final vendorProvider = Provider.of<VendorProvider>(
          context,
          listen: false,
        );
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final vendorId = authProvider.currentUser?.userId ?? 'vendor_nanay';

        // Refresh vendor data to sync state
        await vendorProvider.refreshVendorData(vendorId);
        print('✓ VendorProvider state refreshed');
      }

      setState(() {
        _currentStatus = newStatus;
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Order ${statusStr}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('✗ Error updating order status: $e');
      setState(() {
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order ${widget.order.orderId.replaceAll('ORD', '#')}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _currentStatus == order_models.OrderStatus.outForDelivery
                  ? VendorOrderDetailsPage.primaryOrange
                  : _currentStatus == order_models.OrderStatus.delivered
                  ? Colors.green
                  : Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _currentStatus == order_models.OrderStatus.outForDelivery
                  ? 'out-for-delivery'
                  : _currentStatus.toString().split('.').last,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Information Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer: ${widget.order.customerName}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact: ${widget.order.contactNumber}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Address: ${widget.order.deliveryAddress}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Payment: ${widget.order.paymentMethod} (pending)',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(widget.order.orderDate)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Total Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₱${widget.order.totalAmount}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: VendorOrderDetailsPage.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order Items
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Items:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...widget.order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.mealTitle} x ${item.quantity}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            '₱${item.totalPrice}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status Update Dropdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Status:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _isUpdating
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: VendorOrderDetailsPage.primaryOrange,
                          ),
                        )
                      : DropdownButtonFormField<order_models.OrderStatus>(
                          value: _currentStatus,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          items: order_models.OrderStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                status ==
                                        order_models.OrderStatus.outForDelivery
                                    ? 'Out for Delivery'
                                    : status
                                              .toString()
                                              .split('.')
                                              .last[0]
                                              .toUpperCase() +
                                          status
                                              .toString()
                                              .split('.')
                                              .last
                                              .substring(1),
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null &&
                                newStatus != _currentStatus) {
                              _showUpdateConfirmation(newStatus);
                            }
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateConfirmation(order_models.OrderStatus newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Text(
          'Change status to "${newStatus == order_models.OrderStatus.outForDelivery ? 'Out for Delivery' : newStatus.toString().split('.').last}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VendorOrderDetailsPage.primaryOrange,
            ),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
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
    final hour = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$month ${dateTime.day}, ${dateTime.year}, $hour:$minute:$second $period';
  }
}
