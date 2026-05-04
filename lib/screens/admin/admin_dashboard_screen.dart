import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_order.dart';
import '../../providers/admin_dashboard_provider.dart';
import '../../services/admin_firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin/admin_empty_state.dart';
import '../../widgets/admin/admin_section.dart';
import '../../widgets/admin/admin_stat_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: provider.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              if (provider.isLoading && provider.stats.ordersCount == 0)
                const LinearProgressIndicator(minHeight: 3),
              if (provider.errorMessage != null) ...[
                _ErrorStrip(
                  message: provider.errorMessage!,
                  onRetry: provider.load,
                ),
                const SizedBox(height: 16),
              ],
              _StatsGrid(stats: provider.stats),
              const SizedBox(height: 22),
              _CustomerDataGrid(stats: provider.stats),
              const SizedBox(height: 22),
              AdminSection(
                title: 'Recent Orders',
                subtitle: 'Latest customer purchases from Firestore',
                icon: Icons.receipt_long_outlined,
                child: provider.stats.recentOrders.isEmpty
                    ? const SizedBox(
                        height: 280,
                        child: AdminEmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: 'No orders yet',
                          message:
                              'Orders created in the orders collection will appear here.',
                        ),
                      )
                    : Column(
                        children: provider.stats.recentOrders
                            .map((order) => _RecentOrderTile(order: order))
                            .toList(growable: false),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AdminDashboardStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 580
            ? 2
            : 1;

        final cards = [
          AdminStatCard(
            label: 'Total Revenue',
            value: 'Rs ${stats.totalRevenue.toStringAsFixed(0)}',
            icon: Icons.currency_rupee,
            color: AppColors.success,
          ),
          AdminStatCard(
            label: 'Registered Users',
            value: stats.usersCount.toString(),
            icon: Icons.people_outline,
            color: const Color(0xFF2563EB),
          ),
          AdminStatCard(
            label: 'Orders',
            value: stats.ordersCount.toString(),
            icon: Icons.inventory_2_outlined,
            color: AppColors.warning,
          ),
          AdminStatCard(
            label: 'Pending Orders',
            value: stats.pendingOrdersCount.toString(),
            icon: Icons.pending_actions_outlined,
            color: const Color(0xFF7C3AED),
          ),
          AdminStatCard(
            label: 'Products',
            value: stats.productsCount.toString(),
            icon: Icons.watch_outlined,
            color: const Color(0xFF0891B2),
          ),
          AdminStatCard(
            label: 'Active Products',
            value: stats.activeProductsCount.toString(),
            icon: Icons.verified_outlined,
            color: AppColors.success,
          ),
        ];

        return GridView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: constraints.maxWidth >= 580 ? 112 : 108,
          ),
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }
}

class _CustomerDataGrid extends StatelessWidget {
  final AdminDashboardStats stats;

  const _CustomerDataGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return AdminSection(
      title: 'Customer Data',
      subtitle: 'Live cart, wishlist, and address data stored by users',
      icon: Icons.dataset_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 680;
          final cards = [
            _DataMetric(
              label: 'Cart Items',
              value: stats.cartItemsCount.toString(),
              icon: Icons.shopping_cart_outlined,
              color: const Color(0xFF2563EB),
            ),
            _DataMetric(
              label: 'Wishlist Items',
              value: stats.wishlistItemsCount.toString(),
              icon: Icons.favorite_border,
              color: AppColors.error,
            ),
            _DataMetric(
              label: 'Saved Addresses',
              value: stats.addressesCount.toString(),
              icon: Icons.location_on_outlined,
              color: AppColors.accent,
            ),
          ];

          return GridView.builder(
            itemCount: cards.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 3 : 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 82,
            ),
            itemBuilder: (context, index) => cards[index],
          );
        },
      ),
    );
  }
}

class _DataMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DataMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final AdminOrder order;

  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _statusColor(order.status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: _statusColor(order.status),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.customerDisplayName} | ${_formatDate(order.createdAt)}',
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
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs ${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.status,
                style: TextStyle(
                  color: _statusColor(order.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorStrip extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStrip({required this.message, required this.onRetry});

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
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (AdminOrderStatus.normalize(status)) {
    case AdminOrderStatus.shipped:
      return AppColors.warning;
    case AdminOrderStatus.delivered:
      return AppColors.success;
    default:
      return const Color(0xFF2563EB);
  }
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'Date pending';
  }
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
