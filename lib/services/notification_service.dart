// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import '../utils/logger.dart';

enum NotificationType {
  order,
  promotion,
  system,
}

class NotificationModel {
  final String title;
  final String message;
  final String time;
  final DateTime? timestamp;
  final IconData icon;
  final Color iconColor;
  final NotificationType type;
  final String? orderId;
  bool isRead;

  NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    this.timestamp,
    required this.icon,
    this.iconColor = Colors.blue,
    this.type = NotificationType.system,
    this.orderId,
    this.isRead = false,
  });
}

class NotificationService extends ChangeNotifier {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() {
    return _instance;
  }
  NotificationService._internal();

  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    // In a real app, you would also persist this notification
    AppLogger.info('Notification added: ${notification.title}');
    notifyListeners();
  }

  void markAsRead(NotificationModel notification) {
    notification.isRead = true;
    AppLogger.info('Notification marked as read: ${notification.title}');
    notifyListeners();
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    AppLogger.info('All notifications marked as read.');
    notifyListeners();
  }

  void removeNotification(NotificationModel notification) {
    _notifications.remove(notification);
    AppLogger.info('Notification removed: ${notification.title}');
    notifyListeners();
  }

  // This is a placeholder for a real notification showing mechanism.
  Future<void> showNotification(String title, String body) async {
    AppLogger.info('--- Notification ---');
    AppLogger.info('Title: $title');
    AppLogger.info('Body: $body');
    AppLogger.info('--------------------');
  }

  void clearAll() {
    _notifications.clear();
    AppLogger.info('All notifications cleared.');
    notifyListeners();
  }
}
