import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wishlist_provider.dart';
import '../models/watch_model.dart';
import '../theme/app_colors.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final wishlistProvider = Provider.of<WishlistProvider>(context);
    List<Watch> wishlistItems = wishlistProvider.wishlistItems;

    return Scaffold(
      backgroundColor: AppColors.primaryGold.withOpacity(0.05),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 92,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "My Wishlist",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              Shadow(offset: Offset(0, 2), blurRadius: 8, color: Color(0x80000000)),
              Shadow(offset: Offset(0, -2), blurRadius: 8, color: AppColors.primaryGold),
            ],
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.darkBg, AppColors.primaryGold.withOpacity(0.3)],
            ),
          ),
        ),
      ),

      body: wishlistItems.isEmpty
          ? const Center(
              child: Text("No items in wishlist"),
            )
          : ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {

                final watch = wishlistItems[index];

                return ListTile(
                  leading: Image.network(
                    watch.image,
                    width: 60,
                    fit: BoxFit.cover,
                  ),

                  title: Text(watch.name),

                  subtitle: Text("₹${watch.price}"),

                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => wishlistProvider.toggleWishlist(watch),
                  ),
                );
              },
            ),
    );
  }
}