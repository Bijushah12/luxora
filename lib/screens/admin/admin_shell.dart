import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_auth_provider.dart';
import '../../theme/app_colors.dart';
import 'admin_analytics_screen.dart';
import 'admin_coupons_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_users_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    _AdminDestination(
      label: 'Dashboard',
      subtitle: 'Luxury storefront pulse and AI sales insights',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    _AdminDestination(
      label: 'Products',
      subtitle: 'Manage watch catalog, stock, images and tags',
      icon: Icons.watch_outlined,
      selectedIcon: Icons.watch,
    ),
    _AdminDestination(
      label: 'Orders',
      subtitle: 'Track fulfillment, delivery flow and order details',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
    ),
    _AdminDestination(
      label: 'Accounts',
      subtitle: 'Customers, admins, activity and access control',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    _AdminDestination(
      label: 'Analytics',
      subtitle: 'fl_chart revenue graphs, category performance and insights',
      icon: Icons.auto_graph_outlined,
      selectedIcon: Icons.auto_graph,
    ),
    _AdminDestination(
      label: 'Coupons',
      subtitle: 'Create offers, limits, expiry and premium campaign coupons',
      icon: Icons.confirmation_number_outlined,
      selectedIcon: Icons.confirmation_number,
    ),
    _AdminDestination(
      label: 'Notifications',
      subtitle: 'Queue push campaigns and customer engagement messages',
      icon: Icons.notifications_active_outlined,
      selectedIcon: Icons.notifications_active,
    ),
    _AdminDestination(
      label: 'Settings',
      subtitle: 'Storefront categories, brands, banners and discounts',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  static const _pages = [
    AdminDashboardScreen(),
    AdminProductsScreen(),
    AdminOrdersScreen(),
    AdminUsersScreen(),
    AdminAnalyticsScreen(),
    AdminCouponsScreen(),
    AdminNotificationsScreen(),
    AdminSettingsScreen(),
  ];

  void _selectDestination(int index, {bool closeDrawer = false}) {
    setState(() => _selectedIndex = index);
    if (closeDrawer) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;

        if (isWide) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            body: Row(
              children: [
                SizedBox(
                  width: 282,
                  child: _AdminSidebar(
                    selectedIndex: _selectedIndex,
                    onSelected: _selectDestination,
                  ),
                ),
                Expanded(
                  child: _AdminPageFrame(
                    destination: _destinations[_selectedIndex],
                    child: _pages[_selectedIndex],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.primary,
          drawerEnableOpenDragGesture: true,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textInverse,
            leading: Builder(
              builder: (context) {
                return IconButton(
                  tooltip: 'Open menu',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu, color: AppColors.accent),
                );
              },
            ),
            title: Text(
              _destinations[_selectedIndex].label,
              style: const TextStyle(color: AppColors.textInverse),
            ),
            actions: [
              IconButton(
                tooltip: 'Logout',
                onPressed: () => context.read<AdminAuthProvider>().signOut(),
                icon: const Icon(Icons.logout, color: AppColors.accent),
              ),
            ],
          ),
          drawer: Drawer(
            child: _AdminSidebar(
              selectedIndex: _selectedIndex,
              onSelected: (index) =>
                  _selectDestination(index, closeDrawer: true),
            ),
          ),
          body: _AdminPageFrame(
            destination: _destinations[_selectedIndex],
            showTitle: false,
            child: _pages[_selectedIndex],
          ),
        );
      },
    );
  }
}

class _AdminPageFrame extends StatelessWidget {
  final _AdminDestination destination;
  final Widget child;
  final bool showTitle;

  const _AdminPageFrame({
    required this.destination,
    required this.child,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
            Container(
              height: 86,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                color: AppColors.primary,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textInverse,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  _HeaderChip(
                    icon: Icons.cloud_done_outlined,
                    label: 'Live Firestore',
                  ),
                  const SizedBox(width: 10),
                  _HeaderChip(icon: Icons.calendar_today, label: _todayLabel()),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<AdminAuthProvider>().signOut(),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ),
          if (showTitle)
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
              child: Text(
                destination.subtitle,
                style: const TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accent, size: 17),
          const SizedBox(width: 7),
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

String _todayLabel() {
  final now = DateTime.now();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[now.month - 1]} ${now.day}, ${now.year}';
}

class _LuxoraLogo extends StatelessWidget {
  final double markSize;
  final String subtitle;
  final Color markColor;
  final Color textColor;
  final Color subtitleColor;
  final double titleSize;
  final double subtitleSize;

  const _LuxoraLogo({
    required this.markSize,
    required this.titleSize,
    required this.subtitle,
    required this.subtitleSize,
    required this.markColor,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: markSize,
          child: CustomPaint(painter: _LuxoraMarkPainter(markColor)),
        ),
        SizedBox(width: markSize * 0.22),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LUXORA',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LuxoraMarkPainter extends CustomPainter {
  final Color color;

  const _LuxoraMarkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final crown = Path()
      ..moveTo(size.width * 0.18, size.height * 0.42)
      ..lineTo(size.width * 0.08, size.height * 0.18)
      ..lineTo(size.width * 0.34, size.height * 0.32)
      ..lineTo(size.width * 0.50, size.height * 0.05)
      ..lineTo(size.width * 0.66, size.height * 0.32)
      ..lineTo(size.width * 0.92, size.height * 0.18)
      ..lineTo(size.width * 0.82, size.height * 0.42);
    canvas.drawPath(crown, stroke);
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.56),
      size.width * 0.31,
      stroke,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'L',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.34,
          fontWeight: FontWeight.w900,
          fontFamily: 'Times New Roman',
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(size.width * 0.38, size.height * 0.39));
  }

  @override
  bool shouldRepaint(_LuxoraMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _AdminSidebar({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AdminAuthProvider>().user;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        border: Border(right: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              child: const _LuxoraLogo(
                markSize: 36,
                titleSize: 16,
                subtitle: 'Premium Admin',
                subtitleSize: 11,
                markColor: AppColors.accent,
                textColor: AppColors.textInverse,
                subtitleColor: AppColors.accent,
              ),
            ),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _AdminShellState._destinations.length,
                itemBuilder: (context, index) {
                  final destination = _AdminShellState._destinations[index];
                  final selected = selectedIndex == index;

                  return _SidebarTile(
                    destination: destination,
                    selected: selected,
                    onTap: () => onSelected(index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.accent,
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        user?.email ?? 'Admin',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final _AdminDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 7),
        decoration: BoxDecoration(
          color: widget.selected
              ? AppColors.accent.withValues(alpha: 0.16)
              : _hovering
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.selected
                ? AppColors.accent.withValues(alpha: 0.28)
                : Colors.transparent,
          ),
        ),
        child: ListTile(
          dense: true,
          minLeadingWidth: 24,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: Icon(
            widget.selected
                ? widget.destination.selectedIcon
                : widget.destination.icon,
            color: active ? AppColors.accent : const Color(0xFFD1D5DB),
          ),
          title: Text(
            widget.destination.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? AppColors.textInverse : const Color(0xFFD1D5DB),
              fontWeight: widget.selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

class _AdminDestination {
  final String label;
  final String subtitle;
  final IconData icon;
  final IconData selectedIcon;

  const _AdminDestination({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selectedIcon,
  });
}
