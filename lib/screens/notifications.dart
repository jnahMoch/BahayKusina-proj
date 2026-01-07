// lib/screens/notifications.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);
      if (notificationService.notifications.isEmpty) {
        _addSampleNotifications(notificationService);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addSampleNotifications(NotificationService service) {
    service.addNotification(NotificationModel(
      title: 'Order Confirmed',
      message: 'Your order #ORD-001 has been confirmed and is being prepared.',
      time: '10:30 AM',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
      type: NotificationType.order,
      orderId: 'ORD-001',
    ));
    service.addNotification(NotificationModel(
      title: 'Out for Delivery',
      message: 'Your order #ORD-001 is now out for delivery. Track it live!',
      time: '11:00 AM',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      icon: Icons.delivery_dining_rounded,
      iconColor: const Color(0xFFFF6B00),
      type: NotificationType.order,
      orderId: 'ORD-001',
    ));
    service.addNotification(NotificationModel(
      title: 'Special Offer!',
      message: 'Get 20% off on all breakfast packages this week!',
      time: '9:00 AM',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      icon: Icons.local_offer_rounded,
      iconColor: Colors.purple,
      type: NotificationType.promotion,
    ));
    service.addNotification(NotificationModel(
      title: 'New Vendor Available',
      message: 'Lola\'s Kitchen just joined BahayKusina! Check out their delicious meals.',
      time: 'Yesterday',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.store_rounded,
      iconColor: Colors.blue,
      type: NotificationType.system,
    ));
  }

  List<NotificationModel> _filterNotifications(
    List<NotificationModel> notifications,
    NotificationType? type,
  ) {
    if (type == null) return notifications;
    return notifications.where((n) => n.type == type).toList();
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
            IconButton(
              icon: const Icon(Icons.done_all, color: Color(0xFFFF6B00)),
              onPressed: () {
                notificationService.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All marked as read')),
                );
              },
              tooltip: 'Mark all as read',
            ),
          if (notificationService.notifications.isNotEmpty)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear all'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'clear') {
                  notificationService.clearAll();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications cleared')),
                  );
                }
              },
            ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF6B00),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF6B00),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Orders'),
            Tab(text: 'Promos'),
          ],
        ),
      ),
      body: notificationService.notifications.isEmpty
          ? _buildEmptyState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(notificationService, null),
                _buildNotificationList(notificationService, NotificationType.order),
                _buildNotificationList(notificationService, NotificationType.promotion),
              ],
            ),
    );
  }

  Widget _buildNotificationList(
    NotificationService service,
    NotificationType? filterType,
  ) {
    final filtered = _filterNotifications(service.notifications, filterType);
    
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No ${filterType?.name ?? ''} notifications',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Simulate refresh
        await Future.delayed(const Duration(seconds: 1));
      },
      color: const Color(0xFFFF6B00),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final notification = filtered[index];
          return Dismissible(
            key: Key(notification.time + index.toString()),
            background: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              service.removeNotification(notification);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notification deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      service.addNotification(notification);
                    },
                  ),
                ),
              );
            },
            child: _buildNotificationCard(notification, service),
          );
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

  Widget _buildNotificationCard(
    NotificationModel notification,
    NotificationService service,
  ) {
    final relativeTime = notification.timestamp != null
        ? timeago.format(notification.timestamp!)
        : notification.time;

    return InkWell(
      onTap: () {
        // Mark as read
        if (!notification.isRead) {
          service.markAsRead(notification);
        }
        
        // Navigate based on type
        if (notification.type == NotificationType.order && notification.orderId != null) {
          // Navigate to order details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening order ${notification.orderId}')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: notification.isRead 
                ? Colors.transparent 
                : const Color(0xFFFF6B00).withOpacity(0.2),
            width: 1,
          ),
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
          leading: Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: notification.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(notification.icon, color: notification.iconColor, size: 26),
              ),
              if (!notification.isRead)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B00),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                relativeTime,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              notification.message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
