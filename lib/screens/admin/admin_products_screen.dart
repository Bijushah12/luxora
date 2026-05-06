import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/admin_product.dart';
import '../../providers/admin_products_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin/admin_empty_state.dart';
import '../../widgets/admin/admin_feedback.dart';
import '../../widgets/admin/admin_section.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String _categoryFilter = 'All';
  String _brandFilter = 'All';
  bool _luxuryOnly = false;
  bool _lowStockOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _openProductForm([AdminProduct? product]) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AdminProductsProvider>(),
        child: ProductFormDialog(product: product),
      ),
    );
  }

  Future<void> _deleteProduct(AdminProduct product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.name}" from Firestore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await context.read<AdminProductsProvider>().deleteProduct(product);
    }
  }

  List<AdminProduct> _filterProducts(List<AdminProduct> products) {
    final query = _searchController.text.trim().toLowerCase();
    final minPrice = double.tryParse(_minPriceController.text.trim());
    final maxPrice = double.tryParse(_maxPriceController.text.trim());

    return products
        .where((product) {
          final matchesCategory =
              _categoryFilter == 'All' || product.category == _categoryFilter;
          final matchesBrand =
              _brandFilter == 'All' || product.brand == _brandFilter;
          final matchesPrice =
              (minPrice == null || product.discountedPrice >= minPrice) &&
              (maxPrice == null || product.discountedPrice <= maxPrice);
          final matchesLuxury = !_luxuryOnly || product.isLuxury;
          final matchesLowStock = !_lowStockOnly || product.isLowStock;
          final matchesSearch =
              query.isEmpty ||
              product.name.toLowerCase().contains(query) ||
              product.brand.toLowerCase().contains(query) ||
              product.description.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query);

          return matchesCategory &&
              matchesBrand &&
              matchesPrice &&
              matchesLuxury &&
              matchesLowStock &&
              matchesSearch;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProductsProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<AdminProduct>>(
          stream: provider.productsStream(),
          builder: (context, snapshot) {
            final products = snapshot.data ?? const <AdminProduct>[];
            final filteredProducts = _filterProducts(products);
            final brands = _brandsFor(products);

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AdminFeedbackBanner(
                  error: provider.errorMessage,
                  success: provider.successMessage,
                  onClose: provider.clearMessages,
                ),
                AdminSection(
                  title: 'Products',
                  subtitle:
                      'Add, edit, upload images, and maintain the products collection',
                  icon: Icons.watch_outlined,
                  trailing: ElevatedButton.icon(
                    onPressed: () => _openProductForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                  child: Column(
                    children: [
                      _ProductSummaryStrip(products: products),
                      const SizedBox(height: 16),
                      _ProductToolbar(
                        controller: _searchController,
                        minPriceController: _minPriceController,
                        maxPriceController: _maxPriceController,
                        categoryFilter: _categoryFilter,
                        brandFilter: _brandFilter,
                        brands: brands,
                        luxuryOnly: _luxuryOnly,
                        lowStockOnly: _lowStockOnly,
                        onChanged: () => setState(() {}),
                        onCategoryChanged: (value) {
                          setState(() => _categoryFilter = value);
                        },
                        onBrandChanged: (value) {
                          setState(() => _brandFilter = value);
                        },
                        onLuxuryChanged: (value) {
                          setState(() => _luxuryOnly = value);
                        },
                        onLowStockChanged: (value) {
                          setState(() => _lowStockOnly = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const LinearProgressIndicator(minHeight: 3)
                      else if (snapshot.hasError)
                        _InlineError(message: snapshot.error.toString())
                      else if (products.isEmpty)
                        SizedBox(
                          height: 340,
                          child: AdminEmptyState(
                            icon: Icons.watch_outlined,
                            title: 'No products yet',
                            message:
                                'Create your first product to populate the products collection.',
                            action: ElevatedButton.icon(
                              onPressed: () => _openProductForm(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Product'),
                            ),
                          ),
                        )
                      else if (filteredProducts.isEmpty)
                        const SizedBox(
                          height: 260,
                          child: AdminEmptyState(
                            icon: Icons.search_off,
                            title: 'No matching products',
                            message:
                                'Adjust the search text or category filter.',
                          ),
                        )
                      else
                        _ProductsList(
                          products: filteredProducts,
                          provider: provider,
                          onEdit: _openProductForm,
                          onDelete: _deleteProduct,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> _brandsFor(List<AdminProduct> products) {
    final brands =
        products
            .map((product) => product.brand.trim())
            .where((brand) => brand.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...brands];
  }
}

class _ProductSummaryStrip extends StatelessWidget {
  final List<AdminProduct> products;

  const _ProductSummaryStrip({required this.products});

  @override
  Widget build(BuildContext context) {
    final active = products.where((product) => product.isActive).length;
    final featured = products.where((product) => product.isFeatured).length;
    final trending = products.where((product) => product.isTrending).length;
    final lowStock = products.where((product) => product.isLowStock).length;

    return _AdminSummaryGrid(
      items: [
        _AdminSummaryItem(
          label: 'Total Watches',
          value: products.length.toString(),
          icon: Icons.watch_outlined,
          color: AppColors.accent,
        ),
        _AdminSummaryItem(
          label: 'Active',
          value: active.toString(),
          icon: Icons.verified_outlined,
          color: AppColors.success,
        ),
        _AdminSummaryItem(
          label: 'Featured',
          value: featured.toString(),
          icon: Icons.diamond_outlined,
          color: AppColors.primary,
        ),
        _AdminSummaryItem(
          label: 'Trending',
          value: trending.toString(),
          icon: Icons.local_fire_department_outlined,
          color: AppColors.warning,
        ),
        _AdminSummaryItem(
          label: 'Low Stock',
          value: lowStock.toString(),
          icon: Icons.warning_amber_outlined,
          color: AppColors.error,
        ),
      ],
    );
  }
}

class _AdminSummaryGrid extends StatelessWidget {
  final List<_AdminSummaryItem> items;

  const _AdminSummaryGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 860) {
          return Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: item == items.last ? 0 : 10,
                      ),
                      child: _AdminSummaryTile(item: item),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        }

        return SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) => SizedBox(
              width: 176,
              child: _AdminSummaryTile(item: items[index]),
            ),
          ),
        );
      },
    );
  }
}

class _AdminSummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminSummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _AdminSummaryTile extends StatelessWidget {
  final _AdminSummaryItem item;

  const _AdminSummaryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

class _ProductToolbar extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final String categoryFilter;
  final String brandFilter;
  final List<String> brands;
  final bool luxuryOnly;
  final bool lowStockOnly;
  final VoidCallback onChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onBrandChanged;
  final ValueChanged<bool> onLuxuryChanged;
  final ValueChanged<bool> onLowStockChanged;

  const _ProductToolbar({
    required this.controller,
    required this.minPriceController,
    required this.maxPriceController,
    required this.categoryFilter,
    required this.brandFilter,
    required this.brands,
    required this.luxuryOnly,
    required this.lowStockOnly,
    required this.onChanged,
    required this.onCategoryChanged,
    required this.onBrandChanged,
    required this.onLuxuryChanged,
    required this.onLowStockChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 920;
        final search = TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: 'Search products',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      onChanged();
                    },
                    icon: const Icon(Icons.close),
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        final minPrice = TextField(
          controller: minPriceController,
          onChanged: (_) => onChanged(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Min price',
            prefixIcon: const Icon(Icons.currency_rupee),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        final maxPrice = TextField(
          controller: maxPriceController,
          onChanged: (_) => onChanged(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Max price',
            prefixIcon: const Icon(Icons.currency_rupee),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        final category = DropdownButtonFormField<String>(
          initialValue: categoryFilter,
          decoration: InputDecoration(
            labelText: 'Category',
            prefixIcon: const Icon(Icons.category_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: const ['All', ...AdminProduct.categories]
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onCategoryChanged(value);
            }
          },
        );
        final brand = DropdownButtonFormField<String>(
          initialValue: brands.contains(brandFilter) ? brandFilter : 'All',
          decoration: InputDecoration(
            labelText: 'Brand',
            prefixIcon: const Icon(Icons.workspace_premium_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: brands
              .map(
                (brand) => DropdownMenuItem(value: brand, child: Text(brand)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onBrandChanged(value);
            }
          },
        );
        final chips = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilterChip(
              selected: luxuryOnly,
              onSelected: onLuxuryChanged,
              avatar: const Icon(Icons.diamond_outlined, size: 18),
              label: const Text('Luxury only'),
            ),
            FilterChip(
              selected: lowStockOnly,
              onSelected: onLowStockChanged,
              avatar: const Icon(Icons.warning_amber_outlined, size: 18),
              label: const Text('Low stock'),
            ),
          ],
        );

        if (isWide) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 2, child: search),
                  const SizedBox(width: 12),
                  SizedBox(width: 180, child: category),
                  const SizedBox(width: 12),
                  SizedBox(width: 180, child: brand),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(width: 180, child: minPrice),
                  const SizedBox(width: 12),
                  SizedBox(width: 180, child: maxPrice),
                  const SizedBox(width: 16),
                  Expanded(child: chips),
                ],
              ),
            ],
          );
        }

        return Column(
          children: [
            search,
            const SizedBox(height: 12),
            category,
            const SizedBox(height: 12),
            brand,
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: minPrice),
                const SizedBox(width: 12),
                Expanded(child: maxPrice),
              ],
            ),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: chips),
          ],
        );
      },
    );
  }
}

class _ProductsList extends StatelessWidget {
  final List<AdminProduct> products;
  final AdminProductsProvider provider;
  final ValueChanged<AdminProduct> onEdit;
  final ValueChanged<AdminProduct> onDelete;

  const _ProductsList({
    required this.products,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 860;
        if (!isWide) {
          return Column(
            children: products
                .map(
                  (product) => _ProductCard(
                    product: product,
                    isDeleting: provider.isDeleting(product.id),
                    onEdit: () => onEdit(product),
                    onDelete: () => onDelete(product),
                  ),
                )
                .toList(growable: false),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            dataRowMinHeight: 76,
            dataRowMaxHeight: 88,
            headingTextStyle: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
            ),
            columns: const [
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Brand')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Stock')),
              DataColumn(label: Text('Tags')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: products.map((product) {
              final isDeleting = provider.isDeleting(product.id);
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 320,
                      child: Row(
                        children: [
                          _ProductImage(
                            imageUrl: product.primaryImageUrl,
                            size: 54,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${product.dialColor} dial | ${product.strapMaterial} | ${product.warranty}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(product.brand)),
                  DataCell(Text(product.category)),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs ${product.discountedPrice.toStringAsFixed(0)}',
                        ),
                        if (product.hasDiscount)
                          Text(
                            '${product.discount.toStringAsFixed(0)}% off',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                  ),
                  DataCell(_StockBadge(stock: product.stockQuantity)),
                  DataCell(
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (product.isFeatured)
                          const _TagBadge(
                            label: 'Featured',
                            color: AppColors.accent,
                          ),
                        if (product.isTrending)
                          const _TagBadge(
                            label: 'Trending',
                            color: AppColors.warning,
                          ),
                        if (product.isLuxury)
                          const _TagBadge(
                            label: 'Luxury',
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                  DataCell(_StatusBadge(isActive: product.isActive)),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Edit product',
                          onPressed: isDeleting ? null : () => onEdit(product),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Delete product',
                          onPressed: isDeleting
                              ? null
                              : () => onDelete(product),
                          icon: isDeleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final AdminProduct product;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductImage(imageUrl: product.primaryImageUrl, size: 74),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.brand} | ${product.category} | ${product.dialColor} dial',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.strapMaterial} | ${product.waterResistant ? 'Water resistant' : 'Not water resistant'} | ${product.warranty}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Rs ${product.discountedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (product.hasDiscount)
                      Text(
                        '${product.discount.toStringAsFixed(0)}% off',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    _StockBadge(stock: product.stockQuantity),
                    if (product.isFeatured)
                      const _TagBadge(
                        label: 'Featured',
                        color: AppColors.accent,
                      ),
                    if (product.isTrending)
                      const _TagBadge(
                        label: 'Trending',
                        color: AppColors.warning,
                      ),
                    _StatusBadge(isActive: product.isActive),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                tooltip: 'Edit product',
                onPressed: isDeleting ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete product',
                onPressed: isDeleting ? null : onDelete,
                icon: isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline, color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _ProductImage({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        color: AppColors.surface,
        child: imageUrl.trim().isEmpty
            ? const Icon(Icons.watch_outlined, color: AppColors.textLight)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textLight,
                ),
              ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.textLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;

  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final color = stock <= 0
        ? AppColors.error
        : stock <= 5
        ? AppColors.warning
        : AppColors.success;
    final label = stock <= 0 ? 'Out of stock' : 'Stock $stock';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TagBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == AppColors.accent ? AppColors.textDark : color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductFormDialog extends StatefulWidget {
  final AdminProduct? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _brandController = TextEditingController();
  final _dialColorController = TextEditingController();
  final _strapMaterialController = TextEditingController();
  final _warrantyController = TextEditingController();
  final _stockController = TextEditingController();
  final _variantsController = TextEditingController();

  late String _category;
  bool _isActive = true;
  bool _waterResistant = true;
  bool _isFeatured = false;
  bool _isTrending = false;
  final List<XFile> _pickedImages = [];
  final List<Uint8List> _pickedImageBytes = [];
  String? _imageError;
  bool _isPickingImage = false;

  AdminProduct? get _editingProduct => widget.product;

  @override
  void initState() {
    super.initState();
    final product = _editingProduct ?? AdminProduct.empty();
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price == 0
        ? ''
        : product.price.toStringAsFixed(2);
    _discountController.text = product.discount == 0
        ? ''
        : product.discount.toStringAsFixed(0);
    _brandController.text = product.brand;
    _dialColorController.text = product.dialColor;
    _strapMaterialController.text = product.strapMaterial;
    _warrantyController.text = product.warranty;
    _stockController.text = product.stockQuantity == 0
        ? ''
        : product.stockQuantity.toString();
    _variantsController.text = product.variants
        .map(
          (variant) =>
              '${variant.dialColor}/${variant.strapMaterial}/${variant.stockQuantity}',
        )
        .join('\n');
    _category = product.category;
    _isActive = product.isActive;
    _waterResistant = product.waterResistant;
    _isFeatured = product.isFeatured;
    _isTrending = product.isTrending;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _brandController.dispose();
    _dialColorController.dispose();
    _strapMaterialController.dispose();
    _warrantyController.dispose();
    _stockController.dispose();
    _variantsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    setState(() {
      _isPickingImage = true;
      _imageError = null;
    });

    try {
      final images = await ImagePicker().pickMultiImage(
        maxWidth: 1800,
        imageQuality: 86,
      );
      if (images.isEmpty) {
        return;
      }
      final bytes = await Future.wait(
        images.map((image) => image.readAsBytes()),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _pickedImages
          ..clear()
          ..addAll(images);
        _pickedImageBytes
          ..clear()
          ..addAll(bytes);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _imageError = 'Unable to pick image. $error');
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _save() async {
    final existing = _editingProduct;
    final hasExistingImage = (existing?.primaryImageUrl ?? '')
        .trim()
        .isNotEmpty;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickedImages.isEmpty && !hasExistingImage) {
      setState(() => _imageError = 'Upload at least one product image');
      return;
    }

    final product = (existing ?? AdminProduct.empty()).copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      discount: double.tryParse(_discountController.text.trim()) ?? 0,
      category: _category,
      brand: _brandController.text.trim().isEmpty
          ? 'Luxora'
          : _brandController.text.trim(),
      dialColor: _dialColorController.text.trim().isEmpty
          ? 'Black'
          : _dialColorController.text.trim(),
      strapMaterial: _strapMaterialController.text.trim().isEmpty
          ? 'Stainless Steel'
          : _strapMaterialController.text.trim(),
      waterResistant: _waterResistant,
      warranty: _warrantyController.text.trim().isEmpty
          ? '2 Years'
          : _warrantyController.text.trim(),
      stockQuantity: int.tryParse(_stockController.text.trim()) ?? 0,
      isFeatured: _isFeatured,
      isTrending: _isTrending,
      variants: _parseVariants(_variantsController.text),
      isActive: _isActive,
    );

    final ok = await context.read<AdminProductsProvider>().saveProduct(
      product,
      images: _pickedImages,
    );

    if (ok && mounted) {
      Navigator.pop(context);
    }
  }

  List<AdminWatchVariant> _parseVariants(String raw) {
    return raw
        .split('\n')
        .map((line) {
          final parts = line
              .split('/')
              .map((part) => part.trim())
              .where((part) => part.isNotEmpty)
              .toList();
          if (parts.length < 2) {
            return null;
          }
          return AdminWatchVariant(
            dialColor: parts[0],
            strapMaterial: parts[1],
            stockQuantity: parts.length >= 3 ? int.tryParse(parts[2]) ?? 0 : 0,
          );
        })
        .whereType<AdminWatchVariant>()
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProductsProvider>();
    final title = _editingProduct == null ? 'Add Product' : 'Edit Product';

    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: provider.isSaving
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 620;
                      final formFields = _ProductFields(
                        nameController: _nameController,
                        descriptionController: _descriptionController,
                        priceController: _priceController,
                        discountController: _discountController,
                        brandController: _brandController,
                        dialColorController: _dialColorController,
                        strapMaterialController: _strapMaterialController,
                        warrantyController: _warrantyController,
                        stockController: _stockController,
                        variantsController: _variantsController,
                        category: _category,
                        isActive: _isActive,
                        waterResistant: _waterResistant,
                        isFeatured: _isFeatured,
                        isTrending: _isTrending,
                        onCategoryChanged: (value) {
                          setState(() => _category = value);
                        },
                        onStatusChanged: (value) {
                          setState(() => _isActive = value);
                        },
                        onWaterResistantChanged: (value) {
                          setState(() => _waterResistant = value);
                        },
                        onFeaturedChanged: (value) {
                          setState(() => _isFeatured = value);
                        },
                        onTrendingChanged: (value) {
                          setState(() => _isTrending = value);
                        },
                      );
                      final imagePicker = _ImagePickerPanel(
                        existingImageUrls:
                            _editingProduct?.imageUrls ?? const [],
                        pickedImageBytes: _pickedImageBytes,
                        imageError: _imageError,
                        isPicking: _isPickingImage,
                        onPickImage: _pickImages,
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 240, child: imagePicker),
                            const SizedBox(width: 18),
                            Expanded(child: formFields),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          imagePicker,
                          const SizedBox(height: 18),
                          formFields,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: provider.isSaving
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: provider.isSaving ? null : _save,
                          icon: provider.isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: AppColors.textInverse,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(provider.isSaving ? 'Saving' : 'Save'),
                        ),
                      ),
                    ],
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

class _ProductFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController discountController;
  final TextEditingController brandController;
  final TextEditingController dialColorController;
  final TextEditingController strapMaterialController;
  final TextEditingController warrantyController;
  final TextEditingController stockController;
  final TextEditingController variantsController;
  final String category;
  final bool isActive;
  final bool waterResistant;
  final bool isFeatured;
  final bool isTrending;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onStatusChanged;
  final ValueChanged<bool> onWaterResistantChanged;
  final ValueChanged<bool> onFeaturedChanged;
  final ValueChanged<bool> onTrendingChanged;

  const _ProductFields({
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.discountController,
    required this.brandController,
    required this.dialColorController,
    required this.strapMaterialController,
    required this.warrantyController,
    required this.stockController,
    required this.variantsController,
    required this.category,
    required this.isActive,
    required this.waterResistant,
    required this.isFeatured,
    required this.isTrending,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onWaterResistantChanged,
    required this.onFeaturedChanged,
    required this.onTrendingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if ((value ?? '').trim().length < 3) {
              return 'Enter a product name';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Name',
            prefixIcon: const Icon(Icons.sell_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: brandController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Brand',
            prefixIcon: const Icon(Icons.workspace_premium_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 520;
            final dial = TextFormField(
              controller: dialColorController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Dial color',
                prefixIcon: const Icon(Icons.palette_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            final strap = TextFormField(
              controller: strapMaterialController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Strap material',
                prefixIcon: const Icon(Icons.watch_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: dial),
                  const SizedBox(width: 12),
                  Expanded(child: strap),
                ],
              );
            }
            return Column(children: [dial, const SizedBox(height: 14), strap]);
          },
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 520;
            final warranty = TextFormField(
              controller: warrantyController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Warranty',
                prefixIcon: const Icon(Icons.verified_user_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            final stock = TextFormField(
              controller: stockController,
              keyboardType: TextInputType.number,
              validator: (value) {
                final raw = (value ?? '').trim();
                if (raw.isEmpty) {
                  return null;
                }
                final stock = int.tryParse(raw);
                if (stock == null || stock < 0) {
                  return 'Use 0 or more';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Stock quantity',
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: warranty),
                  const SizedBox(width: 12),
                  Expanded(child: stock),
                ],
              );
            }
            return Column(
              children: [warranty, const SizedBox(height: 14), stock],
            );
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: descriptionController,
          minLines: 3,
          maxLines: 5,
          validator: (value) {
            if ((value ?? '').trim().length < 12) {
              return 'Enter a useful description';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Description',
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.notes_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 520;
            final priceField = TextFormField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final price = double.tryParse((value ?? '').trim());
                if (price == null || price <= 0) {
                  return 'Enter a valid price';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Price',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            final discountField = TextFormField(
              controller: discountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final raw = (value ?? '').trim();
                if (raw.isEmpty) {
                  return null;
                }
                final discount = double.tryParse(raw);
                if (discount == null || discount < 0 || discount > 100) {
                  return 'Use 0 to 100';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Discount %',
                prefixIcon: const Icon(Icons.percent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: priceField),
                  const SizedBox(width: 12),
                  Expanded(child: discountField),
                ],
              );
            }

            return Column(
              children: [priceField, const SizedBox(height: 14), discountField],
            );
          },
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: category,
          decoration: InputDecoration(
            labelText: 'Category',
            prefixIcon: const Icon(Icons.category_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: AdminProduct.categories
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onCategoryChanged(value);
            }
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: variantsController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Variants',
            helperText: 'Use Dial/Strap/Stock, one variant per line',
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.tune_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: waterResistant,
          onChanged: onWaterResistantChanged,
          title: const Text(
            'Water resistant',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: const Text('Shown as a product specification.'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isFeatured,
          onChanged: onFeaturedChanged,
          title: const Text(
            'Featured watch',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: const Text('Use for premium placements and banners.'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isTrending,
          onChanged: onTrendingChanged,
          title: const Text(
            'Trending tag',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: const Text('Highlights high-demand watches.'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isActive,
          onChanged: onStatusChanged,
          title: const Text(
            'Active product',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: const Text('Inactive products stay stored but hidden.'),
        ),
      ],
    );
  }
}

class _ImagePickerPanel extends StatelessWidget {
  final List<String> existingImageUrls;
  final List<Uint8List> pickedImageBytes;
  final String? imageError;
  final bool isPicking;
  final VoidCallback onPickImage;

  const _ImagePickerPanel({
    required this.existingImageUrls,
    required this.pickedImageBytes,
    required this.imageError,
    required this.isPicking,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    Widget preview;
    if (pickedImageBytes.isNotEmpty) {
      preview = Image.memory(pickedImageBytes.first, fit: BoxFit.cover);
    } else if (existingImageUrls.isNotEmpty) {
      preview = Image.network(
        existingImageUrls.first,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.broken_image_outlined,
          color: AppColors.textLight,
          size: 42,
        ),
      );
    } else {
      preview = const Icon(
        Icons.add_photo_alternate_outlined,
        color: AppColors.textLight,
        size: 46,
      );
    }
    final thumbnailCount = pickedImageBytes.isNotEmpty
        ? pickedImageBytes.length
        : existingImageUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: AppColors.surface,
              child: Center(child: preview),
            ),
          ),
        ),
        if (thumbnailCount > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: thumbnailCount,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final child = pickedImageBytes.isNotEmpty
                    ? Image.memory(pickedImageBytes[index], fit: BoxFit.cover)
                    : Image.network(
                        existingImageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.textLight,
                            ),
                      );
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 54,
                    height: 54,
                    color: AppColors.surface,
                    child: child,
                  ),
                );
              },
            ),
          ),
        ],
        if (imageError != null) ...[
          const SizedBox(height: 8),
          Text(
            imageError!,
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: isPicking ? null : onPickImage,
            icon: isPicking
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.collections_outlined),
            label: Text(isPicking ? 'Opening' : 'Upload Images'),
          ),
        ),
      ],
    );
  }
}
