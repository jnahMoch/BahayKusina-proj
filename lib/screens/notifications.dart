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
      final notificationService = Provider.of<NotificationService>(context, listen: false);
      if (notificationService.notifications.isEmpty) {
        notificationService.addNotification(NotificationModel(
          title: 'Order Confirmed',
          message: 'Your order #ORD-001 has been confirmed and is being prepared.',
          time: '10:30 AM',
          icon: Icons.check_circle,
          iconColor: Colors.green,
        ));
        notificationService.addNotification(NotificationModel(
          title: 'Out for Delivery',
          message: 'Your order #ORD-001 is now out for delivery. Track it live!',
          time: '11:00 AM',
          icon: Icons.delivery_dining,
          iconColor: const Color(0xFFFF6B00),
        ));
        notificationService.addNotification(NotificationModel(
          title: 'Order Delivered',
          message: 'Your order #ORD-001 has been successfully delivered.',
          time: '11:25 AM',
          icon: Icons.home,
          iconColor: Colors.grey,
        ));
        notificationService.addNotification(NotificationModel(
          title: 'New Meal Package!',
          message: 'Nanay\'s Kitchen has added a new "Sinigang na Baboy" package.',
          time: 'Yesterday',
          icon: Icons.restaurant_menu,
          iconColor: Colors.blue,
        ));
        notificationService.addNotification(NotificationModel(
          title: 'Promo Alert',
          message: 'Get 20% off on all breakfast packages this weekend!',
          time: '2 days ago',
          icon: Icons.local_offer,
          iconColor: Colors.red,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFFFF6B00),
      ),
      body: notificationService.notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('No notifications yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notificationService.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationService.notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: notification.iconColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(notification.icon, color: notification.iconColor),
                    ),
                    title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(notification.message),
                    trailing: Text(notification.time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
