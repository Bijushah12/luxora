import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_order.dart';
import '../../models/admin_user.dart';
import '../../providers/admin_users_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin/admin_empty_state.dart';
import '../../widgets/admin/admin_feedback.dart';
import '../../widgets/admin/admin_section.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminAppUser> _filterUsers(List<AdminAppUser> users) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return users;
    }

    return users
        .where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.phoneNumber.toLowerCase().contains(query) ||
              user.role.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminUsersProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<AdminAppUser>>(
          stream: provider.usersStream(),
          builder: (context, snapshot) {
            final users = snapshot.data ?? const <AdminAppUser>[];
            final filteredUsers = _filterUsers(users);

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AdminFeedbackBanner(
                  error: provider.errorMessage,
                  success: provider.successMessage,
                  onClose: provider.clearMessages,
                ),
                AdminSection(
                  title: 'Users',
                  subtitle:
                      'Registered customers with orders, cart, wishlist, addresses, and notifications',
                  icon: Icons.people_outline,
                  child: Column(
                    children: [
                      _UserSummaryStrip(users: users),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Search users',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const LinearProgressIndicator(minHeight: 3)
                      else if (snapshot.hasError)
                        _InlineError(message: snapshot.error.toString())
                      else if (users.isEmpty)
                        const SizedBox(
                          height: 340,
                          child: AdminEmptyState(
                            icon: Icons.people_outline,
                            title: 'No users yet',
                            message:
                                'New customer signup documents will appear here.',
                          ),
                        )
                      else if (filteredUsers.isEmpty)
                        const SizedBox(
                          height: 260,
                          child: AdminEmptyState(
                            icon: Icons.search_off,
                            title: 'No matching users',
                            message: 'Adjust the search text.',
                          ),
                        )
                      else
                        _UsersList(users: filteredUsers, provider: provider),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _UserSummaryStrip extends StatelessWidget {
  final List<AdminAppUser> users;

  const _UserSummaryStrip({required this.users});

  @override
  Widget build(BuildContext context) {
    final admins = users.where((user) => user.isAdmin).length;
    final blocked = users.where((user) => user.isBlocked).length;
    final customers = users.where((user) => !user.isAdmin).length;

    return _AdminSummaryGrid(
      items: [
        _AdminSummaryItem(
          label: 'Total Users',
          value: users.length.toString(),
          icon: Icons.people_outline,
          color: AppColors.primary,
        ),
        _AdminSummaryItem(
          label: 'Customers',
          value: customers.toString(),
          icon: Icons.person_outline,
          color: const Color(0xFF2563EB),
        ),
        _AdminSummaryItem(
          label: 'Admins',
          value: admins.toString(),
          icon: Icons.admin_panel_settings_outlined,
          color: AppColors.accent,
        ),
        _AdminSummaryItem(
          label: 'Blocked',
          value: blocked.toString(),
          icon: Icons.block_outlined,
          color: AppColors.error,
        ),
      ],
    );
  }
}

class _AdminSummaryGrid extends StatelessWidget {
  final List<_AdminSummaryItem> items;

  const _AdminSummaryGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: item == items.last ? 0 : 10,
                      ),
                      child: _AdminSummaryTile(item: item),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        }

        return SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) => SizedBox(
              width: 176,
              child: _AdminSummaryTile(item: items[index]),
            ),
          ),
        );
      },
    );
  }
}

class _AdminSummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminSummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _AdminSummaryTile extends StatelessWidget {
  final _AdminSummaryItem item;

  const _AdminSummaryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

class _UsersList extends StatelessWidget {
  final List<AdminAppUser> users;
  final AdminUsersProvider provider;

  const _UsersList({required this.users, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: users
          .map((user) => _UserActivityPanel(user: user, provider: provider))
          .toList(growable: false),
    );
  }
}

class _UserActivityPanel extends StatelessWidget {
  final AdminAppUser user;
  final AdminUsersProvider provider;

  const _UserActivityPanel({required this.user, required this.provider});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AdminUserActivity>(
      stream: provider.userActivityStream(user.id),
      builder: (context, snapshot) {
        final activity = snapshot.data ?? AdminUserActivity.empty();
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: Text(
                _initialsFor(user),
                style: const TextStyle(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user.name.isEmpty ? 'Unnamed user' : user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _RoleBadge(user: user),
                if (user.isBlocked) ...[
                  const SizedBox(width: 8),
                  const _BlockedBadge(),
                ],
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _contactLine(user),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 8),
                  if (isLoading)
                    const LinearProgressIndicator(minHeight: 2)
                  else if (snapshot.hasError)
                    Text(
                      'Unable to load activity',
                      style: TextStyle(
                        color: AppColors.error.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    _ActivityChips(activity: activity),
                ],
              ),
            ),
            children: [
              if (snapshot.hasError)
                _InlineError(message: snapshot.error.toString())
              else
                _ActivityDetails(
                  user: user,
                  activity: activity,
                  provider: provider,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityChips extends StatelessWidget {
  final AdminUserActivity activity;

  const _ActivityChips({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetricChip(
          icon: Icons.inventory_2_outlined,
          label: 'Orders',
          value: activity.orderCount.toString(),
        ),
        _MetricChip(
          icon: Icons.shopping_cart_outlined,
          label: 'Cart',
          value: activity.cartTotalItems.toString(),
        ),
        _MetricChip(
          icon: Icons.favorite_border,
          label: 'Wishlist',
          value: activity.wishlistCount.toString(),
        ),
        _MetricChip(
          icon: Icons.location_on_outlined,
          label: 'Addresses',
          value: activity.addressCount.toString(),
        ),
        if (activity.totalSpent >= 100000)
          _MetricChip(
            icon: Icons.workspace_premium_outlined,
            label: 'VIP',
            value: 'Rs ${activity.totalSpent.toStringAsFixed(0)}',
          ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.textLight),
          const SizedBox(width: 5),
          Text(
            '$label $value',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityDetails extends StatelessWidget {
  final AdminAppUser user;
  final AdminUserActivity activity;
  final AdminUsersProvider provider;

  const _ActivityDetails({
    required this.user,
    required this.activity,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = [
      _DetailBlock(
        title: 'Customer',
        icon: Icons.person_outline,
        children: [
          _DetailRow(label: 'Email', value: _fallback(user.email)),
          _DetailRow(label: 'Phone', value: _fallback(user.phoneNumber)),
          _DetailRow(label: 'Joined', value: _formatDate(user.createdAt)),
          _DetailRow(label: 'Last login', value: _formatDate(user.lastLoginAt)),
          _DetailRow(
            label: 'Access',
            value: user.isBlocked ? 'Blocked' : 'Active',
          ),
          const Divider(height: 20),
          _UserAccessAction(user: user, provider: provider),
        ],
      ),
      _DetailBlock(
        title: 'Orders',
        icon: Icons.receipt_long_outlined,
        footer: 'Total spent: Rs ${activity.totalSpent.toStringAsFixed(2)}',
        children: activity.orders.isEmpty
            ? const [_MutedText('No orders yet.')]
            : activity.orders
                  .take(4)
                  .map((order) => _OrderMiniTile(order: order))
                  .toList(growable: false),
      ),
      _DetailBlock(
        title: 'Cart',
        icon: Icons.shopping_cart_outlined,
        footer: 'Cart value: Rs ${activity.cartTotal.toStringAsFixed(2)}',
        children: activity.cartItems.isEmpty
            ? const [_MutedText('Cart is empty.')]
            : activity.cartItems
                  .take(4)
                  .map((item) => _CartMiniTile(item: item))
                  .toList(growable: false),
      ),
      _DetailBlock(
        title: 'Wishlist',
        icon: Icons.favorite_border,
        children: activity.wishlistItems.isEmpty
            ? const [_MutedText('No wishlist items.')]
            : activity.wishlistItems
                  .take(4)
                  .map((item) => _WishlistMiniTile(item: item))
                  .toList(growable: false),
      ),
      _DetailBlock(
        title: 'Addresses',
        icon: Icons.location_on_outlined,
        children: activity.addresses.isEmpty
            ? const [_MutedText('No saved addresses.')]
            : activity.addresses
                  .take(4)
                  .map((address) => _AddressMiniTile(address: address))
                  .toList(growable: false),
      ),
      _DetailBlock(
        title: 'Notifications',
        icon: Icons.notifications_none,
        footer: '${activity.unreadNotificationCount} unread',
        children: activity.notifications.isEmpty
            ? const [_MutedText('No notifications stored.')]
            : activity.notifications
                  .take(4)
                  .map(
                    (notification) =>
                        _NotificationMiniTile(notification: notification),
                  )
                  .toList(growable: false),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 860) {
          final width = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: blocks
                .map((block) => SizedBox(width: width, child: block))
                .toList(growable: false),
          );
        }

        return Column(
          children: blocks
              .map(
                (block) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: block,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _DetailBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? footer;

  const _DetailBlock({
    required this.title,
    required this.icon,
    required this.children,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
          if (footer != null) ...[
            const Divider(height: 20),
            Text(
              footer!,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderMiniTile extends StatelessWidget {
  final AdminOrder order;

  const _OrderMiniTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return _PlainTile(
      icon: Icons.inventory_2_outlined,
      iconColor: _statusColor(order.status),
      title:
          '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id} - ${order.status}',
      subtitle:
          '${_formatDate(order.createdAt)} | ${order.items.length} product types',
      trailing: 'Rs ${order.totalAmount.toStringAsFixed(0)}',
    );
  }
}

class _CartMiniTile extends StatelessWidget {
  final AdminCartItem item;

  const _CartMiniTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return _ProductTile(
      imageUrl: item.imageUrl,
      title: item.name,
      subtitle: '${item.brand} | Qty ${item.quantity}',
      trailing: 'Rs ${item.subtotal.toStringAsFixed(0)}',
    );
  }
}

class _WishlistMiniTile extends StatelessWidget {
  final AdminWishlistItem item;

  const _WishlistMiniTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return _ProductTile(
      imageUrl: item.imageUrl,
      title: item.name,
      subtitle: '${item.brand} | ${item.category}',
      trailing: 'Rs ${item.price.toStringAsFixed(0)}',
    );
  }
}

class _AddressMiniTile extends StatelessWidget {
  final AdminSavedAddress address;

  const _AddressMiniTile({required this.address});

  @override
  Widget build(BuildContext context) {
    return _PlainTile(
      icon: address.isDefault
          ? Icons.home_work_outlined
          : Icons.location_on_outlined,
      iconColor: address.isDefault ? AppColors.accent : AppColors.textLight,
      title: address.displayLabel,
      subtitle:
          '${_fallback(address.fullName)} | ${_fallback(address.phone)}\n${address.addressLine}',
    );
  }
}

class _NotificationMiniTile extends StatelessWidget {
  final AdminUserNotification notification;

  const _NotificationMiniTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return _PlainTile(
      icon: notification.isRead
          ? Icons.notifications_none
          : Icons.notifications_active_outlined,
      iconColor: notification.isRead ? AppColors.textLight : AppColors.warning,
      title: notification.title,
      subtitle: notification.subtitle,
      trailing: _formatDate(notification.createdAt),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String trailing;

  const _ProductTile({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 44,
              height: 44,
              color: AppColors.surface,
              child: imageUrl.trim().isEmpty
                  ? const Icon(Icons.watch_outlined, color: AppColors.textLight)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.watch_outlined,
                        color: AppColors.textLight,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            trailing,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? trailing;

  const _PlainTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(
              trailing!,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MutedText extends StatelessWidget {
  final String text;

  const _MutedText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: AppColors.textLight));
  }
}

class _RoleBadge extends StatelessWidget {
  final AdminAppUser user;

  const _RoleBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    final color = user.isAdmin ? AppColors.accent : AppColors.textLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        user.isAdmin ? 'Admin' : user.role,
        style: TextStyle(
          color: user.isAdmin ? AppColors.textDark : color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BlockedBadge extends StatelessWidget {
  const _BlockedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Blocked',
        style: TextStyle(
          color: AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _UserAccessAction extends StatelessWidget {
  final AdminAppUser user;
  final AdminUsersProvider provider;

  const _UserAccessAction({required this.user, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isUpdating = provider.isUpdating(user.id);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isUpdating
            ? null
            : () => provider.updateBlocked(user, !user.isBlocked),
        icon: isUpdating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                user.isBlocked
                    ? Icons.lock_open_outlined
                    : Icons.block_outlined,
              ),
        label: Text(user.isBlocked ? 'Unblock user' : 'Block user'),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (AdminOrderStatus.normalize(status)) {
    case AdminOrderStatus.packed:
      return const Color(0xFF7C3AED);
    case AdminOrderStatus.shipped:
      return AppColors.warning;
    case AdminOrderStatus.delivered:
      return AppColors.success;
    default:
      return const Color(0xFF2563EB);
  }
}

String _initialsFor(AdminAppUser user) {
  final source = user.name.isNotEmpty ? user.name : user.email;
  final pieces = source
      .trim()
      .split(RegExp(r'\s+'))
      .where((piece) => piece.isNotEmpty)
      .toList();

  if (pieces.isEmpty) {
    return 'U';
  }
  if (pieces.length == 1) {
    return pieces.first.substring(0, 1).toUpperCase();
  }
  return '${pieces[0][0]}${pieces[1][0]}'.toUpperCase();
}

String _contactLine(AdminAppUser user) {
  final phone = user.phoneNumber.isEmpty
      ? 'Phone not provided'
      : user.phoneNumber;
  final email = user.email.isEmpty ? 'No email stored' : user.email;
  return '$email | $phone';
}

String _fallback(String value) => value.trim().isEmpty ? 'Not provided' : value;

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'Date pending';
  }
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
