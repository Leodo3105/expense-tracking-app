import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FutureBuilder(
        future: Provider.of<NotificationProvider>(context, listen: false).fetchNotifications(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load notifications.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          } else {
            return Consumer<NotificationProvider>(
              builder: (ctx, notificationProvider, _) {
                if (notificationProvider.notifications.isEmpty) {
                  return Center(
                    child: Text(
                      'No notifications found.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: notificationProvider.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notificationProvider.notifications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Icon(
                          _getNotificationIcon(notification.type),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          notification.type,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        trailing: Text(
                          notification.createdAt.toLocal().toString().split(' ')[0],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  // Hàm để lấy biểu tượng dựa trên loại thông báo
  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'alert':
        return Icons.notifications_active;
      case 'reminder':
        return Icons.alarm;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}