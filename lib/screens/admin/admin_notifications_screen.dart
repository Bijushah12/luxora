import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_broadcast_notification.dart';
import '../../providers/admin_notifications_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin/admin_empty_state.dart';
import '../../widgets/admin/admin_feedback.dart';
import '../../widgets/admin/admin_luxury_widgets.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _searchController = TextEditingController();
  String _audienceFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNotificationForm([AdminBroadcastNotification? notification]) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AdminNotificationsProvider>(),
        child: _NotificationFormDialog(notification: notification),
      ),
    );
  }

  List<AdminBroadcastNotification> _filter(
    List<AdminBroadcastNotification> notifications,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    return notifications
        .where((notification) {
          final matchesAudience =
              _audienceFilter == 'All' ||
              notification.audience == _audienceFilter;
          final matchesQuery =
              query.isEmpty ||
              notification.title.toLowerCase().contains(query) ||
              notification.message.toLowerCase().contains(query);
          return matchesAudience && matchesQuery;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Consumer<AdminNotificationsProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<AdminBroadcastNotification>>(
          stream: provider.notificationsStream(),
          builder: (context, snapshot) {
            final notifications =
                snapshot.data ?? const <AdminBroadcastNotification>[];
            final filtered = _filter(notifications);

            return AdminLuxuryBackground(
              child: ListView(
                children: [
                  AdminFeedbackBanner(
                    error: provider.errorMessage,
                    success: provider.successMessage,
                    onClose: provider.clearMessages,
                  ),
                  AdminGlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdminSectionHeader(
                          icon: Icons.notifications_active_outlined,
                          title: 'Push Notifications',
                          subtitle:
                              'Create campaigns, queue push messages, and store delivery intent in Firebase.',
                          trailing: ElevatedButton.icon(
                            onPressed: () => _openNotificationForm(),
                            icon: const Icon(Icons.add),
                            label: const Text('New Push'),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _NotificationSummary(notifications: notifications),
                        const SizedBox(height: 18),
                        _NotificationToolbar(
                          controller: _searchController,
                          audienceFilter: _audienceFilter,
                          onSearchChanged: (_) => setState(() {}),
                          onAudienceChanged: (value) {
                            setState(() => _audienceFilter = value);
                          },
                        ),
                        const SizedBox(height: 18),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              minHeight: 4,
                              color: AppColors.accent,
                            ),
                          )
                        else if (snapshot.hasError)
                          _DarkError(message: snapshot.error.toString())
                        else if (notifications.isEmpty)
                          SizedBox(
                            height: 320,
                            child: AdminEmptyState(
                              icon: Icons.notifications_active_outlined,
                              title: 'No push campaigns yet',
                              message:
                                  'Create a push notification campaign for customers.',
                              action: ElevatedButton.icon(
                                onPressed: () => _openNotificationForm(),
                                icon: const Icon(Icons.add),
                                label: const Text('Create Push'),
                              ),
                            ),
                          )
                        else if (filtered.isEmpty)
                          const SizedBox(
                            height: 260,
                            child: AdminEmptyState(
                              icon: Icons.search_off,
                              title: 'No matching notifications',
                              message: 'Adjust search text or audience filter.',
                            ),
                          )
                        else
                          _NotificationList(
                            notifications: filtered,
                            provider: provider,
                            onEdit: _openNotificationForm,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _NotificationSummary extends StatelessWidget {
  final List<AdminBroadcastNotification> notifications;

  const _NotificationSummary({required this.notifications});

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    final scheduled = notifications.where((item) => item.isScheduled).length;
    final immediate = notifications.length - scheduled;
    final audiences = notifications.map((item) => item.audience).toSet().length;

    return AdminResponsiveGrid(
      minItemWidth: 210,
      children: [
        _SummaryTile(
          label: 'Campaigns',
          value: notifications.length.toString(),
        ),
        _SummaryTile(label: 'Immediate', value: immediate.toString()),
        _SummaryTile(label: 'Scheduled', value: scheduled.toString()),
        _SummaryTile(label: 'Audiences', value: audiences.toString()),
      ],
    );
  }
}

class _NotificationToolbar extends StatelessWidget {
  final TextEditingController controller;
  final String audienceFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onAudienceChanged;

  const _NotificationToolbar({
    required this.controller,
    required this.audienceFilter,
    required this.onSearchChanged,
    required this.onAudienceChanged,
  });

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = AdminLuxuryTextField(
          controller: controller,
          label: 'Search notifications',
          icon: Icons.search,
          onChanged: onSearchChanged,
        );
        final dropdown = DropdownButtonFormField<String>(
          initialValue: audienceFilter,
          dropdownColor: AppColors.primary,
          style: TextStyle(color: AppColors.textInverse),
          decoration: InputDecoration(
            labelText: 'Audience',
            labelStyle: const TextStyle(color: Color(0xFFD1D5DB)),
            prefixIcon: Icon(Icons.groups_outlined, color: AppColors.accent),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.07),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.accent, width: 1.4),
            ),
          ),
          items:
              const [
                    'All',
                    'All customers',
                    'Wishlist users',
                    'Cart abandoners',
                    'VIP customers',
                  ]
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) {
              onAudienceChanged(value);
            }
          },
        );

        if (constraints.maxWidth >= 720) {
          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 14),
              SizedBox(width: 260, child: dropdown),
            ],
          );
        }
        return Column(children: [search, const SizedBox(height: 10), dropdown]);
      },
    );
  }
}

class _NotificationList extends StatelessWidget {
  final List<AdminBroadcastNotification> notifications;
  final AdminNotificationsProvider provider;
  final ValueChanged<AdminBroadcastNotification> onEdit;

  const _NotificationList({
    required this.notifications,
    required this.provider,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Column(
      children: notifications
          .map(
            (notification) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _NotificationCard(
                notification: notification,
                isDeleting: provider.isDeleting(notification.id),
                onEdit: () => onEdit(notification),
                onSend: () => provider.send(notification),
                onDelete: () => provider.delete(notification.id),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AdminBroadcastNotification notification;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onSend;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.isDeleting,
    required this.onEdit,
    required this.onSend,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    final statusColor = notification.isScheduled
        ? AppColors.warning
        : AppColors.success;
    final statusText = notification.isScheduled ? 'Scheduled' : 'Ready';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AdminStatusPill(
                    label: notification.type.toUpperCase(),
                    color: AppColors.accent,
                    icon: Icons.campaign_outlined,
                  ),
                  const SizedBox(width: 10),
                  AdminStatusPill(label: statusText, color: statusColor),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notification.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textInverse,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                notification.audience,
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: compact ? WrapAlignment.start : WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              FilledButton.icon(
                onPressed: onSend,
                icon: const Icon(Icons.send_outlined, size: 18),
                label: const Text('Queue Push'),
              ),
              IconButton(
                tooltip: 'Delete notification',
                onPressed: isDeleting ? null : onDelete,
                icon: isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
                color: AppColors.error,
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [content, const SizedBox(height: 14), actions],
            );
          }

          return Row(
            children: [
              Expanded(child: content),
              const SizedBox(width: 18),
              SizedBox(width: 330, child: actions),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationFormDialog extends StatefulWidget {
  final AdminBroadcastNotification? notification;

  const _NotificationFormDialog({this.notification});

  @override
  State<_NotificationFormDialog> createState() =>
      _NotificationFormDialogState();
}

class _NotificationFormDialogState extends State<_NotificationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _scheduledAtController = TextEditingController();
  String _audience = 'All customers';
  String _type = 'offer';
  bool _isScheduled = false;

  @override
  void initState() {
    super.initState();
    final notification = widget.notification;
    if (notification != null) {
      _titleController.text = notification.title;
      _messageController.text = notification.message;
      _scheduledAtController.text = notification.scheduledAt == null
          ? ''
          : _formatDateTime(notification.scheduledAt!);
      _audience = notification.audience;
      _type = notification.type;
      _isScheduled = notification.isScheduled;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _scheduledAtController.dispose();
    super.dispose();
  }

  Future<void> _save(AdminNotificationsProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final base = widget.notification ?? AdminBroadcastNotification.empty();
    final notification = AdminBroadcastNotification(
      id: base.id,
      title: _titleController.text,
      message: _messageController.text,
      audience: _audience,
      type: _type,
      isScheduled: _isScheduled,
      scheduledAt: _scheduledAtController.text.trim().isEmpty
          ? null
          : DateTime.tryParse(_scheduledAtController.text.trim()),
      createdAt: base.createdAt,
    );
    final saved = await provider.save(notification);
    if (saved && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Consumer<AdminNotificationsProvider>(
      builder: (context, provider, child) {
        return AlertDialog(
          title: Text(
            widget.notification == null
                ? 'Create Push Notification'
                : 'Edit Push Notification',
          ),
          content: SizedBox(
            width: 580,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _messageController,
                      minLines: 3,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        prefixIcon: Icon(Icons.message_outlined),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _audience,
                            decoration: const InputDecoration(
                              labelText: 'Audience',
                              prefixIcon: Icon(Icons.groups_outlined),
                            ),
                            items:
                                const [
                                      'All customers',
                                      'Wishlist users',
                                      'Cart abandoners',
                                      'VIP customers',
                                    ]
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(item),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _audience = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _type,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: const ['offer', 'order', 'launch', 'stock']
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _type = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _isScheduled,
                      onChanged: (value) =>
                          setState(() => _isScheduled = value),
                      title: const Text('Schedule notification'),
                      subtitle: const Text('Leave off for immediate queueing'),
                    ),
                    if (_isScheduled) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _scheduledAtController,
                        decoration: const InputDecoration(
                          labelText: 'Schedule yyyy-mm-dd hh:mm',
                          prefixIcon: Icon(Icons.event_outlined),
                        ),
                        validator: (value) {
                          if (!_isScheduled) {
                            return null;
                          }
                          final raw = value?.trim() ?? '';
                          if (raw.isEmpty) {
                            return 'Required';
                          }
                          return DateTime.tryParse(raw) == null
                              ? 'Use yyyy-mm-dd hh:mm'
                              : null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: provider.isSaving
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: provider.isSaving ? null : () => _save(provider),
              icon: provider.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(provider.isSaving ? 'Saving' : 'Save Push'),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textInverse,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkError extends StatelessWidget {
  final String message;

  const _DarkError({required this.message});

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.24)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.textInverse,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String _formatDateTime(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.year}-$month-$day $hour:$minute';
}
