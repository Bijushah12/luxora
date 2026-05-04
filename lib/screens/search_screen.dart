import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/watch_model.dart';
import '../providers/cart_provider.dart';
import '../widgets/watch_card.dart';
import 'cart_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Watch> allWatches = [];
  List<Watch> filtered = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  List<String> recentSearches = [];
  final List<String> suggestions = [
    'Rolex',
    'Omega',
    'Men',
    'Women',
    'Luxury',
    'Sports',
    'Smart',
    'Casio',
    'Fossil',
    'Tag Heuer',
  ];

  @override
  void initState() {
    super.initState();
    loadWatches();
    loadRecentSearches();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> loadWatches() async {
    try {
      allWatches = await ApiService.getWatches();
      filtered = allWatches;
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Error loading watches: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    recentSearches.remove(query);
    recentSearches.insert(0, query);
    if (recentSearches.length > 10) {
      recentSearches = recentSearches.sublist(0, 10);
    }
    await prefs.setStringList('recent_searches', recentSearches);
    setState(() {});
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() => recentSearches = []);
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(value);
    });
  }

  void _performSearch(String value) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => filtered = allWatches);
      return;
    }
    setState(() {
      filtered = allWatches.where((watch) {
        return watch.name.toLowerCase().contains(query) ||
            watch.brand.toLowerCase().contains(query) ||
            watch.category.toLowerCase().contains(query);
      }).toList();
    });
    saveRecentSearch(value.trim());
  }

  void _submitSearch(String value) {
    _focusNode.unfocus();
    _performSearch(value);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    final bool showSuggestions =
        _controller.text.trim().isEmpty && _focusNode.hasFocus;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Watches"),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
                  );
                },
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration:
                        const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(cart.totalItems.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: onSearchChanged,
              onSubmitted: _submitSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search watches, brands, categories...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    onSearchChanged('');
                    _focusNode.requestFocus();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (showSuggestions)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recentSearches.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Searches',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: clearRecentSearches,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recentSearches.map((term) {
                          return ActionChip(
                            avatar: const Icon(Icons.history, size: 18),
                            label: Text(term),
                            onPressed: () {
                              _controller.text = term;
                              _submitSearch(term);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Suggestions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suggestions.map((term) {
                        return ActionChip(
                          avatar: const Icon(Icons.trending_up, size: 18),
                          label: Text(term),
                          onPressed: () {
                            _controller.text = term;
                            _submitSearch(term);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off,
                              size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No watches found',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try different keywords',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: WatchCard.cardHeight,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          WatchCard(watch: filtered[index]),
                    ),
            ),
        ],
      ),
    );
  }
}
