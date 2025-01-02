import 'package:flutter/material.dart';
import '../models/notificationmodel.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        notification.isRead ? Icons.notifications : Icons.notifications_active,
        color: notification.isRead ? Colors.grey : Colors.blue,
      ),
      title: Text(notification.message),
      trailing: IconButton(
        icon: Icon(Icons.check),
        onPressed: onTap,
      ),
    );
  }
}
