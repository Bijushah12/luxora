import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/watch_model.dart';
import '../providers/cart_provider.dart';
import '../widgets/watch_filter_sheet.dart';
import '../widgets/watch_card.dart';
import 'cart_screen.dart';

class LuxuryScreen extends StatefulWidget {
  const LuxuryScreen({super.key});

  @override
  State<LuxuryScreen> createState() => _LuxuryScreenState();
}

class _LuxuryScreenState extends State<LuxuryScreen> {
  List<Watch> categoryWatches = [];
  bool isLoading = true;
  WatchFilterState _filter = const WatchFilterState();

  @override
  void initState() {
    super.initState();
    loadCategoryWatches();
  }

  Future<void> loadCategoryWatches() async {
    try {
      final allWatches = await ApiService.getWatches();
      categoryWatches = allWatches
          .where((w) => w.category == 'Luxury')
          .toList();
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Error loading Luxury watches: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final filteredWatches = WatchFilters.apply(categoryWatches, _filter);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Luxury Watches'),
        actions: [
          WatchFilterButton(
            isActive: _filter.hasActiveFilters,
            onPressed: () async {
              final next = await showWatchFilterSheet(
                context: context,
                current: _filter,
                watches: categoryWatches,
              );
              if (next != null && mounted) {
                setState(() => _filter = next);
              }
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cart.totalItems.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
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
                    const Text(
                      'Luxury watches coming soon',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      'High-quality selection loading...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : filteredWatches.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.filter_alt_off, size: 76, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No watches match filters',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Try a different price or brand.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: WatchCard.cardHeight,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredWatches.length,
                itemBuilder: (context, index) =>
                    WatchCard(watch: filteredWatches[index]),
              ),
      ),
    );
  }
}
