import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'wishlist_screen.dart';
import 'cart_screen.dart';
import 'offers_screen.dart';
import 'profile_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/chatbot_launcher.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const WishlistScreen(),
    const CartScreen(),
    const OffersScreen(),
    const ProfileScreen(),
  ];

  static const _destinations = [
    _UserDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    _UserDestination(
      label: 'Wishlist',
      icon: Icons.favorite_border,
      selectedIcon: Icons.favorite,
    ),
    _UserDestination(
      label: 'Cart',
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
    ),
    _UserDestination(
      label: 'Offers',
      icon: Icons.local_offer_outlined,
      selectedIcon: Icons.local_offer,
    ),
    _UserDestination(
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 720;
        final extendedRail = constraints.maxWidth >= 1080;

        if (useRail) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  extended: extendedRail,
                  backgroundColor: AppColors.scaffoldBg,
                  selectedIconTheme: const IconThemeData(
                    color: AppColors.accent,
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: AppColors.textLight,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.watch_outlined,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  destinations: _destinations
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(growable: false),
                  onDestinationSelected: (i) => setState(() => index = i),
                ),
                const VerticalDivider(width: 1, color: AppColors.border),
                Expanded(child: screens[index]),
              ],
            ),
            floatingActionButton: const ChatbotLauncher(),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        }

        return Scaffold(
          body: screens[index],
          floatingActionButton: const ChatbotLauncher(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (i) => setState(() => index = i),
            items: _destinations
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
                )
                .toList(growable: false),
          ),
        );
      },
    );
  }
}

class _UserDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _UserDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
