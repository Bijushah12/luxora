import 'package:flutter/material.dart';

import '../models/watch_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

enum WatchSortOption { featured, priceLowToHigh, priceHighToLow, nameAToZ }

extension WatchSortOptionLabel on WatchSortOption {
  String get label {
    switch (this) {
      case WatchSortOption.featured:
        return 'Featured';
      case WatchSortOption.priceLowToHigh:
        return 'Price: Low to High';
      case WatchSortOption.priceHighToLow:
        return 'Price: High to Low';
      case WatchSortOption.nameAToZ:
        return 'Name: A to Z';
    }
  }
}

class WatchFilterState {
  final double? minPrice;
  final double? maxPrice;
  final String brand;
  final String category;
  final WatchSortOption sortOption;

  const WatchFilterState({
    this.minPrice,
    this.maxPrice,
    this.brand = 'All',
    this.category = 'All',
    this.sortOption = WatchSortOption.featured,
  });

  bool get hasActiveFilters {
    return minPrice != null ||
        maxPrice != null ||
        brand != 'All' ||
        category != 'All' ||
        sortOption != WatchSortOption.featured;
  }
}

class WatchFilters {
  static List<Watch> apply(
    List<Watch> watches,
    WatchFilterState filter, {
    String query = '',
  }) {
    final search = query.trim().toLowerCase();
    final result = watches.where((watch) {
      final matchesSearch =
          search.isEmpty ||
          watch.name.toLowerCase().contains(search) ||
          watch.brand.toLowerCase().contains(search) ||
          watch.category.toLowerCase().contains(search) ||
          watch.description.toLowerCase().contains(search);
      final matchesBrand = filter.brand == 'All' || watch.brand == filter.brand;
      final matchesCategory =
          filter.category == 'All' || watch.category == filter.category;
      final matchesMin =
          filter.minPrice == null || watch.price >= filter.minPrice!;
      final matchesMax =
          filter.maxPrice == null || watch.price <= filter.maxPrice!;

      return matchesSearch &&
          matchesBrand &&
          matchesCategory &&
          matchesMin &&
          matchesMax;
    }).toList();

    switch (filter.sortOption) {
      case WatchSortOption.featured:
        break;
      case WatchSortOption.priceLowToHigh:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case WatchSortOption.priceHighToLow:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case WatchSortOption.nameAToZ:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return result;
  }

  static List<String> brandsFor(List<Watch> watches) {
    final brands =
        watches
            .map((watch) => watch.brand.trim())
            .where((brand) => brand.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...brands];
  }
}

class WatchFilterButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;

  const WatchFilterButton({
    super.key,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Filter watches',
          icon: const Icon(Icons.tune),
          onPressed: onPressed,
        ),
        if (isActive)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

Future<WatchFilterState?> showWatchFilterSheet({
  required BuildContext context,
  required WatchFilterState current,
  required List<Watch> watches,
  bool includeCategory = false,
}) {
  return showModalBottomSheet<WatchFilterState>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _WatchFilterSheet(
      current: current,
      watches: watches,
      includeCategory: includeCategory,
    ),
  );
}

class _WatchFilterSheet extends StatefulWidget {
  final WatchFilterState current;
  final List<Watch> watches;
  final bool includeCategory;

  const _WatchFilterSheet({
    required this.current,
    required this.watches,
    required this.includeCategory,
  });

  @override
  State<_WatchFilterSheet> createState() => _WatchFilterSheetState();
}

class _WatchFilterSheetState extends State<_WatchFilterSheet> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  late String _brand;
  late String _category;
  late WatchSortOption _sortOption;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.current.minPrice?.toStringAsFixed(0) ?? '',
    );
    _maxController = TextEditingController(
      text: widget.current.maxPrice?.toStringAsFixed(0) ?? '',
    );
    _brand = widget.current.brand;
    _category = widget.current.category;
    _sortOption = widget.current.sortOption;
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final brands = WatchFilters.brandsFor(widget.watches);
    if (!brands.contains(_brand)) {
      _brand = 'All';
    }
    final categories = ['All', ...ApiService.categories];
    if (!categories.contains(_category)) {
      _category = 'All';
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filter Watches',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(const WatchFilterState()),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      'Min price',
                      Icons.currency_rupee,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      'Max price',
                      Icons.currency_rupee,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _brand,
              decoration: _inputDecoration('Brand', Icons.watch),
              items: brands
                  .map(
                    (brand) =>
                        DropdownMenuItem(value: brand, child: Text(brand)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _brand = value ?? 'All'),
            ),
            if (widget.includeCategory) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _inputDecoration(
                  'Category',
                  Icons.category_outlined,
                ),
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _category = value ?? 'All'),
              ),
            ],
            const SizedBox(height: 18),
            const Text(
              'Sort by',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WatchSortOption.values.map((option) {
                final selected = option == _sortOption;
                return ChoiceChip(
                  label: Text(option.label),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _sortOption = option),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text('Apply Filters'),
                onPressed: _apply,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }

  void _apply() {
    final minPrice = double.tryParse(_minController.text.trim());
    final maxPrice = double.tryParse(_maxController.text.trim());

    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Min price should be lower than max price'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      WatchFilterState(
        minPrice: minPrice,
        maxPrice: maxPrice,
        brand: _brand,
        category: widget.includeCategory ? _category : 'All',
        sortOption: _sortOption,
      ),
    );
  }
}
