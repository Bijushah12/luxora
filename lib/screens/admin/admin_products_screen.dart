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
  String _categoryFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
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

    return products
        .where((product) {
          final matchesCategory =
              _categoryFilter == 'All' || product.category == _categoryFilter;
          final matchesSearch =
              query.isEmpty ||
              product.name.toLowerCase().contains(query) ||
              product.brand.toLowerCase().contains(query) ||
              product.description.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query);

          return matchesCategory && matchesSearch;
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
                      _ProductToolbar(
                        controller: _searchController,
                        categoryFilter: _categoryFilter,
                        onChanged: () => setState(() {}),
                        onCategoryChanged: (value) {
                          setState(() => _categoryFilter = value);
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
}

class _ProductToolbar extends StatelessWidget {
  final TextEditingController controller;
  final String categoryFilter;
  final VoidCallback onChanged;
  final ValueChanged<String> onCategoryChanged;

  const _ProductToolbar({
    required this.controller,
    required this.categoryFilter,
    required this.onChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 680;
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

        if (isWide) {
          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 14),
              SizedBox(width: 220, child: category),
            ],
          );
        }

        return Column(children: [search, const SizedBox(height: 12), category]);
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
            headingTextStyle: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
            ),
            columns: const [
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Discount')),
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
                          _ProductImage(imageUrl: product.imageUrl, size: 54),
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
                                  product.description,
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
                  DataCell(Text(product.category)),
                  DataCell(Text('Rs ${product.price.toStringAsFixed(2)}')),
                  DataCell(Text('${product.discount.toStringAsFixed(0)}%')),
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
          _ProductImage(imageUrl: product.imageUrl, size: 74),
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
                  product.category,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Rs ${product.price.toStringAsFixed(2)}',
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

  late String _category;
  bool _isActive = true;
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
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
    _category = product.category;
    _isActive = product.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
      _imageError = null;
    });

    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        imageQuality: 86,
      );
      if (image == null) {
        return;
      }
      final bytes = await image.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _pickedImage = image;
        _pickedImageBytes = bytes;
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
    final hasExistingImage = (existing?.imageUrl ?? '').trim().isNotEmpty;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickedImage == null && !hasExistingImage) {
      setState(() => _imageError = 'Upload a product image');
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
      isActive: _isActive,
    );

    final ok = await context.read<AdminProductsProvider>().saveProduct(
      product,
      image: _pickedImage,
    );

    if (ok && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProductsProvider>();
    final title = _editingProduct == null ? 'Add Product' : 'Edit Product';

    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
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
                        category: _category,
                        isActive: _isActive,
                        onCategoryChanged: (value) {
                          setState(() => _category = value);
                        },
                        onStatusChanged: (value) {
                          setState(() => _isActive = value);
                        },
                      );
                      final imagePicker = _ImagePickerPanel(
                        existingImageUrl: _editingProduct?.imageUrl ?? '',
                        pickedImageBytes: _pickedImageBytes,
                        imageError: _imageError,
                        isPicking: _isPickingImage,
                        onPickImage: _pickImage,
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
  final String category;
  final bool isActive;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onStatusChanged;

  const _ProductFields({
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.discountController,
    required this.brandController,
    required this.category,
    required this.isActive,
    required this.onCategoryChanged,
    required this.onStatusChanged,
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
        const SizedBox(height: 10),
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
  final String existingImageUrl;
  final Uint8List? pickedImageBytes;
  final String? imageError;
  final bool isPicking;
  final VoidCallback onPickImage;

  const _ImagePickerPanel({
    required this.existingImageUrl,
    required this.pickedImageBytes,
    required this.imageError,
    required this.isPicking,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    Widget preview;
    if (pickedImageBytes != null) {
      preview = Image.memory(pickedImageBytes!, fit: BoxFit.cover);
    } else if (existingImageUrl.trim().isNotEmpty) {
      preview = Image.network(
        existingImageUrl,
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
                : const Icon(Icons.upload_file),
            label: Text(isPicking ? 'Opening' : 'Upload Image'),
          ),
        ),
      ],
    );
  }
}
