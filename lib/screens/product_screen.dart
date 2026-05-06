import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/watch_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/watch_content_service.dart';
import '../theme/app_colors.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

class ProductScreen extends StatefulWidget {
  final Watch watch;

  const ProductScreen(this.watch, {super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _selectedImageIndex = 0;

  List<String> get _galleryImages => [widget.watch.image];

  void _addToCart(BuildContext context) {
    Provider.of<CartProvider>(context, listen: false).addToCart(widget.watch);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.watch.name} added to cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  void _buyNow(BuildContext context) {
    Provider.of<CartProvider>(context, listen: false).addToCart(widget.watch);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CheckoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final galleryImages = _galleryImages;
    final selectedImageIndex = _selectedImageIndex < galleryImages.length
        ? _selectedImageIndex
        : 0;
    final selectedImage = galleryImages[selectedImageIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _ProductAppBar(watch: widget.watch),
      bottomNavigationBar: isWide
          ? null
          : _StickyPurchaseBar(
              watch: widget.watch,
              onAddToCart: () => _addToCart(context),
              onBuyNow: () => _buyNow(context),
            ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 14, 16, isWide ? 36 : 138),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 520,
                          child: _ProductGallery(
                            watch: widget.watch,
                            selectedImage: selectedImage,
                            images: galleryImages,
                            selectedIndex: selectedImageIndex,
                            onImageTap: (index) {
                              setState(() => _selectedImageIndex = index);
                            },
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: _ProductDetails(
                            watch: widget.watch,
                            showActions: true,
                            onAddToCart: () => _addToCart(context),
                            onBuyNow: () => _buyNow(context),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProductGallery(
                          watch: widget.watch,
                          selectedImage: selectedImage,
                          images: galleryImages,
                          selectedIndex: selectedImageIndex,
                          onImageTap: (index) {
                            setState(() => _selectedImageIndex = index);
                          },
                        ),
                        const SizedBox(height: 20),
                        _ProductDetails(
                          watch: widget.watch,
                          showActions: false,
                          onAddToCart: () => _addToCart(context),
                          onBuyNow: () => _buyNow(context),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Watch watch;

  const _ProductAppBar({required this.watch});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.scaffoldBg,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.textDark),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            watch.brand,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            watch.category.isEmpty ? 'Signature timepiece' : watch.category,
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
      centerTitle: true,
      actions: [
        Consumer<WishlistProvider>(
          builder: (context, wishlist, child) {
            final isFavorite = wishlist.isFavorite(watch);
            return IconButton(
              tooltip: isFavorite ? 'Remove from wishlist' : 'Add to wishlist',
              onPressed: () => wishlist.toggleWishlist(watch),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isFavorite),
                  color: isFavorite ? AppColors.error : AppColors.textDark,
                ),
              ),
            );
          },
        ),
        Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Cart',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                ),
                if (cart.totalItems > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 17),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cart.totalItems.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          tooltip: 'Share',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share option coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.ios_share_outlined),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _ProductGallery extends StatelessWidget {
  final Watch watch;
  final String selectedImage;
  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onImageTap;

  const _ProductGallery({
    required this.watch,
    required this.selectedImage,
    required this.images,
    required this.selectedIndex,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = images.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Hero(
                  tag: watch.id,
                  child: AspectRatio(
                    aspectRatio: 0.92,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.985,
                              end: 1,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        key: ValueKey(selectedImage),
                        imageUrl: selectedImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: AppColors.surface,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.watch_outlined,
                            color: AppColors.textLight,
                            size: 76,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: _GlassBadge(
                    icon: Icons.verified_outlined,
                    label: 'Authenticated',
                  ),
                ),
                if (hasMultipleImages)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _GlassBadge(
                      icon: Icons.photo_library_outlined,
                      label: '${selectedIndex + 1}/${images.length}',
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasMultipleImages) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () => onImageTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: isSelected ? 88 : 76,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.watch_outlined,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ProductDetails extends StatelessWidget {
  final Watch watch;
  final bool showActions;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _ProductDetails({
    required this.watch,
    required this.showActions,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  void _showDeliverySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => const _DeliveryAvailabilitySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = watch.category.trim().isEmpty
        ? 'Signature'
        : watch.category;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Pill(
              icon: Icons.workspace_premium_outlined,
              label: watch.brand.toUpperCase(),
              filled: true,
            ),
            _Pill(icon: Icons.category_outlined, label: category),
            const _Pill(icon: Icons.check_circle_outline, label: 'In stock'),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          watch.name,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              color: AppColors.goldAccent,
              size: 20,
            ),
            const Icon(
              Icons.star_rounded,
              color: AppColors.goldAccent,
              size: 20,
            ),
            const Icon(
              Icons.star_rounded,
              color: AppColors.goldAccent,
              size: 20,
            ),
            const Icon(
              Icons.star_rounded,
              color: AppColors.goldAccent,
              size: 20,
            ),
            const Icon(
              Icons.star_half_rounded,
              color: AppColors.goldAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${watch.id} | Curated ${category.toLowerCase()} pick',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Rs ${watch.price.toStringAsFixed(2)}',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'MRP inclusive of all taxes',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        const _TrustMetricStrip(),
        if (showActions) ...[
          const SizedBox(height: 22),
          _DesktopActionPanel(onAddToCart: onAddToCart, onBuyNow: onBuyNow),
        ],
        const SizedBox(height: 22),
        _OfferStrip(watch: watch),
        const SizedBox(height: 18),
        _InfoBox(watch: watch, onTap: () => _showDeliverySheet(context)),
        const SizedBox(height: 18),
        _StyleProfile(watch: watch),
        const SizedBox(height: 18),
        _ProductStoryTabs(watch: watch),
        const SizedBox(height: 20),
        const _ServiceStrip(),
      ],
    );
  }
}

class _StickyPurchaseBar extends StatelessWidget {
  final Watch watch;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _StickyPurchaseBar({
    required this.watch,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      elevation: 18,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rs ${watch.price.toStringAsFixed(2)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Text(
                    'Free shipping',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _PurchaseButton(
                      label: 'Add',
                      icon: Icons.shopping_bag_outlined,
                      onPressed: onAddToCart,
                      filled: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PurchaseButton(
                      label: 'Buy Now',
                      icon: Icons.flash_on_outlined,
                      onPressed: onBuyNow,
                      filled: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopActionPanel extends StatelessWidget {
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _DesktopActionPanel({
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PurchaseButton(
            label: 'Add to Cart',
            icon: Icons.shopping_bag_outlined,
            onPressed: onAddToCart,
            filled: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PurchaseButton(
            label: 'Buy Now',
            icon: Icons.flash_on_outlined,
            onPressed: onBuyNow,
            filled: true,
          ),
        ),
      ],
    );
  }
}

class _PurchaseButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  const _PurchaseButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppColors.textInverse : AppColors.textDark;
    final background = filled ? AppColors.primary : AppColors.card;

    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          side: BorderSide(
            color: filled ? AppColors.primary : AppColors.primary,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _OfferStrip extends StatelessWidget {
  final Watch watch;

  const _OfferStrip({required this.watch});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Luxora Privilege',
                  style: TextStyle(
                    color: AppColors.textInverse,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Complimentary gift box, insured dispatch, and priority support for ${watch.brand} buyers.',
                  style: TextStyle(
                    color: AppColors.textInverse.withValues(alpha: 0.76),
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

class _InfoBox extends StatelessWidget {
  final Watch watch;
  final VoidCallback onTap;

  const _InfoBox({required this.watch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final description = WatchContentService.descriptionFor(watch);

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.textDark,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Check delivery availability',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textDark),
                ],
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 36),
                child: Text(
                  'Free insured shipping across India',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textLight,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustMetricStrip extends StatelessWidget {
  const _TrustMetricStrip();

  @override
  Widget build(BuildContext context) {
    const metrics = [
      _MetricData(
        icon: Icons.verified_user_outlined,
        title: '24 months',
        subtitle: 'Warranty',
      ),
      _MetricData(
        icon: Icons.local_shipping_outlined,
        title: '3-5 days',
        subtitle: 'Delivery',
      ),
      _MetricData(
        icon: Icons.payments_outlined,
        title: 'Secure',
        subtitle: 'Checkout',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 390;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: metrics.map((metric) {
            final width = isCompact
                ? constraints.maxWidth
                : (constraints.maxWidth - 20) / 3;
            return SizedBox(
              width: width,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(metric.icon, color: AppColors.accent, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metric.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            metric.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _StyleProfile extends StatelessWidget {
  final Watch watch;

  const _StyleProfile({required this.watch});

  List<_ProfilePoint> get _profile {
    final category = watch.category.toLowerCase();
    if (category.contains('sport')) {
      return const [
        _ProfilePoint('Durability', 0.90),
        _ProfilePoint('Motion ready', 0.86),
        _ProfilePoint('Desk to dinner', 0.62),
      ];
    }
    if (category.contains('smart')) {
      return const [
        _ProfilePoint('Utility', 0.92),
        _ProfilePoint('Comfort', 0.84),
        _ProfilePoint('Presence', 0.66),
      ];
    }
    if (category.contains('luxury')) {
      return const [
        _ProfilePoint('Craft presence', 0.94),
        _ProfilePoint('Statement', 0.88),
        _ProfilePoint('Daily wear', 0.64),
      ];
    }
    return const [
      _ProfilePoint('Versatility', 0.84),
      _ProfilePoint('Dress appeal', 0.78),
      _ProfilePoint('Statement', 0.70),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.tune_outlined,
            title: 'Style profile',
            subtitle: 'A quick read on how this watch wears.',
          ),
          const SizedBox(height: 18),
          ..._profile.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ProfileBar(point: point),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBar extends StatelessWidget {
  final _ProfilePoint point;

  const _ProfileBar({required this.point});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: point.value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    point.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 7,
                color: AppColors.accent,
                backgroundColor: AppColors.surface,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductStoryTabs extends StatefulWidget {
  final Watch watch;

  const _ProductStoryTabs({required this.watch});

  @override
  State<_ProductStoryTabs> createState() => _ProductStoryTabsState();
}

class _ProductStoryTabsState extends State<_ProductStoryTabs> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    const labels = ['Details', 'Care', 'Guarantee'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.article_outlined,
            title: 'Product intelligence',
            subtitle: 'Details that matter before checkout.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(labels.length, (index) {
              final isSelected = _selectedTab == index;
              return ChoiceChip(
                showCheckmark: false,
                selected: isSelected,
                label: Text(labels[index]),
                onSelected: (_) => setState(() => _selectedTab = index),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.textInverse
                      : AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey(_selectedTab),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 1:
        return const _BulletList(
          bullets: [
            'Wipe with a soft dry cloth after regular wear.',
            'Keep away from perfume, sanitizer, and direct moisture exposure.',
            'Store inside the box when travelling or not in use.',
          ],
        );
      case 2:
        return const _BulletList(
          bullets: [
            'Brand-authenticated dispatch with Luxora quality checks.',
            'Covered by 24 months service support from purchase date.',
            'Secure payment flow with order tracking after checkout.',
          ],
        );
      default:
        return _SpecGrid(watch: widget.watch);
    }
  }
}

class _SpecGrid extends StatelessWidget {
  final Watch watch;

  const _SpecGrid({required this.watch});

  @override
  Widget build(BuildContext context) {
    final category = watch.category.trim().isEmpty
        ? 'Signature'
        : watch.category;
    final specs = [
      _SpecData('Reference', watch.id),
      _SpecData('Collection', category),
      _SpecData('Brand', watch.brand),
      const _SpecData('Packaging', 'Gift ready'),
      const _SpecData('Delivery', '3-5 days'),
      const _SpecData('Returns', 'Easy return'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 560 ? 3 : 2;
        final spacing = 12.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: specs.map((spec) {
            return SizedBox(
              width: width,
              child: _SpecTile(spec: spec),
            );
          }).toList(),
        );
      },
    );
  }
}

class _SpecTile extends StatelessWidget {
  final _SpecData spec;

  const _SpecTile({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            spec.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            spec.value.trim().isEmpty ? 'Luxora' : spec.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> bullets;

  const _BulletList({required this.bullets});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: bullets.map((bullet) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.accent,
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  bullet,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ServiceStrip extends StatelessWidget {
  const _ServiceStrip();

  @override
  Widget build(BuildContext context) {
    const services = [
      _MetricData(
        icon: Icons.verified_user_outlined,
        title: 'Warranty',
        subtitle: '24 months',
      ),
      _MetricData(
        icon: Icons.local_shipping_outlined,
        title: 'Shipping',
        subtitle: 'Free',
      ),
      _MetricData(
        icon: Icons.inventory_2_outlined,
        title: 'Returns',
        subtitle: 'Easy',
      ),
      _MetricData(
        icon: Icons.payments_outlined,
        title: 'COD',
        subtitle: 'Available',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth < 430
            ? (constraints.maxWidth - 12) / 2
            : (constraints.maxWidth - 36) / 4;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: services.map((service) {
            return SizedBox(
              width: itemWidth,
              child: Container(
                height: 94,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(service.icon, color: AppColors.textDark, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      service.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _DeliveryAvailabilitySheet extends StatefulWidget {
  const _DeliveryAvailabilitySheet();

  @override
  State<_DeliveryAvailabilitySheet> createState() =>
      _DeliveryAvailabilitySheetState();
}

class _DeliveryAvailabilitySheetState
    extends State<_DeliveryAvailabilitySheet> {
  final TextEditingController _controller = TextEditingController();
  String _selectedPincode = '110001';
  String _checkedPincode = '';
  String _checkedLocation = '';
  String _pincodeError = '';

  static const _locations = [
    {'pin': '110001', 'city': 'New Delhi, Delhi, India'},
    {'pin': '400001', 'city': 'Mumbai, Maharashtra, India'},
    {'pin': '560001', 'city': 'Bengaluru, Karnataka, India'},
    {'pin': '700001', 'city': 'Kolkata, West Bengal, India'},
    {'pin': '600001', 'city': 'Chennai, Tamil Nadu, India'},
    {'pin': '380001', 'city': 'Ahmedabad, Gujarat, India'},
    {'pin': '302001', 'city': 'Jaipur, Rajasthan, India'},
    {'pin': '500001', 'city': 'Hyderabad, Telangana, India'},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final isTypedPincodeValid = RegExp(r'^[1-9][0-9]{5}$').hasMatch(query);
    final filteredLocations = query.isEmpty
        ? _locations
        : _locations.where((location) {
            final pin = location['pin']!;
            final city = location['city']!.toLowerCase();
            return pin.startsWith(query) || city.contains(query.toLowerCase());
          }).toList();
    final displayLocations = filteredLocations.isNotEmpty
        ? filteredLocations
        : isTypedPincodeValid
        ? [
            {'pin': query, 'city': 'Delivery across India'},
          ]
        : _locations;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          MediaQuery.of(context).viewInsets.bottom + 22,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Delivery estimate',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textDark),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.accent),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter your pincode to confirm delivery, shipping speed, and payment availability.',
                      style: TextStyle(
                        color: AppColors.textLight,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Search pincode',
                      hintText: 'Enter Indian pincode',
                      errorText: _pincodeError.isEmpty ? null : _pincodeError,
                      suffixIcon: IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _checkedPincode = '';
                            _checkedLocation = '';
                            _pincodeError = '';
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {
                        _checkedPincode = '';
                        _checkedLocation = '';
                        _pincodeError = '';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _checkPincode,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textInverse,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Check',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 230),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: displayLocations.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: AppColors.divider),
                  itemBuilder: (context, index) {
                    final location = displayLocations[index];
                    final pin = location['pin']!;
                    final isSelected = _selectedPincode == pin;
                    return ListTile(
                      onTap: () {
                        _controller.text = pin;
                        setState(() {
                          _selectedPincode = pin;
                          _checkedPincode = pin;
                          _checkedLocation = location['city']!;
                          _pincodeError = '';
                        });
                      },
                      title: Text(
                        pin,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(location['city']!),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            )
                          : null,
                    );
                  },
                ),
              ),
            ),
            if (_checkedPincode.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Delivery available at $_checkedPincode',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_checkedLocation.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _checkedLocation,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Text(
                      'Expected delivery in 3-5 days with free insured shipping.',
                      style: TextStyle(
                        color: AppColors.textLight,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _checkPincode() {
    final value = _controller.text.trim();
    final pincode = value.isEmpty ? _selectedPincode : value;
    final isValid = RegExp(r'^[1-9][0-9]{5}$').hasMatch(pincode);
    Map<String, String>? matchedLocation;
    for (final location in _locations) {
      if (location['pin'] == pincode) {
        matchedLocation = location;
        break;
      }
    }

    setState(() {
      _selectedPincode = isValid ? pincode : _selectedPincode;
      _checkedPincode = isValid ? pincode : '';
      _checkedLocation = isValid
          ? (matchedLocation?['city'] ?? 'Delivery across India')
          : '';
      _pincodeError = isValid ? '' : 'Enter a valid 6-digit Indian pincode';
    });
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textLight,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;

  const _Pill({required this.icon, required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: filled ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: filled ? AppColors.accent : AppColors.textLight,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: filled ? AppColors.textInverse : AppColors.textDark,
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

class _GlassBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GlassBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.glassShadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textDark, size: 15),
          const SizedBox(width: 6),
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

class _MetricData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MetricData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _ProfilePoint {
  final String label;
  final double value;

  const _ProfilePoint(this.label, this.value);
}

class _SpecData {
  final String label;
  final String value;

  const _SpecData(this.label, this.value);
}
