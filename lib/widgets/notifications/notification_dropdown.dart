/// Notification Dropdown
/// แสดงรายการ notifications ในรูปแบบ dropdown

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';

class NotificationDropdown extends StatelessWidget {
  final String userId;
  final VoidCallback onClose;

  const NotificationDropdown({
    super.key,
    required this.userId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final notifications = notificationProvider.notifications;
        final isLoading = notificationProvider.isLoading;

        return Container(
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'การแจ้งเตือน',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (notifications.any((n) => !n.isRead))
                      notificationProvider.isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            )
                          : TextButton(
                              onPressed: () async {
                                debugPrint('🔔 [NotificationDropdown] อ่านหมดแล้ว clicked');
                                await notificationProvider.markAllAsRead(userId);
                                debugPrint('✅ [NotificationDropdown] markAllAsRead completed');
                              },
                              child: const Text(
                                'อ่านหมดแล้ว',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onClose,
                      tooltip: 'ปิด',
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : notifications.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => notificationProvider.refresh(userId),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: notifications.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final notification = notifications[index];
                                return _buildNotificationItem(
                                  context,
                                  notification,
                                  notificationProvider,
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'ไม่มีการแจ้งเตือน',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
    NotificationProvider provider,
  ) {
    return InkWell(
      onTap: () async {
        debugPrint('🔔 [NotificationDropdown] Notification clicked: ${notification.id}');
        debugPrint('  - isRead: ${notification.isRead}');
        debugPrint('  - title: ${notification.title}');
        
        // Mark as read
        if (!notification.isRead) {
          debugPrint('📖 [NotificationDropdown] Marking as read...');
          final success = await provider.markAsRead(notification.id, userId);
          debugPrint('  - Success: $success');
        }
        
        // Navigate to related page (if link exists)
        if (notification.link != null) {
          debugPrint('🔗 [NotificationDropdown] Navigating to: ${notification.link}');
          // TODO: Implement navigation based on link
          // context.go(notification.link!);
          onClose();
        }
      },
      child: Container(
        color: notification.isRead ? Colors.white : const Color(0xFFF1F8F1),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon based on type
            _buildTypeIcon(notification.type),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead 
                          ? FontWeight.normal 
                          : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
              itemBuilder: (context) => [
                if (!notification.isRead)
                  const PopupMenuItem(
                    value: 'read',
                    child: Row(
                      children: [
                        Icon(Icons.check, size: 18),
                        SizedBox(width: 8),
                        Text('ทำเครื่องหมายว่าอ่านแล้ว'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('ลบ', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                debugPrint('🔔 [NotificationDropdown] PopupMenu selected: $value');
                if (value == 'read') {
                  debugPrint('📖 [NotificationDropdown] Marking as read via menu: ${notification.id}');
                  final success = await provider.markAsRead(notification.id, userId);
                  debugPrint('  - Success: $success');
                } else if (value == 'delete') {
                  debugPrint('🗑️ [NotificationDropdown] Deleting: ${notification.id}');
                  final success = await provider.deleteNotification(notification.id);
                  debugPrint('  - Success: $success');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'reply':
        iconData = Icons.reply;
        color = Colors.blue;
        break;
      case 'comment_reply':
        iconData = Icons.comment;
        color = Colors.orange;
        break;
      case 'status_change':
        iconData = Icons.info;
        color = Colors.green;
        break;
      case 'upvote':
        iconData = Icons.thumb_up;
        color = Colors.purple;
        break;
      case 'mention':
        iconData = Icons.alternate_email;
        color = Colors.red;
        break;
      default:
        iconData = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _formatTime(DateTime dateTime) {
    timeago.setLocaleMessages('th', timeago.ThMessages());
    return timeago.format(dateTime, locale: 'th');
  }
}
