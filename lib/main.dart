import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/cart_provider.dart';
import 'providers/address_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/order_provider.dart';
import 'providers/admin_auth_provider.dart';
import 'providers/admin_dashboard_provider.dart';
import 'providers/admin_orders_provider.dart';
import 'providers/admin_products_provider.dart';
import 'providers/admin_settings_provider.dart';
import 'providers/admin_users_provider.dart';
import 'theme/app_theme.dart';
import 'screens/admin/admin_gate.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const LuxoraApp());
}

class LuxoraApp extends StatelessWidget {
  const LuxoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => AdminProductsProvider()),
        ChangeNotifierProvider(create: (_) => AdminOrdersProvider()),
        ChangeNotifierProvider(create: (_) => AdminUsersProvider()),
        ChangeNotifierProvider(create: (_) => AdminSettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => AddressProvider()..loadAddresses(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..loadNotifications(),
        ),
      ],

      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Luxora Watch",

            themeAnimationDuration: const Duration(milliseconds: 400),

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.currentTheme,

            scrollBehavior: const MaterialScrollBehavior().copyWith(
              physics: const BouncingScrollPhysics(),
            ),

            builder: (context, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: child,
              );
            },

            home: const SplashScreen(),
            routes: {'/admin': (_) => const AdminGate()},
          );
        },
      ),
    );
  }
}
