import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/watch_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

class WatchCard extends StatelessWidget {
  final Watch watch;

  const WatchCard({super.key, required this.watch});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260, // 🔥 FIX (important)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(22),
            ),
            child: Stack(
              children: [
                Image.network(
                  watch.image,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                /// ❤️ Wishlist
                Positioned(
                  right: 10,
                  top: 10,
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlistProvider, child) => GestureDetector(
                      onTap: () => wishlistProvider.toggleWishlist(watch),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          wishlistProvider.isFavorite(watch) ? Icons.favorite : Icons.favorite_border, 
                          size: 18,
                          color: wishlistProvider.isFavorite(watch) ? Colors.red : null,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

          /// DETAILS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// NAME
                Text(
                  watch.name,
                  maxLines: 1, // 🔥 FIX (overflow removed)
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                /// BRAND
                Text(
                  watch.brand,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 10),

                /// PRICE + BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rs ${watch.price.toInt()}",
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Provider.of<CartProvider>(context, listen: false).addToCart(watch);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart!'),
                            duration: Duration(milliseconds: 800),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Add",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}