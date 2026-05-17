import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/watch_model.dart';
import '../providers/cart_provider.dart';
import '../widgets/watch_filter_sheet.dart';
import '../widgets/watch_card.dart';
import '../widgets/theme_toggle_button.dart';
import 'cart_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen(this.category, {super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
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
      if (widget.category == 'All' ||
          widget.category == 'Special Member Deals' ||
          widget.category == 'New Arrivals') {
        categoryWatches = allWatches;
      } else {
        categoryWatches = allWatches
            .where((w) => w.category == widget.category)
            .toList();
      }
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Error loading ${widget.category} watches: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final filteredWatches = WatchFilters.apply(categoryWatches, _filter);
    final includeCategory =
        widget.category == 'All' ||
        widget.category == 'Special Member Deals' ||
        widget.category == 'New Arrivals';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [
          WatchFilterButton(
            isActive: _filter.hasActiveFilters,
            onPressed: () async {
              final next = await showWatchFilterSheet(
                context: context,
                current: _filter,
                watches: categoryWatches,
                includeCategory: includeCategory,
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
          const ThemeToggleButton(),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryWatches.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.watch_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.category} watches coming soon',
                    style: const TextStyle(fontSize: 20),
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
                    'Try a different price, brand, or category.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : GridView.builder(
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
    );
  }
}
