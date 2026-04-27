import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/watch_card.dart';
import 'orders_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  File? image;

  String name = "";
  String email = "";

  bool notificationsEnabled = true;
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 🔥 Firebase se user data load
  Future<void> loadUserData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;

        setState(() {
          name = data['name'] ?? "";
          email = data['email'] ?? "";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  void logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDark;
        final cart = Provider.of<CartProvider>(context);
        final wishlist = Provider.of<WishlistProvider>(context);
        final orders = Provider.of<OrderProvider>(context);

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.background,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text(
              'Profile',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Profile'),
                Tab(text: 'Orders'),
                Tab(text: 'Wishlist'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // PROFILE TAB
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 120),

                          GestureDetector(
                            onTap: pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: image != null
                                  ? FileImage(image!)
                                  : const NetworkImage(
                                          "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d")
                                      as ImageProvider,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(name,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),

                          Text(email,
                              style:
                                  const TextStyle(color: Colors.black54)),

                          const SizedBox(height: 20),

                          ProfileStatCard(
                            count: wishlist.wishlistItems.length.toString(),
                            title: 'Wishlist',
                            icon: Icons.favorite,
                          ),

                          ProfileStatCard(
                            count: cart.items.length.toString(),
                            title: 'Cart',
                            icon: Icons.shopping_bag,
                          ),

                          ProfileStatCard(
                            count: orders.orders.length.toString(),
                            title: 'Orders',
                            icon: Icons.inventory,
                          ),
                        ],
                      ),
                    ),

                    // ORDERS TAB
                    ListView.builder(
                      itemCount: orders.orders.length,
                      itemBuilder: (context, index) {
                        final order = orders.orders[index];
                        return ListTile(
                          title: Text("Order ${order.id}"),
                        );
                      },
                    ),

                    // WISHLIST TAB
                    ListView.builder(
                      itemCount: wishlist.wishlistItems.length,
                      itemBuilder: (context, index) =>
                          WatchCard(watch: wishlist.wishlistItems[index]),
                    ),

                    // SETTINGS TAB
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Notifications'),
                            value: notificationsEnabled,
                            onChanged: (val) {
                              setState(() =>
                                  notificationsEnabled = val);
                            },
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: logout,
                              child: const Text("Sign Out"),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}