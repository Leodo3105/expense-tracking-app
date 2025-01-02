import 'package:flutter/material.dart';
import '../models/notificationmodel.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  String _token = "";

  List<NotificationModel> get notifications => _notifications;
  String get token => _token;

  set token(String value) {
    _token = value;
    notifyListeners();
  }

  // Fetch all notifications
  Future<void> fetchNotifications() async {
    try {
      _notifications = await NotificationService.getNotifications(_token);
      notifyListeners();
    } catch (error) {
      print('Error fetching notifications: $error');
      throw Exception('Failed to fetch notifications');
    }
  }

  // Mark a specific notification as read
  Future<void> markNotificationAsRead(int id) async {
    await NotificationService.markAsRead(id, _token);
    final notificationIndex = _notifications.indexWhere((n) => n.id == id);
    if (notificationIndex != -1) {
      final existingNotification = _notifications[notificationIndex];
      _notifications[notificationIndex] = NotificationModel(
        id: existingNotification.id,
        userId: existingNotification.userId, // Preserve userId
        type: existingNotification.type, // Preserve type
        message: existingNotification.message, // Preserve message
        isRead: true, // Update isRead to true
        createdAt: existingNotification.createdAt,
      );
    }
    notifyListeners();
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    await NotificationService.markAllAsRead(_token);
    _notifications = _notifications.map((notification) {
      return NotificationModel(
        id: notification.id,
        userId: notification.userId, // Preserve userId
        type: notification.type, // Preserve type
        message: notification.message, // Preserve message
        isRead: true, // Update isRead to true
        createdAt: notification.createdAt,
      );
    }).toList();
    notifyListeners();
  }
}
