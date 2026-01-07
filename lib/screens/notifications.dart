// lib/screens/notifications.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);
      if (notificationService.notifications.isEmpty) {
        _addSampleNotifications(notificationService);
      }
    });
  }

  void _addSampleNotifications(NotificationService service) {
    service.addNotification(NotificationModel(
      title: 'Order Confirmed',
      message: 'Your order #ORD-001 has been confirmed and is being prepared.',
      time: '10:30 AM',
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
    ));
    service.addNotification(NotificationModel(
      title: 'Out for Delivery',
      message: 'Your order #ORD-001 is now out for delivery. Track it live!',
      time: '11:00 AM',
      icon: Icons.delivery_dining_rounded,
      iconColor: const Color(0xFFFF6B00),
    ));
    service.addNotification(NotificationModel(
      title: 'Order Delivered',
      message: 'Your order #ORD-001 has been successfully delivered.',
      time: '11:25 AM',
      icon: Icons.home_rounded,
      iconColor: Colors.blue,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (notificationService.notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                notificationService.clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications cleared')),
                );
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationService.notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: notificationService.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationService.notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something important happens.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: notification.iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(notification.icon, color: notification.iconColor, size: 26),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              notification.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              notification.time,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            notification.message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
          ),
        ),
      ),
    );
  }
}
