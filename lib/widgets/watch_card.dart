import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/watch_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../screens/product_screen.dart';
import '../theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class WatchCard extends StatefulWidget {
  final Watch watch;
  final VoidCallback? onTap;
  final bool isSkeleton;

  const WatchCard({
    super.key,
    required this.watch,
    this.onTap,
    this.isSkeleton = false,
  });

  @override
  State<WatchCard> createState() => _WatchCardState();
}

class _WatchCardState extends State<WatchCard> with SingleTickerProviderStateMixin {
  late AnimationController _liftController;
  late Animation<double> _liftAnimation;

  @override
  void initState() {
    super.initState();
    _liftController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _liftAnimation = Tween<double>(
      begin: 0,
      end: -4,
    ).animate(CurvedAnimation(parent: _liftController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _liftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSkeleton) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: AppColors.card,
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 140, color: Colors.white),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, width: 120, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 10, width: 80, color: Colors.white),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(height: 12, width: 60, color: Colors.white),
                          Container(width: 40, height: 24, color: Colors.white),
                        ],
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

    return GestureDetector(
      onTapDown: (_) => _liftController.forward(),
      onTapUp: (_) {
        _liftController.reverse();
        if (widget.onTap != null) {
          widget.onTap!.call();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductScreen(widget.watch)),
          );
        }
      },
      onTapCancel: () => _liftController.reverse(),
      child: AnimatedBuilder(
        animation: _liftAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _liftAnimation.value),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
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
                        CachedNetworkImage(
                          imageUrl: widget.watch.image,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 140,
                              color: Colors.grey[300],
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 140,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        ),

                        Positioned(
                          right: 10,
                          top: 10,
                          child: Consumer<WishlistProvider>(
                            builder: (context, wishlistProvider, child) => GestureDetector(
                              onTap: () => wishlistProvider.toggleWishlist(widget.watch),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  wishlistProvider.isFavorite(widget.watch) ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: wishlistProvider.isFavorite(widget.watch) ? AppColors.error : AppColors.textLight,
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
                          widget.watch.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: AppColors.textDark,
                          ),
                        ),

                        const SizedBox(height: 4),

                        /// BRAND
                        Text(
                          widget.watch.brand,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// PRICE + BADGE + BUTTON
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Rs ${widget.watch.price.toInt()}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.goldAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (widget.watch.category.toLowerCase().contains('luxury')) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Luxury',
                                        style: TextStyle(
                                          color: AppColors.textInverse,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            GestureDetector(
                              onTap: () {
                                Provider.of<CartProvider>(context, listen: false).addToCart(widget.watch);
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
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Add",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
            ),
          );
        },
      ),
    );
  }
}
