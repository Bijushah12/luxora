import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/admin_coupon.dart';
import '../providers/cart_provider.dart';
import '../providers/coupons_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/theme_toggle_button.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminCoupon> _filterCoupons(List<AdminCoupon> coupons) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return coupons;
    }
    return coupons
        .where((coupon) {
          return coupon.code.toLowerCase().contains(query) ||
              coupon.title.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Offers',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: StreamBuilder<List<AdminCoupon>>(
        stream: context.read<CouponsProvider>().activeCouponsStream(),
        builder: (context, snapshot) {
          final coupons = snapshot.data ?? const <AdminCoupon>[];
          final filteredCoupons = _filterCoupons(coupons);

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async => setState(() {}),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _OffersHero(
                    totalOffers: coupons.length,
                    subtotal: cart.totalPrice,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: _OfferSearchBar(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Consumer<CouponsProvider>(
                    builder: (context, provider, child) {
                      if (provider.errorMessage == null &&
                          provider.successMessage == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _OfferFeedback(
                          error: provider.errorMessage,
                          success: provider.successMessage,
                          onClose: provider.clearMessages,
                        ),
                      );
                    },
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _OffersEmptyState(
                      icon: Icons.error_outline,
                      title: 'Unable to load offers',
                      message: snapshot.error.toString(),
                    ),
                  )
                else if (coupons.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _OffersEmptyState(
                      icon: Icons.local_offer_outlined,
                      title: 'No active offers',
                      message: 'Fresh Luxora coupons will appear here.',
                    ),
                  )
                else if (filteredCoupons.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _OffersEmptyState(
                      icon: Icons.search_off,
                      title: 'No matching offers',
                      message: 'Try another coupon code or offer title.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final crossAxisCount = width >= 1100
                            ? 4
                            : width >= 760
                            ? 3
                            : width >= 520
                            ? 2
                            : 1;

                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _OfferCard(
                              coupon: filteredCoupons[index],
                              subtotal: cart.totalPrice,
                            ),
                            childCount: filteredCoupons.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                mainAxisExtent: 238,
                              ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OffersHero extends StatelessWidget {
  final int totalOffers;
  final double subtotal;

  const _OffersHero({required this.totalOffers, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'LUXORA MEMBER DEALS',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Premium offers for your next smartwatch',
                style: TextStyle(
                  color: AppColors.textInverse,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apply active admin coupons directly at checkout.',
                style: TextStyle(
                  color: AppColors.textInverse.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
          final stats = Row(
            mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Active Offers',
                  value: totalOffers.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroStat(
                  label: 'Cart Value',
                  value: 'Rs ${subtotal.toStringAsFixed(0)}',
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 18), stats],
            );
          }
          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 20),
              SizedBox(width: 330, child: stats),
            ],
          );
        },
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textInverse.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textInverse,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _OfferSearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search offers or coupon codes',
        prefixIcon: Icon(Icons.search, color: AppColors.textLight),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final AdminCoupon coupon;
  final double subtotal;

  const _OfferCard({required this.coupon, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    final couponsProvider = context.watch<CouponsProvider>();
    final isSelected = couponsProvider.selectedCoupon?.id == coupon.id;
    final canApply = couponsProvider.canUse(coupon, subtotal);
    final discountPreview = coupon.discountType == 'flat'
        ? coupon.discountValue.clamp(0, subtotal).toDouble()
        : (subtotal * (coupon.discountValue / 100))
              .clamp(0, subtotal)
              .toDouble();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? AppColors.accent : AppColors.border,
          width: isSelected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  coupon.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            coupon.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Save ${coupon.displayDiscount} on orders above Rs ${coupon.minOrderValue.toStringAsFixed(0)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  canApply
                      ? 'You save Rs ${discountPreview.toStringAsFixed(0)}'
                      : 'Min Rs ${coupon.minOrderValue.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: canApply ? AppColors.success : AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: isSelected
                    ? couponsProvider.clearCoupon
                    : () => couponsProvider.applyCoupon(coupon, subtotal),
                style: FilledButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppColors.success
                      : canApply
                      ? AppColors.primary
                      : AppColors.textLight,
                  foregroundColor: AppColors.textInverse,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: Text(isSelected ? 'Applied' : 'Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OfferFeedback extends StatelessWidget {
  final String? error;
  final String? success;
  final VoidCallback onClose;

  const _OfferFeedback({
    required this.error,
    required this.success,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    final isError = error != null;
    final color = isError ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error ?? success ?? '',
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}

class _OffersEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _OffersEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.accent, size: 52),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
