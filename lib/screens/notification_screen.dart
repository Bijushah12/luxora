import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_notification.dart';
import '../providers/notification_provider.dart';
import '../theme/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return IconButton(
                tooltip: 'Mark all as read',
                icon: const Icon(Icons.mark_email_read_outlined),
                onPressed: provider.unreadCount == 0
                    ? null
                    : () => provider.markAllRead(),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              final provider = context.read<NotificationProvider>();
              if (value == 'clear_read') {
                provider.clearRead();
              }
              if (value == 'clear_all') {
                provider.clearAll();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'clear_read', child: Text('Clear Read')),
              PopupMenuItem(
                value: 'clear_all',
                child: Text(
                  'Clear All',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (!provider.isLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          final notifications = provider.notifications;
          if (notifications.isEmpty) {
            return const _EmptyNotificationState();
          }

          final grouped = _groupNotifications(notifications);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _NotificationSummary(unreadCount: provider.unreadCount),
              const SizedBox(height: 18),
              ...grouped.entries.expand((entry) {
                return [
                  _SectionTitle(title: entry.key),
                  const SizedBox(height: 10),
                  ...entry.value.map(
                    (notification) => _NotificationCard(
                      notification: notification,
                      time: _relativeTime(notification.createdAt),
                      icon: _iconForType(notification.type),
                      color: _colorForType(notification.type),
                      onTap: () => provider.markAsRead(notification.id),
                      onDelete: () =>
                          provider.deleteNotification(notification.id),
                    ),
                  ),
                  const SizedBox(height: 12),
                ];
              }),
            ],
          );
        },
      ),
    );
  }

  Map<String, List<AppNotification>> _groupNotifications(
    List<AppNotification> notifications,
  ) {
    final grouped = <String, List<AppNotification>>{};

    for (final notification in notifications) {
      final label = _groupLabel(notification.createdAt);
      grouped.putIfAbsent(label, () => []).add(notification);
    }

    return grouped;
  }

  String _groupLabel(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(now, date)) {
      return 'Today';
    }
    if (DateUtils.isSameDay(now.subtract(const Duration(days: 1)), date)) {
      return 'Yesterday';
    }
    return 'Earlier';
  }

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} mins ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'payment':
        return Icons.payments_outlined;
      case 'shipping':
        return Icons.local_shipping_outlined;
      case 'wishlist':
        return Icons.favorite_border;
      case 'offer':
        return Icons.local_offer_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'order':
        return AppColors.success;
      case 'payment':
        return const Color(0xFF2563EB);
      case 'shipping':
        return const Color(0xFF0284C7);
      case 'wishlist':
        return AppColors.error;
      case 'offer':
        return AppColors.accent;
      default:
        return const Color(0xFF7C3AED);
    }
  }
}

class _NotificationSummary extends StatelessWidget {
  final int unreadCount;

  const _NotificationSummary({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unreadCount == 0
                      ? 'All caught up'
                      : '$unreadCount unread ${unreadCount == 1 ? 'alert' : 'alerts'}',
                  style: const TextStyle(
                    color: AppColors.textInverse,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order updates, offers, and account activity appear here.',
                  style: TextStyle(
                    color: AppColors.textInverse.withValues(alpha: 0.72),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final String time;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.time,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.border
                  : color.withValues(alpha: 0.36),
              width: notification.isRead ? 1 : 1.4,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            title: Text(
              notification.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: notification.isRead
                    ? FontWeight.w600
                    : FontWeight.w800,
                color: notification.isRead
                    ? AppColors.textLight
                    : AppColors.textDark,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            trailing: notification.isRead
                ? null
                : const Icon(Icons.circle, color: AppColors.error, size: 9),
          ),
        ),
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 42,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'New order updates and offers will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    );
  }
}
