import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
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
    loadWatches();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void loadWatches() async {
    try {
      final data = await ApiService.getWatches();
      setState(() {
        apiWatches = data;
        isLoading = false;
      });
    } catch (e) {
      print("API Error: $e");
      setState(() => isLoading = false);
    }
  }

List<Map<String, String>> banners = [
  {
    'image': 'https://images.unsplash.com/photo-1524592094714-0f0654e20314',
    'title': 'Luxury Watches'
  },
  {
    'image': 'https://images.unsplash.com/photo-1587836374828-4dbafa94cf0e',
    'title': 'Modern Style'
  },
  {
    'image': 'https://images.unsplash.com/photo-1508057198894-247b23fe5ade',
    'title': 'Premium Collection'
  },
  {
    'image': 'https://images.unsplash.com/photo-1609587312208-cea54be969e7',
        'title': 'Elegant Design'
  },
];  final List<String> categories = ['All', 'Men', 'Women', 'Luxury', 'Sports', 'Smart'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGold.withOpacity(0.05),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 92,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'LUXORA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: Colors.white,
                    shadows: [
                      Shadow(offset: Offset(0, 2), blurRadius: 8, color: Color(0x80000000)),
                      Shadow(offset: Offset(0, -2), blurRadius: 8, color: AppColors.primaryGold),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              'PREMIUM WATCH COLLECTION',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
        automaticallyImplyLeading: false,
        actions: [],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 132)),
              
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        height: 320,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.darkBg, AppColors.primaryGold],
                          ),
                        ),
child: CarouselSlider(
  options: CarouselOptions(
    height: 320,
    autoPlay: true,
    viewportFraction: 1,
    autoPlayInterval: Duration(seconds: 2),
  ),
  items: banners.map((banner) {
    return Stack(
      fit: StackFit.expand,
      children: [

Image.network(
  banner['image']!,
  fit: BoxFit.cover,
  width: double.infinity,
  errorBuilder: (_, __, ___) =>
      const Center(child: Icon(Icons.image_not_supported)),
),

       Container(
          color: Colors.black.withOpacity(0.3),
        ),
      ],
    );
  }).toList(),
),                      ),
                    ),
                    Positioned(
                      top: 120,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                        const Icon(Icons.stars, color: Colors.white, size: 50),
                          const SizedBox(height: 16),
                          const Text(
                            'DISCOVER TIMELESS ELEGANCE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 2,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.darkBg,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  elevation: 15,
                                  shadowColor: AppColors.primaryGold,
                                ),
                                onPressed: () => _controller.forward(),
                                child: const Text('EXPLORE COLLECTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
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
                        prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: const Text('Categories', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.darkBg)),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: () {
                                switch (cat) {
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
                                    loadWatches();
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [AppColors.primaryGold, AppColors.accentGold]),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryGold.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: AppColors.darkBg,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('New Arrivals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.darkBg)),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CategoryScreen('New Arrivals'))),
                            child: Text('View All', style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 0.55, 
  ),
  itemCount: newArrivals.length > 4 ? 4 : newArrivals.length,
  itemBuilder: (context, index) =>
      WatchCard(watch: newArrivals[index]),
),                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Trending Now', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.darkBg)),
                          TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: AppColors.accentGold))),
                          
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 320,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: trendingWatches.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SizedBox(width: 220, child: WatchCard(watch: trendingWatches[index])),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
