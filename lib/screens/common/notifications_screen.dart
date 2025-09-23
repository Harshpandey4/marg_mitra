import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Service is completed successfully',
      message: 'Yous Car Maintainence is completed successfully',
      time: ' before 2 minutes',
      type: NotificationType.success,
      isRead: false,
    ),
    NotificationItem(
      title: 'technician is on the way ',
      message: 'technician Raj will come soon ',
      time: 'before 15 minutes',
      type: NotificationType.info,
      isRead: false,
    ),
    NotificationItem(
      title: 'maintenance reminder',
      message: 'Its  time to change your cars oil.',
      time: '2 hours ago.',
      type: NotificationType.warning,
      isRead: true,
    ),
    NotificationItem(
      title: 'New feature added',
      message: 'You can now use SOS offline.',
      time: '1 day ago',
      type: NotificationType.update,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: const Text(
          'Notificatin',
          style: TextStyle(
            color: Colors.yellow ,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(notifications[index], index);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue[50],
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: notification.isRead ? Colors.grey.shade200 : Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              notification.message,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notification.time,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF1E88E5),
            shape: BoxShape.circle,
          ),
        )
            : null,
        onTap: () => _markAsRead(index),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'no information',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You have not  received any new notifications yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.update:
        return Colors.purple;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.update:
        return Icons.system_update;
    }
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index].isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
  }
}

enum NotificationType { success, warning, error, info, update }

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
  });
}