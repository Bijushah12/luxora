import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/unsplash_service.dart';
import '../models/watch_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/watch_card.dart';
import '../screens/search_screen.dart';
import '../screens/men_screen.dart';
import '../screens/women_screen.dart';
import '../screens/luxury_screen.dart';
import '../screens/sports_screen.dart';
import '../screens/smart_screen.dart';
import '../screens/Category_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui' as ui;
import '../screens/product_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _searchController = TextEditingController();

  List<Watch> apiWatches = [];
  List<String> bannerImages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);
    _controller.forward();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      loadWatches(),
      loadBanners(),
    ]);
  }

  Future<void> loadWatches() async {
    try {
      final data = await ApiService.getWatches();
      if (mounted) {
        setState(() {
          apiWatches = data;
        });
      }
    } catch (e) {
      print("API Error: $e");
    }
  }

  Future<void> loadBanners() async {
    try {
      bannerImages = await UnsplashService.fetchImagesByCategory('banner');
      if (bannerImages.length < 4) {
        bannerImages.addAll([
          'https://images.unsplash.com/photo-1524592094714-0f0654e20314',
          'https://images.unsplash.com/photo-1587836374828-4dbafa94cf0e',
          'https://images.unsplash.com/photo-1508057198894-247b23fe5ade',
          'https://images.unsplash.com/photo-1609587312208-cea54be969e7',
        ]);
      }
    } catch (e) {
      print("Banner load error: $e");
      bannerImages = [
        'https://images.unsplash.com/photo-1524592094714-0f0654e20314',
        'https://images.unsplash.com/photo-1587836374828-4dbafa94cf0e',
        'https://images.unsplash.com/photo-1508057198894-247b23fe5ade',
        'https://images.unsplash.com/photo-1609587312208-cea54be969e7',
      ];
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }


  final List<String> bannerTitles = ['Luxury Watches', 'Modern Style', 'Premium Collection', 'Elegant Design'];


  List<Watch> get newArrivals {
    final len = apiWatches.length;
    final firstHalf = List<Watch>.from(apiWatches.sublist(0, len ~/ 2));
    firstHalf.shuffle();
    return firstHalf;
  }

  List<Watch> get trendingWatches {
    final len = apiWatches.length;
    final secondHalf = List<Watch>.from(apiWatches.sublist(len ~/ 2));
    secondHalf.shuffle();
    return secondHalf;
  }

  Widget _buildCategorySection() {
    final categoryItems = [
      {
        'title': 'All',
        'image': 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=300&q=80',
      },
      {
        'title': 'Men',
        'image': 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=300&q=80',
      },
      {
        'title': 'Women',
        'image': 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&w=300&q=80',
      },
      {
        'title': 'Luxury',
        'image': 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&w=300&q=80',
      },
      {
        'title': 'Sports',
        'image': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=300&q=80',
      },
      {
        'title': 'Smart',
        'image': 'https://images.unsplash.com/photo-1544117519-31a4b719223d?auto=format&fit=crop&w=300&q=80',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        SizedBox(
          height: 124,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categoryItems.length,
            itemBuilder: (context, index) {
              final item = categoryItems[index];
              final title = item['title']!;
              return GestureDetector(
                onTap: () => _openCategory(title),
                child: Container(
                  width: 88,
                  margin: const EdgeInsets.only(right: 18),
                  child: Column(
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.card,
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: item['image']!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surface,
                              child: const Icon(Icons.watch, color: AppColors.textLight),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surface,
                              child: const Icon(Icons.watch_outlined, color: AppColors.textLight),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openCategory(String category) {
    switch (category) {
      case 'Men':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MenScreen()));
        break;
      case 'Women':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WomenScreen()));
        break;
      case 'Luxury':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LuxuryScreen()));
        break;
      case 'Sports':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SportsScreen()));
        break;
      case 'Smart':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SmartScreen()));
        break;
      default:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => CategoryScreen(category)));
    }
  }

  Widget _buildTrustSection() {
    final items = [
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Authentic',
        'subtitle': 'Original watches',
      },
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Fast Delivery',
        'subtitle': 'Quick doorstep shipping',
      },
      {
        'icon': Icons.workspace_premium_outlined,
        'title': 'Warranty',
        'subtitle': 'Service support',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(item['icon'] as IconData, color: AppColors.accent, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    item['title'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['subtitle'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewsSection() {
    final reviews = [
      {
        'name': 'Aarav Mehta',
        'initials': 'AM',
        'review': 'Premium feel, neat packaging, and the watch looked even better in person.',
      },
      {
        'name': 'Nisha Kapoor',
        'initials': 'NK',
        'review': 'Loved the collection. The product details made choosing the right watch easy.',
      },
      {
        'name': 'Rohan Shah',
        'initials': 'RS',
        'review': 'Smooth experience from browsing to cart. Great designs for gifting.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'Customer Reviews',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        SizedBox(
          height: 178,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            review['initials'] as String,
                            style: const TextStyle(
                              color: AppColors.textInverse,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            review['name'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.star, color: AppColors.goldAccent, size: 16),
                        Icon(Icons.star, color: AppColors.goldAccent, size: 16),
                        Icon(Icons.star, color: AppColors.goldAccent, size: 16),
                        Icon(Icons.star, color: AppColors.goldAccent, size: 16),
                        Icon(Icons.star_half, color: AppColors.goldAccent, size: 16),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      review['review'] as String,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOfferSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openCategory('Special Member Deals'),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.card_giftcard_outlined,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Special Member Deals',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textInverse,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Tap to explore all collections with member offers.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFFD1D5DB),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textInverse,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: AppColors.accent, size: 24),

            const SizedBox(width: 8),
            const Text(
              'LUXORA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
        : RefreshIndicator(
            onRefresh: _loadData,
            child: CustomScrollView(
              slivers: [
                // Banner carousel
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 200,
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 200,
                            autoPlay: true,
                            viewportFraction: 1,
                            autoPlayInterval: const Duration(seconds: 3),
                            enlargeCenterPage: false,
                          ),
                          items: List.generate(
                            (bannerImages.length < 4 ? 4 : bannerImages.length),
                            (index) => Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: bannerImages[index % bannerImages.length],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.watch, color: Colors.grey, size: 50),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: Text(
                                    bannerTitles[index % bannerTitles.length],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Search bar
SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),

                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.glassBg,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.glassBorder),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.glassShadow,
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            readOnly: true,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SearchScreen()),
                              );
                            },
                            decoration: InputDecoration(
                              hintText: 'Search luxury watches...',
                              hintStyle: const TextStyle(color: AppColors.textLight),
                              prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Categories
                SliverToBoxAdapter(child: _buildCategorySection()),

                // New Arrivals
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('New Arrivals', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CategoryScreen('New Arrivals'))),
                              child: const Text('View All', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: newArrivals.length > 4 ? 4 : newArrivals.length,
                        itemBuilder: (context, index) => WatchCard(
                          watch: newArrivals[index],
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductScreen(newArrivals[index]))),
                        ),
                      ),
                    ],
                  ),
                ),

                // Trending Now
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Trending Now', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                            Text('View All', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: trendingWatches.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 170,
                                child: WatchCard(
                                  watch: trendingWatches[index],
                                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductScreen(trendingWatches[index]))),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SliverToBoxAdapter(child: _buildTrustSection()),

                SliverToBoxAdapter(child: _buildReviewsSection()),

                SliverToBoxAdapter(child: _buildOfferSection()),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
    );
  }
}
