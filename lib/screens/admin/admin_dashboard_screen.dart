import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_order.dart';
import '../../models/admin_product.dart';
import '../../providers/admin_dashboard_provider.dart';
import '../../services/admin_firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin/admin_empty_state.dart';
import '../../widgets/admin/admin_luxury_widgets.dart';

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
        final stats = provider.stats;

        return AdminLuxuryBackground(
          padding: EdgeInsets.zero,
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: provider.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              children: [
                if (provider.isLoading && stats.ordersCount == 0) ...[
                  const _DashboardLoadingBar(),
                  const SizedBox(height: 16),
                ],
                if (provider.errorMessage != null) ...[
                  _ErrorStrip(
                    message: provider.errorMessage!,
                    onRetry: provider.load,
                  ),
                  const SizedBox(height: 16),
                ],
                _DashboardHero(stats: stats),
                const SizedBox(height: 18),
                _MetricGrid(stats: stats),
                const SizedBox(height: 18),
                _CommandLayout(stats: stats),
                const SizedBox(height: 18),
                _MarketLayout(stats: stats),
                const SizedBox(height: 18),
                _ActionLayout(stats: stats),
                const SizedBox(height: 18),
                _RecentOrdersPanel(orders: stats.recentOrders),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardLoadingBar extends StatelessWidget {
  const _DashboardLoadingBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: const LinearProgressIndicator(
        minHeight: 4,
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final intro = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroBadge(),
              const SizedBox(height: 18),
              const Text(
                'Luxora Admin Home',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textInverse,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'A premium command center for orders, revenue, catalog health, and customer activity.',
                style: TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroChip(
                    icon: Icons.today_outlined,
                    label: '${stats.ordersTodayCount} today',
                  ),
                  _HeroChip(
                    icon: Icons.pending_actions_outlined,
                    label: '${stats.pendingOrdersCount} pending',
                  ),
                  _HeroChip(
                    icon: Icons.inventory_2_outlined,
                    label: '${stats.activeProductsCount} live watches',
                  ),
                ],
              ),
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: intro),
                const SizedBox(width: 24),
                SizedBox(width: 410, child: _TopWatchSpotlight(stats: stats)),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              intro,
              const SizedBox(height: 22),
              _TopWatchSpotlight(stats: stats),
            ],
          );
        },
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, color: AppColors.accent, size: 17),
          SizedBox(width: 8),
          Text(
            'LUXORA RETAIL OPERATIONS',
            style: TextStyle(
              color: AppColors.textInverse,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accent, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textInverse,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopWatchSpotlight extends StatelessWidget {
  final AdminDashboardStats stats;

  const _TopWatchSpotlight({required this.stats});

  @override
  Widget build(BuildContext context) {
    final imageUrl = stats.topSellingWatchImageUrl.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 126,
              height: 126,
              color: AppColors.scaffoldBg,
              child: imageUrl.isEmpty
                  ? const Icon(
                      Icons.watch_outlined,
                      color: AppColors.accent,
                      size: 46,
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.watch_outlined,
                        color: AppColors.accent,
                        size: 46,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
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
                    color: AppColors.textInverse,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stats.topSellingWatchQuantity == 0
                      ? 'Sales data will appear here'
                      : '${stats.topSellingWatchQuantity} units sold',
                  style: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _SpotlightMiniMetric(
                        label: 'Luxury',
                        value: _compactCurrency(stats.luxuryRevenue),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SpotlightMiniMetric(
                        label: 'Budget',
                        value: _compactCurrency(stats.budgetRevenue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightMiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _SpotlightMiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textInverse,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final AdminDashboardStats stats;

  const _MetricGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final completionRate = stats.ordersCount == 0
        ? 0
        : (((stats.ordersCount - stats.pendingOrdersCount) /
                      stats.ordersCount) *
                  100)
              .round();
    final activeRate = stats.productsCount == 0
        ? 0
        : ((stats.activeProductsCount / stats.productsCount) * 100).round();

    final metrics = [
      _MetricData(
        label: 'Total Revenue',
        value: _compactCurrency(stats.totalRevenue),
        helper: '${stats.ordersCount} total orders',
        icon: Icons.currency_rupee,
        color: AppColors.accent,
      ),
      _MetricData(
        label: 'Orders Today',
        value: stats.ordersTodayCount.toString(),
        helper: '${stats.pendingOrdersCount} pending now',
        icon: Icons.local_mall_outlined,
        color: const Color(0xFF2563EB),
      ),
      _MetricData(
        label: 'Fulfillment',
        value: '$completionRate%',
        helper: 'Packed, shipped or delivered',
        icon: Icons.task_alt_outlined,
        color: AppColors.success,
      ),
      _MetricData(
        label: 'Catalog Live',
        value: '${stats.activeProductsCount}/${stats.productsCount}',
        helper: '$activeRate% active watches',
        icon: Icons.watch_outlined,
        color: AppColors.primary,
      ),
      _MetricData(
        label: 'Customers',
        value: stats.usersCount.toString(),
        helper: '${stats.cartItemsCount} cart items',
        icon: Icons.people_outline,
        color: const Color(0xFF7C3AED),
      ),
      _MetricData(
        label: 'Low Stock',
        value: stats.lowStockProducts.length.toString(),
        helper: 'Needs restock attention',
        icon: Icons.warning_amber_outlined,
        color: AppColors.warning,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1120
            ? 3
            : width >= 720
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 118,
          ),
          itemBuilder: (context, index) => _MetricCard(data: metrics[index]),
        );
      },
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final String helper;
  final IconData icon;
  final Color color;

  const _MetricData({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    required this.color,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.color, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
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
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.helper,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

class _CommandLayout extends StatelessWidget {
  final AdminDashboardStats stats;

  const _CommandLayout({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 960) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _SalesPerformancePanel(stats: stats)),
              const SizedBox(width: 14),
              Expanded(flex: 5, child: _StoreHealthPanel(stats: stats)),
            ],
          );
        }

        return Column(
          children: [
            _SalesPerformancePanel(stats: stats),
            const SizedBox(height: 14),
            _StoreHealthPanel(stats: stats),
          ],
        );
      },
    );
  }
}

class _SalesPerformancePanel extends StatelessWidget {
  final AdminDashboardStats stats;

  const _SalesPerformancePanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            icon: Icons.show_chart_outlined,
            title: 'Sales Performance',
            subtitle: 'Weekly revenue movement and six month trend',
          ),
          const SizedBox(height: 18),
          SizedBox(height: 210, child: _SalesBars(points: stats.weeklySales)),
          const SizedBox(height: 18),
          _MonthTrend(points: stats.monthlySales),
        ],
      ),
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

    if (points.isEmpty) {
      return const _SoftEmptyState(
        icon: Icons.bar_chart_outlined,
        title: 'No weekly sales yet',
        message: 'Revenue bars will populate after orders are placed.',
      );
    }

    return BarChart(
      BarChartData(
        maxY: maxValue <= 0 ? 10 : maxValue * 1.18,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border.withValues(alpha: 0.75),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    points[index].label,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: points[i].value,
                  color: AppColors.accent,
                  width: 18,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
        ],
      ),
      swapAnimationDuration: const Duration(milliseconds: 700),
    );
  }
}

class _MonthTrend extends StatelessWidget {
  final List<AdminChartPoint> points;

  const _MonthTrend({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = points.fold<double>(0, (sum, point) => sum + point.value);
    final maxValue = points.fold<double>(
      0,
      (max, point) => point.value > max ? point.value : max,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Six Month Revenue',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _compactCurrency(total),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SlimBar(
                label: point.label,
                value: point.value,
                share: maxValue <= 0 ? 0 : point.value / maxValue,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreHealthPanel extends StatelessWidget {
  final AdminDashboardStats stats;

  const _StoreHealthPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    final fulfillment = stats.ordersCount == 0
        ? 0.0
        : ((stats.ordersCount - stats.pendingOrdersCount) / stats.ordersCount)
              .clamp(0.0, 1.0)
              .toDouble();
    final activeCatalog = stats.productsCount == 0
        ? 0.0
        : (stats.activeProductsCount / stats.productsCount)
              .clamp(0.0, 1.0)
              .toDouble();
    final customerSignal = stats.usersCount == 0
        ? 0.0
        : ((stats.cartItemsCount + stats.wishlistItemsCount) / stats.usersCount)
              .clamp(0.0, 1.0)
              .toDouble();

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            icon: Icons.insights_outlined,
            title: 'Store Health',
            subtitle: 'Operational signals that need admin attention',
          ),
          const SizedBox(height: 18),
          _HealthProgress(
            label: 'Fulfillment Flow',
            value: fulfillment,
            helper:
                '${stats.pendingOrdersCount} pending of ${stats.ordersCount}',
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          _HealthProgress(
            label: 'Live Catalog',
            value: activeCatalog,
            helper:
                '${stats.activeProductsCount} active of ${stats.productsCount}',
            color: AppColors.accent,
          ),
          const SizedBox(height: 16),
          _HealthProgress(
            label: 'Customer Intent',
            value: customerSignal,
            helper:
                '${stats.cartItemsCount} carts + ${stats.wishlistItemsCount} wishlist',
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 18),
          _CustomerSignalGrid(stats: stats),
        ],
      ),
    );
  }
}

class _HealthProgress extends StatelessWidget {
  final String label;
  final double value;
  final String helper;
  final Color color;

  const _HealthProgress({
    required this.label,
    required this.value,
    required this.helper,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: value,
            color: color,
            backgroundColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          helper,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CustomerSignalGrid extends StatelessWidget {
  final AdminDashboardStats stats;

  const _CustomerSignalGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SignalData(
        label: 'Cart',
        value: stats.cartItemsCount.toString(),
        icon: Icons.shopping_cart_outlined,
      ),
      _SignalData(
        label: 'Wishlist',
        value: stats.wishlistItemsCount.toString(),
        icon: Icons.favorite_border,
      ),
      _SignalData(
        label: 'Address',
        value: stats.addressesCount.toString(),
        icon: Icons.location_on_outlined,
      ),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: item == items.last ? 0 : 10),
                child: _SignalTile(data: item),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _SignalData {
  final String label;
  final String value;
  final IconData icon;

  const _SignalData({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _SignalTile extends StatelessWidget {
  final _SignalData data;

  const _SignalTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: AppColors.accent, size: 20),
          const SizedBox(height: 8),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketLayout extends StatelessWidget {
  final AdminDashboardStats stats;

  const _MarketLayout({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;
        final children = [
          _RevenueSplitPanel(stats: stats),
          _RankingPanel(
            title: 'Category Sales',
            subtitle: 'Top categories by revenue',
            icon: Icons.category_outlined,
            values: stats.categorySales,
          ),
          _RankingPanel(
            title: 'Brand Performance',
            subtitle: 'Brands currently driving revenue',
            icon: Icons.workspace_premium_outlined,
            values: stats.brandSales,
          ),
        ];

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                Expanded(child: children[index]),
                if (index != children.length - 1) const SizedBox(width: 14),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1) const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}

class _RevenueSplitPanel extends StatelessWidget {
  final AdminDashboardStats stats;

  const _RevenueSplitPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.luxuryRevenue + stats.budgetRevenue;
    final luxuryShare = total <= 0 ? 0.0 : stats.luxuryRevenue / total;
    final budgetShare = total <= 0 ? 0.0 : stats.budgetRevenue / total;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            icon: Icons.diamond_outlined,
            title: 'Revenue Mix',
            subtitle: 'Luxury and budget contribution',
          ),
          const SizedBox(height: 18),
          _SplitMetric(
            label: 'Luxury Collection',
            value: stats.luxuryRevenue,
            share: luxuryShare,
            color: AppColors.accent,
          ),
          const SizedBox(height: 18),
          _SplitMetric(
            label: 'Budget Collection',
            value: stats.budgetRevenue,
            share: budgetShare,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Split Revenue',
                  style: TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _compactCurrency(total),
                  style: const TextStyle(
                    color: AppColors.textInverse,
                    fontSize: 22,
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

class _SplitMetric extends StatelessWidget {
  final String label;
  final double value;
  final double share;
  final Color color;

  const _SplitMetric({
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              _compactCurrency(value),
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            minHeight: 11,
            value: share.clamp(0.0, 1.0).toDouble(),
            color: color,
            backgroundColor: AppColors.surface,
          ),
        ),
      ],
    );
  }
}

class _RankingPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Map<String, double> values;

  const _RankingPanel({
    required this.title,
    required this.subtitle,
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

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(icon: icon, title: title, subtitle: subtitle),
          const SizedBox(height: 18),
          if (entries.isEmpty)
            const SizedBox(
              height: 190,
              child: _SoftEmptyState(
                icon: Icons.leaderboard_outlined,
                title: 'No sales ranking',
                message: 'Ranking will update when orders are available.',
              ),
            )
          else
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _SlimBar(
                  label: entry.key,
                  value: entry.value,
                  share: maxValue <= 0 ? 0 : entry.value / maxValue,
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SlimBar extends StatelessWidget {
  final String label;
  final double value;
  final double share;
  final Color color;

  const _SlimBar({
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              _compactCurrency(value),
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
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: share.clamp(0.04, 1.0).toDouble(),
            minHeight: 9,
            color: color,
            backgroundColor: AppColors.surface,
          ),
        ),
      ],
    );
  }
}

class _ActionLayout extends StatelessWidget {
  final AdminDashboardStats stats;

  const _ActionLayout({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _SmartAlertsPanel(alerts: stats.smartAlerts)),
              const SizedBox(width: 14),
              Expanded(
                child: _InventoryPanel(products: stats.lowStockProducts),
              ),
            ],
          );
        }

        return Column(
          children: [
            _SmartAlertsPanel(alerts: stats.smartAlerts),
            const SizedBox(height: 14),
            _InventoryPanel(products: stats.lowStockProducts),
          ],
        );
      },
    );
  }
}

class _SmartAlertsPanel extends StatelessWidget {
  final List<AdminSmartAlert> alerts;

  const _SmartAlertsPanel({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            icon: Icons.notifications_active_outlined,
            title: 'Smart Alerts',
            subtitle: 'Priority signals from store operations',
          ),
          const SizedBox(height: 18),
          ...alerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AlertTile(alert: alert),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_alertIcon(alert.level), color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  alert.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
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

class _InventoryPanel extends StatelessWidget {
  final List<AdminProduct> products;

  const _InventoryPanel({required this.products});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            icon: Icons.inventory_2_outlined,
            title: 'Inventory Watchlist',
            subtitle: 'Low stock products that need restocking soon',
          ),
          const SizedBox(height: 18),
          if (products.isEmpty)
            const SizedBox(
              height: 194,
              child: AdminEmptyState(
                icon: Icons.verified_outlined,
                title: 'Inventory looks healthy',
                message: 'Low-stock watches will appear here.',
              ),
            )
          else
            ...products.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InventoryTile(product: product),
              ),
            ),
        ],
      ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  final AdminProduct product;

  const _InventoryTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.primaryImageUrl.trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 50,
              height: 50,
              color: AppColors.surface,
              child: imageUrl.isEmpty
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
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
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
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '${product.stockQuantity} left',
              style: const TextStyle(
                color: AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentOrdersPanel extends StatelessWidget {
  final List<AdminOrder> orders;

  const _RecentOrdersPanel({required this.orders});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            icon: Icons.receipt_long_outlined,
            title: 'Recent Orders',
            subtitle: 'Latest purchases flowing in from Firestore',
          ),
          const SizedBox(height: 18),
          if (orders.isEmpty)
            const SizedBox(
              height: 260,
              child: AdminEmptyState(
                icon: Icons.local_mall_outlined,
                title: 'No orders yet',
                message: 'Orders created in Firestore will appear here.',
              ),
            )
          else
            ...orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RecentOrderTile(order: order),
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
    final statusColor = _statusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final leading = Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: statusColor),
          );
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${_shortOrderId(order.id)}',
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
          final amount = Column(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Text(
                _fullCurrency(order.totalAmount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              _StatusBadge(status: order.status, color: statusColor),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    leading,
                    const SizedBox(width: 12),
                    Expanded(child: title),
                  ],
                ),
                const SizedBox(height: 12),
                amount,
              ],
            );
          }

          return Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(child: title),
              const SizedBox(width: 16),
              amount,
            ],
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        AdminOrderStatus.normalize(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PanelHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.glassShadow,
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SoftEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _SoftEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textLight, size: 36),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
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
        borderRadius: BorderRadius.circular(14),
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

String _shortOrderId(String id) {
  return id.length > 8 ? id.substring(0, 8) : id;
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'Date pending';
  }
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _compactCurrency(double value) {
  final absolute = value.abs();
  if (absolute >= 10000000) {
    return 'Rs ${(value / 10000000).toStringAsFixed(1)}Cr';
  }
  if (absolute >= 100000) {
    return 'Rs ${(value / 100000).toStringAsFixed(1)}L';
  }
  if (absolute >= 1000) {
    return 'Rs ${(value / 1000).toStringAsFixed(1)}K';
  }
  return 'Rs ${value.toStringAsFixed(0)}';
}

String _fullCurrency(double value) {
  return 'Rs ${value.toStringAsFixed(2)}';
}
