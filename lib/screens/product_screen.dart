import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/watch_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_colors.dart';
import 'checkout_screen.dart';

class ProductScreen extends StatefulWidget {
  final Watch watch;

  const ProductScreen(this.watch, {super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _selectedImageIndex = 0;

  List<String> get _galleryImages => [
        widget.watch.image,
        'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1539874754764-5a96559165b0?auto=format&fit=crop&w=900&q=80',
      ];

  void _addToCart(BuildContext context) {
    Provider.of<CartProvider>(context, listen: false).addToCart(widget.watch);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _buyNow(BuildContext context) {
    Provider.of<CartProvider>(context, listen: false).addToCart(widget.watch);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final galleryImages = _galleryImages;
    final selectedImage = galleryImages[_selectedImageIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text(
          widget.watch.brand,
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlist, child) {
              final isFavorite = wishlist.isFavorite(widget.watch);
              return IconButton(
                onPressed: () => wishlist.toggleWishlist(widget.watch),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.error : AppColors.textDark,
                ),
              );
            },
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share option coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            return Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 16 : 0, 8, isWide ? 16 : 0, 24),
              child: Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: isWide ? constraints.maxWidth * 0.42 : double.infinity,
                    child: _ProductGallery(
                      watchId: widget.watch.id,
                      selectedImage: selectedImage,
                      images: galleryImages,
                      selectedIndex: _selectedImageIndex,
                      onImageTap: (index) {
                        setState(() => _selectedImageIndex = index);
                      },
                    ),
                  ),
                  SizedBox(width: isWide ? 28 : 0, height: isWide ? 0 : 20),
                  if (isWide)
                    Expanded(
                      child: _ProductDetails(
                        watch: widget.watch,
                        onAddToCart: () => _addToCart(context),
                        onBuyNow: () => _buyNow(context),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                      child: SizedBox(
                        width: double.infinity,
                        child: _ProductDetails(
                          watch: widget.watch,
                          onAddToCart: () => _addToCart(context),
                          onBuyNow: () => _buyNow(context),
                        ),
                      ),
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
class _ProductGallery extends StatelessWidget {
  final String watchId;
  final String selectedImage;
  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onImageTap;

  const _ProductGallery({
    required this.watchId,
    required this.selectedImage,
    required this.images,
    required this.selectedIndex,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: watchId,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: selectedImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surface,
                  child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.watch, color: AppColors.textLight, size: 72),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 72,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => onImageTap(index),
                      child: Container(
                        width: 72,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: images[index],
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Icon(Icons.watch),
                            ),
                            if (isSelected)
                              const Center(
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: AppColors.card,
                                  child: Icon(Icons.check, color: AppColors.primary, size: 20),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Text(
              '${selectedIndex + 1} / ${images.length}',
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProductDetails extends StatelessWidget {
  final Watch watch;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _ProductDetails({
    required this.watch,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  void _showDeliverySheet(BuildContext context) {
    final controller = TextEditingController();
    var selectedPincode = '110001';
    var checkedPincode = '';
    var checkedLocation = '';
    var pincodeError = '';
    final locations = [
      {'pin': '110001', 'city': 'New Delhi, Delhi, India'},
      {'pin': '400001', 'city': 'Mumbai, Maharashtra, India'},
      {'pin': '560001', 'city': 'Bengaluru, Karnataka, India'},
      {'pin': '700001', 'city': 'Kolkata, West Bengal, India'},
      {'pin': '600001', 'city': 'Chennai, Tamil Nadu, India'},
      {'pin': '380001', 'city': 'Ahmedabad, Gujarat, India'},
      {'pin': '302001', 'city': 'Jaipur, Rajasthan, India'},
      {'pin': '500001', 'city': 'Hyderabad, Telangana, India'},
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final query = controller.text.trim();
            final isTypedPincodeValid = RegExp(r'^[1-9][0-9]{5}$').hasMatch(query);
            final filteredLocations = query.isEmpty
                ? locations
                : locations.where((location) {
                    final pin = location['pin']!;
                    final city = location['city']!.toLowerCase();
                    return pin.startsWith(query) || city.contains(query.toLowerCase());
                  }).toList();
            final displayLocations = filteredLocations.isNotEmpty
                ? filteredLocations
                : isTypedPincodeValid
                    ? [
                        {
                          'pin': query,
                          'city': 'Delivery across India',
                        }
                      ]
                    : locations;

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    18,
                    22,
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
                          'Select Your Location',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Color(0xFFFFE4E6)),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_off_outlined, color: AppColors.error, size: 30),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location Permission Is Off!',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Enable your location permission from browser settings for a better delivery experience.',
                                style: TextStyle(color: AppColors.textDark, height: 1.35),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'ENABLE LOCATION',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w900,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Search Pincode',
                            hintText: 'Enter any Indian pincode',
                            errorText: pincodeError.isEmpty ? null : pincodeError,
                            suffixIcon: IconButton(
                              onPressed: () {
                                controller.clear();
                                setSheetState(() {
                                  checkedPincode = '';
                                  checkedLocation = '';
                                  pincodeError = '';
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (_) {
                            setSheetState(() {
                              checkedPincode = '';
                              checkedLocation = '';
                              pincodeError = '';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            final value = controller.text.trim();
                            setSheetState(() {
                              final pincode = value.isEmpty ? selectedPincode : value;
                              final isValid = RegExp(r'^[1-9][0-9]{5}$').hasMatch(pincode);
                              selectedPincode = isValid ? pincode : selectedPincode;
                              checkedPincode = isValid ? pincode : '';
                              checkedLocation = isValid ? 'Delivery across India' : '';
                              pincodeError = isValid ? '' : 'Enter a valid 6-digit Indian pincode';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textInverse,
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'CHECK',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 210),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: displayLocations.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                      itemBuilder: (context, index) {
                        final location = displayLocations[index];
                        final pin = location['pin']!;
                        final isSelected = selectedPincode == pin;
                        return ListTile(
                          onTap: () {
                            controller.text = pin;
                            setSheetState(() {
                              selectedPincode = pin;
                              checkedPincode = pin;
                              checkedLocation = location['city']!;
                              pincodeError = '';
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
                              ? const Icon(Icons.check_circle, color: AppColors.success)
                              : null,
                        );
                      },
                    ),
                  ),
                  if (checkedPincode.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withOpacity(0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Delivery available at $checkedPincode',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (checkedLocation.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              checkedLocation,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          const Text(
                            'Expected delivery in 3-5 days. Free shipping available across India.',
                            style: TextStyle(color: AppColors.textLight, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                watch.brand,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Text(
              '0 Reviews',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          watch.name,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${watch.id} | ${watch.category}',
          style: const TextStyle(color: AppColors.textLight, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Text(
          'MRP Rs ${watch.price.toStringAsFixed(2)}',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Inclusive of all taxes*',
          style: TextStyle(color: AppColors.textLight, fontSize: 13),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Icon(Icons.view_in_ar_outlined, color: AppColors.textDark, size: 20),
            SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 26),
        Text(
          'Dial Color : ${watch.category.isEmpty ? 'Classic' : watch.category}',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onAddToCart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'ADD TO CART',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onBuyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textInverse,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'BUY NOW',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _InfoBox(watch: watch, onTap: () => _showDeliverySheet(context)),
        const SizedBox(height: 22),
        const _ServiceStrip(),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final Watch watch;
  final VoidCallback onTap;

  const _InfoBox({required this.watch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: AppColors.textDark),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Check Delivery Availability',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
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
                  'Free shipping across India',
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                watch.description,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textLight, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceStrip extends StatelessWidget {
  const _ServiceStrip();

  @override
  Widget build(BuildContext context) {
    final services = [
      {'icon': Icons.verified_user_outlined, 'label': '24 Months\nWarranty'},
      {'icon': Icons.local_shipping_outlined, 'label': 'Free Shipping\nCountrywide'},
      {'icon': Icons.inventory_2_outlined, 'label': 'Easy\nReturn'},
      {'icon': Icons.payments_outlined, 'label': 'Pay on Delivery\nAvailable'},
      {'icon': Icons.settings_outlined, 'label': 'Serviced\nAcross India'},
    ];

    return Row(
      children: services.map((service) {
        return Expanded(
          child: Column(
            children: [
              Icon(service['icon'] as IconData, color: AppColors.textDark, size: 28),
              const SizedBox(height: 8),
              Text(
                service['label'] as String,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
