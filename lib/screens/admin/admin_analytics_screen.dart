import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_dashboard_provider.dart';
import '../../services/admin_firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin/admin_luxury_widgets.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;
        return AdminLuxuryBackground(
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: provider.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (provider.isLoading) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const _AnalyticsHero(),
                const SizedBox(height: 18),
                AdminResponsiveGrid(
                  minItemWidth: 240,
                  children: [
                    _AnalyticsMetric(
                      label: 'Revenue',
                      value: _compactCurrency(stats.totalRevenue),
                      icon: Icons.currency_rupee,
                      color: AppColors.accent,
                    ),
                    _AnalyticsMetric(
                      label: 'Orders',
                      value: stats.ordersCount.toString(),
                      icon: Icons.receipt_long_outlined,
                      color: const Color(0xFF60A5FA),
                    ),
                    _AnalyticsMetric(
                      label: 'Products',
                      value: stats.productsCount.toString(),
                      icon: Icons.watch_outlined,
                      color: const Color(0xFFA78BFA),
                    ),
                    _AnalyticsMetric(
                      label: 'Active Users',
                      value: stats.usersCount.toString(),
                      icon: Icons.people_outline,
                      color: AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 960;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _SalesGraph(points: stats.weeklySales),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 5,
                            child: _RevenueChart(
                              luxuryRevenue: stats.luxuryRevenue,
                              budgetRevenue: stats.budgetRevenue,
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _SalesGraph(points: stats.weeklySales),
                        const SizedBox(height: 14),
                        _RevenueChart(
                          luxuryRevenue: stats.luxuryRevenue,
                          budgetRevenue: stats.budgetRevenue,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 960;
                    final topWatches = _topWatchesFrom(stats);
                    final categoryPanel = _PerformancePanel(
                      title: 'Category Performance',
                      subtitle: 'Revenue by smartwatch category',
                      values: stats.categorySales,
                      icon: Icons.category_outlined,
                    );
                    final watchesPanel = _TopSellingPanel(watches: topWatches);

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: watchesPanel),
                          const SizedBox(width: 14),
                          Expanded(child: categoryPanel),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        watchesPanel,
                        const SizedBox(height: 14),
                        categoryPanel,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                _AiInsightsPanel(stats: stats),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnalyticsHero extends StatelessWidget {
  const _AnalyticsHero();

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return AdminGlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.auto_graph_outlined,
              color: AppColors.accent,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Luxury Sales Intelligence',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textInverse,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Real-time Firestore analytics powered by fl_chart, clean signals, and AI-style retail insights.',
                  style: TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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

class _AnalyticsMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return AdminGlassCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textInverse,
                    fontSize: 23,
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

class _SalesGraph extends StatelessWidget {
  final List<AdminChartPoint> points;

  const _SalesGraph({required this.points});

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];
    final maxY = points.fold<double>(
      0,
      (max, point) => point.value > max ? point.value : max,
    );

    return AdminGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            icon: Icons.show_chart_outlined,
            title: 'Sales Graph',
            subtitle: 'Weekly revenue movement',
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 280,
            child: points.isEmpty
                ? const _EmptyChart(
                    message: 'Sales graph will appear after orders.',
                  )
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY <= 0 ? 10 : maxY * 1.18,
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withValues(alpha: 0.08),
                          strokeWidth: 1,
                        ),
                      ),
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
                                    color: Color(0xFFD1D5DB),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: const LineTouchData(enabled: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppColors.accent,
                          barWidth: 4,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.accent.withValues(alpha: 0.16),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 700),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final double luxuryRevenue;
  final double budgetRevenue;

  const _RevenueChart({
    required this.luxuryRevenue,
    required this.budgetRevenue,
  });

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    final total = luxuryRevenue + budgetRevenue;
    final sections = total <= 0
        ? [
            PieChartSectionData(
              value: 1,
              color: Colors.white.withValues(alpha: 0.12),
              title: 'No data',
              radius: 78,
              titleStyle: TextStyle(
                color: AppColors.textInverse,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ]
        : [
            PieChartSectionData(
              value: luxuryRevenue,
              color: AppColors.accent,
              title: 'Luxury',
              radius: 82,
              titleStyle: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            PieChartSectionData(
              value: budgetRevenue,
              color: const Color(0xFF60A5FA),
              title: 'Budget',
              radius: 70,
              titleStyle: TextStyle(
                color: AppColors.textInverse,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ];

    return AdminGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            icon: Icons.donut_large_outlined,
            title: 'Revenue Chart',
            subtitle: 'Luxury vs budget split',
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 280,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 58,
                sectionsSpace: 3,
              ),
              swapAnimationDuration: const Duration(milliseconds: 700),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _LegendTile(
                  color: AppColors.accent,
                  label: 'Luxury',
                  value: _compactCurrency(luxuryRevenue),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LegendTile(
                  color: const Color(0xFF60A5FA),
                  label: 'Budget',
                  value: _compactCurrency(budgetRevenue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopSellingPanel extends StatelessWidget {
  final List<_TopWatchRow> watches;

  const _TopSellingPanel({required this.watches});

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return AdminGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            icon: Icons.workspace_premium_outlined,
            title: 'Top Selling Watches',
            subtitle: 'Best performers from recent order data',
          ),
          const SizedBox(height: 18),
          if (watches.isEmpty)
            const SizedBox(
              height: 220,
              child: _EmptyChart(
                message: 'Top sellers will appear after orders.',
              ),
            )
          else
            ...watches.map(
              (watch) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 52,
                        height: 52,
                        color: Colors.white.withValues(alpha: 0.08),
                        child: watch.imageUrl.isEmpty
                            ? Icon(
                                Icons.watch_outlined,
                                color: AppColors.accent,
                              )
                            : Image.network(
                                watch.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.watch_outlined,
                                      color: AppColors.accent,
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
                            watch.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textInverse,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${watch.quantity} units sold',
                            style: const TextStyle(
                              color: Color(0xFFD1D5DB),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _compactCurrency(watch.revenue),
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PerformancePanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Map<String, double> values;

  const _PerformancePanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    final entries = values.entries.take(6).toList(growable: false);
    final maxY = entries.fold<double>(
      0,
      (max, entry) => entry.value > max ? entry.value : max,
    );

    return AdminGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionHeader(icon: icon, title: title, subtitle: subtitle),
          const SizedBox(height: 18),
          SizedBox(
            height: 280,
            child: entries.isEmpty
                ? const _EmptyChart(
                    message: 'Category performance will appear after sales.',
                  )
                : BarChart(
                    BarChartData(
                      maxY: maxY <= 0 ? 10 : maxY * 1.18,
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withValues(alpha: 0.08),
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
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              final index = value.round();
                              if (index < 0 || index >= entries.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  entries[index].key,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFD1D5DB),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < entries.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: entries[i].value,
                                color: AppColors.accent,
                                width: 22,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ],
                          ),
                      ],
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 700),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AiInsightsPanel extends StatelessWidget {
  final AdminDashboardStats stats;

  const _AiInsightsPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    final insights = [
      if (stats.pendingOrdersCount > 0)
        'Prioritize ${stats.pendingOrdersCount} pending orders to protect premium delivery experience.',
      if (stats.lowStockProducts.isNotEmpty)
        '${stats.lowStockProducts.first.name} is low stock. Restock before the next campaign.',
      if (stats.topSellingWatchQuantity > 0)
        '${stats.topSellingWatchName} is the lead seller. Feature it in homepage banners and push offers.',
      if (stats.ordersTodayCount == 0)
        'No orders today yet. Consider a targeted coupon for wishlist users.',
    ];

    return AdminGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            icon: Icons.auto_awesome_outlined,
            title: 'AI Sales Insights',
            subtitle: 'Actionable retail recommendations from current signals',
          ),
          const SizedBox(height: 18),
          ...insights
              .take(4)
              .map(
                (insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.bolt_outlined,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          insight,
                          style: const TextStyle(
                            color: Color(0xFFE5E7EB),
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _LegendTile extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendTile({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textInverse,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String message;

  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFD1D5DB),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TopWatchRow {
  final String name;
  final String imageUrl;
  final int quantity;
  final double revenue;

  const _TopWatchRow({
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.revenue,
  });
}

List<_TopWatchRow> _topWatchesFrom(AdminDashboardStats stats) {
  final rows = <String, _TopWatchAccumulator>{};

  for (final order in stats.recentOrders) {
    for (final item in order.items) {
      final key = item.name.trim();
      if (key.isEmpty) {
        continue;
      }
      rows.putIfAbsent(
        key,
        () => _TopWatchAccumulator(name: key, imageUrl: item.imageUrl),
      );
      rows[key]!
        ..quantity += item.quantity
        ..revenue += item.subtotal;
    }
  }

  final values = rows.values.toList()
    ..sort((a, b) => b.quantity.compareTo(a.quantity));
  if (values.isEmpty && stats.topSellingWatchQuantity > 0) {
    return [
      _TopWatchRow(
        name: stats.topSellingWatchName,
        imageUrl: stats.topSellingWatchImageUrl,
        quantity: stats.topSellingWatchQuantity,
        revenue: 0,
      ),
    ];
  }

  return values
      .take(5)
      .map(
        (item) => _TopWatchRow(
          name: item.name,
          imageUrl: item.imageUrl,
          quantity: item.quantity,
          revenue: item.revenue,
        ),
      )
      .toList(growable: false);
}

class _TopWatchAccumulator {
  final String name;
  final String imageUrl;
  int quantity = 0;
  double revenue = 0;

  _TopWatchAccumulator({required this.name, required this.imageUrl});
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
