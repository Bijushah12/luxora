import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/watch_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/watch_card.dart';

class MenScreen extends StatefulWidget {
  const MenScreen({super.key});

  @override
  State<MenScreen> createState() => _MenScreenState();
}

class _MenScreenState extends State<MenScreen> {
  List<Watch> categoryWatches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategoryWatches();
  }

  Future<void> loadCategoryWatches() async {
    try {
      final allWatches = await ApiService.getWatches();
      categoryWatches = allWatches.where((w) => w.category == 'Men').toList();
      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading Men watches: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final wishlist = Provider.of<WishlistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Men Watches'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {}, // Navigate to cart if needed
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(cart.totalItems.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryWatches.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.watch_outlined, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Men watches coming soon', style: TextStyle(fontSize: 20)),
                    Text('High-quality selection loading...', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              )
            : GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.60,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: categoryWatches.length,
                itemBuilder: (context, index) => WatchCard(watch: categoryWatches[index]),
              ),
      ),
    );
  }
}
