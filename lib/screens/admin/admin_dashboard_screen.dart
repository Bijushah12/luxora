import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_order.dart';
import '../../models/admin_product.dart';
import '../../providers/admin_dashboard_provider.dart';
import '../../services/admin_firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin/admin_empty_state.dart';
import '../../widgets/admin/admin_section.dart';

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
              _DashboardHero(stats: provider.stats),
              const SizedBox(height: 16),
              _StatsGrid(stats: provider.stats),
              const SizedBox(height: 16),
              _AnalyticsGrid(stats: provider.stats),
              const SizedBox(height: 22),
              _AlertsAndInventory(stats: provider.stats),
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
    final cards = [
      _TitanMetricCard(
        label: 'Revenue',
        value: 'Rs ${stats.totalRevenue.toStringAsFixed(0)}',
        icon: Icons.currency_rupee,
        color: AppColors.accent,
      ),
      _TitanMetricCard(
        label: 'Orders Today',
        value: stats.ordersTodayCount.toString(),
        icon: Icons.local_mall_outlined,
        color: const Color(0xFF2563EB),
      ),
      _TitanMetricCard(
        label: 'Watches',
        value: stats.productsCount.toString(),
        icon: Icons.watch_outlined,
        color: AppColors.primary,
      ),
      _TitanMetricCard(
        label: 'Low Stock',
        value: stats.lowStockProducts.length.toString(),
        icon: Icons.warning_amber_outlined,
        color: AppColors.warning,
      ),
      _TitanMetricCard(
        label: 'Customers',
        value: stats.usersCount.toString(),
        icon: Icons.people_outline,
        color: AppColors.success,
      ),
    ];

    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => cards[index],
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  final AdminDashboardStats stats;

  const _DashboardHero({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 860;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _MiniGoldLabel(
                    icon: Icons.storefront_outlined,
                    label: 'LUXORA RETAIL',
                  ),
                  const SizedBox(width: 10),
                  _MiniGoldLabel(
                    icon: Icons.verified_outlined,
                    label: '${stats.activeProductsCount} LIVE',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Storefront Home',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'A clean retail dashboard for watches, orders, inventory and premium customer activity.',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroPill(
                    icon: Icons.today_outlined,
                    label: '${stats.ordersTodayCount} orders today',
                  ),
                  _HeroPill(
                    icon: Icons.pending_actions_outlined,
                    label: '${stats.pendingOrdersCount} pending',
                  ),
                  _HeroPill(
                    icon: Icons.diamond_outlined,
                    label:
                        'Rs ${stats.luxuryRevenue.toStringAsFixed(0)} luxury',
                  ),
                ],
              ),
            ],
          );
          final commerce = _TitanCommercePanel(stats: stats);

          if (isWide) {
            return Row(
              children: [
                Expanded(child: copy),
                const SizedBox(width: 22),
                SizedBox(width: 390, child: commerce),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [copy, const SizedBox(height: 18), commerce],
          );
        },
      ),
    );
  }
}

class _TitanMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TitanMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 206,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
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

class _TitanCommercePanel extends StatelessWidget {
  final AdminDashboardStats stats;

  const _TitanCommercePanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 104,
                  height: 104,
                  color: AppColors.card,
                  child: stats.topSellingWatchImageUrl.trim().isEmpty
                      ? const Icon(
                          Icons.watch_outlined,
                          color: AppColors.accent,
                          size: 40,
                        )
                      : Image.network(
                          stats.topSellingWatchImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.watch_outlined,
                                color: AppColors.accent,
                                size: 40,
                              ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Best Performer',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stats.topSellingWatchName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stats.topSellingWatchQuantity == 0
                          ? 'Sales will appear here'
                          : '${stats.topSellingWatchQuantity} units sold',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CompactRetailMetric(
                  label: 'Budget',
                  value: 'Rs ${stats.budgetRevenue.toStringAsFixed(0)}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompactRetailMetric(
                  label: 'Luxury',
                  value: 'Rs ${stats.luxuryRevenue.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniGoldLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniGoldLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accent, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textDark, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
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

class _CompactRetailMetric extends StatelessWidget {
  final String label;
  final String value;

  const _CompactRetailMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _AnalyticsGrid extends StatelessWidget {
  final AdminDashboardStats stats;

  const _AnalyticsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;
        final children = [
          _SalesChartCard(title: 'Weekly Sales', points: stats.weeklySales),
          _SalesChartCard(title: 'Monthly Sales', points: stats.monthlySales),
          _LuxuryBudgetCard(stats: stats),
          _MetricBarCard(
            title: 'Category-wise Sales',
            icon: Icons.category_outlined,
            values: stats.categorySales,
          ),
          _MetricBarCard(
            title: 'Top Brands Performance',
            icon: Icons.workspace_premium_outlined,
            values: stats.brandSales,
          ),
        ];

        if (isWide) {
          return GridView.builder(
            itemCount: children.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 260,
            ),
            itemBuilder: (context, index) => children[index],
          );
        }

        return Column(
          children: children
              .map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SizedBox(height: 260, child: child),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _SalesChartCard extends StatelessWidget {
  final String title;
  final List<AdminChartPoint> points;

  const _SalesChartCard({required this.title, required this.points});

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: title,
      icon: Icons.show_chart_outlined,
      child: points.isEmpty
          ? const _MutedAnalyticsText('Sales data will appear after orders.')
          : _SalesBars(points: points),
    );
  }
}

class _SalesBars extends StatelessWidget {
  final List<AdminChartPoint> points;

  const _SalesBars({required this.points});

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<double>(
      0,
      (max, point) => point.value > max ? point.value : max,
    );
    return SizedBox(
      height: 174,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points
            .map(
              (point) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        point.value == 0
                            ? '0'
                            : '${(point.value / 1000).toStringAsFixed(0)}k',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Flexible(
                        child: FractionallySizedBox(
                          heightFactor: maxValue <= 0
                              ? 0.08
                              : (point.value / maxValue)
                                    .clamp(0.08, 1.0)
                                    .toDouble(),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        point.label,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _LuxuryBudgetCard extends StatelessWidget {
  final AdminDashboardStats stats;

  const _LuxuryBudgetCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.luxuryRevenue + stats.budgetRevenue;
    final luxuryShare = total <= 0 ? 0.0 : stats.luxuryRevenue / total;
    final budgetShare = total <= 0 ? 0.0 : stats.budgetRevenue / total;

    return _AnalyticsCard(
      title: 'Luxury vs Budget',
      icon: Icons.diamond_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SplitBar(
            label: 'Luxury',
            value: stats.luxuryRevenue,
            share: luxuryShare,
            color: AppColors.accent,
          ),
          const SizedBox(height: 18),
          _SplitBar(
            label: 'Budget',
            value: stats.budgetRevenue,
            share: budgetShare,
            color: const Color(0xFF2563EB),
          ),
          const Spacer(),
          Text(
            'Revenue split is calculated from sold watches and their category/price.',
            style: TextStyle(
              color: AppColors.textLight.withValues(alpha: 0.86),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitBar extends StatelessWidget {
  final String label;
  final double value;
  final double share;
  final Color color;

  const _SplitBar({
    required this.label,
    required this.value,
    required this.share,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              'Rs ${value.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: share.clamp(0, 1).toDouble(),
            minHeight: 12,
            backgroundColor: AppColors.surface,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MetricBarCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, double> values;

  const _MetricBarCard({
    required this.title,
    required this.icon,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.take(5).toList(growable: false);
    final maxValue = entries.fold<double>(
      0,
      (max, entry) => entry.value > max ? entry.value : max,
    );

    return _AnalyticsCard(
      title: title,
      icon: icon,
      child: entries.isEmpty
          ? const _MutedAnalyticsText(
              'Performance data will appear after sales.',
            )
          : Column(
              children: entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MetricBar(
                        label: entry.key,
                        value: entry.value,
                        maxValue: maxValue,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;

  const _MetricBar({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final share = maxValue <= 0
        ? 0.0
        : (value / maxValue).clamp(0.05, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              'Rs ${value.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: share,
            minHeight: 10,
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
          ),
        ),
      ],
    );
  }
}

class _AlertsAndInventory extends StatelessWidget {
  final AdminDashboardStats stats;

  const _AlertsAndInventory({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final alerts = _SmartAlertsPanel(alerts: stats.smartAlerts);
        final stock = _LowStockPanel(products: stats.lowStockProducts);
        if (constraints.maxWidth >= 860) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: alerts),
              const SizedBox(width: 14),
              Expanded(child: stock),
            ],
          );
        }
        return Column(children: [alerts, const SizedBox(height: 14), stock]);
      },
    );
  }
}

class _SmartAlertsPanel extends StatelessWidget {
  final List<AdminSmartAlert> alerts;

  const _SmartAlertsPanel({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return AdminSection(
      title: 'Smart Alerts',
      subtitle: 'New orders, demand spikes, and fulfillment signals',
      icon: Icons.notifications_active_outlined,
      child: Column(
        children: alerts
            .map((alert) => _AlertTile(alert: alert))
            .toList(growable: false),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final AdminSmartAlert alert;

  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _alertColor(alert.level);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(_alertIcon(alert.level), color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  alert.message,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _LowStockPanel extends StatelessWidget {
  final List<AdminProduct> products;

  const _LowStockPanel({required this.products});

  @override
  Widget build(BuildContext context) {
    return AdminSection(
      title: 'Low Stock Watches',
      subtitle: 'Inventory that needs restocking soon',
      icon: Icons.warning_amber_outlined,
      child: products.isEmpty
          ? const SizedBox(
              height: 164,
              child: AdminEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Inventory looks healthy',
                message: 'Low-stock watches will appear here.',
              ),
            )
          : Column(
              children: products
                  .map((product) => _LowStockTile(product: product))
                  .toList(growable: false),
            ),
    );
  }
}

class _LowStockTile extends StatelessWidget {
  final AdminProduct product;

  const _LowStockTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 46,
              height: 46,
              color: AppColors.surface,
              child: product.primaryImageUrl.trim().isEmpty
                  ? const Icon(Icons.watch_outlined, color: AppColors.textLight)
                  : Image.network(
                      product.primaryImageUrl,
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
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${product.brand} | ${product.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${product.stockQuantity} left',
            style: const TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _AnalyticsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MutedAnalyticsText extends StatelessWidget {
  final String text;

  const _MutedAnalyticsText(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textLight,
          fontWeight: FontWeight.w700,
        ),
      ),
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

Color _alertColor(String level) {
  switch (level) {
    case 'danger':
      return AppColors.error;
    case 'warning':
      return AppColors.warning;
    case 'info':
      return const Color(0xFF2563EB);
    default:
      return AppColors.success;
  }
}

IconData _alertIcon(String level) {
  switch (level) {
    case 'danger':
      return Icons.error_outline;
    case 'warning':
      return Icons.warning_amber_outlined;
    case 'info':
      return Icons.trending_up;
    default:
      return Icons.check_circle_outline;
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
