import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_auth_provider.dart';
import '../../theme/app_colors.dart';
import 'admin_dashboard_screen.dart';
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
      subtitle: 'Live store pulse and smart sales insights',
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
      label: 'Users',
      subtitle: 'Customer activity, VIP value and access control',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
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
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                SizedBox(
                  width: 268,
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
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldBg,
            title: Text(_destinations[_selectedIndex].label),
            actions: [
              IconButton(
                tooltip: 'Logout',
                onPressed: () => context.read<AdminAuthProvider>().signOut(),
                icon: const Icon(Icons.logout),
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
              decoration: const BoxDecoration(
                color: AppColors.scaffoldBg,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
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
              color: AppColors.scaffoldBg,
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
              child: Text(
                destination.subtitle,
                style: const TextStyle(
                  color: AppColors.textLight,
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
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

class _AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _AdminSidebar({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AdminAuthProvider>().user;

    return Container(
      color: AppColors.primary,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.watch_outlined,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LUXORA',
                          style: TextStyle(
                            color: AppColors.textInverse,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Admin',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      selected: selected,
                      selectedTileColor: AppColors.accent.withValues(
                        alpha: 0.16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: Icon(
                        selected ? destination.selectedIcon : destination.icon,
                        color: selected
                            ? AppColors.accent
                            : const Color(0xFFD1D5DB),
                      ),
                      title: Text(
                        destination.label,
                        style: TextStyle(
                          color: selected
                              ? AppColors.textInverse
                              : const Color(0xFFD1D5DB),
                          fontWeight: selected
                              ? FontWeight.w900
                              : FontWeight.w700,
                        ),
                      ),
                      onTap: () => onSelected(index),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
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
