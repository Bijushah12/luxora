import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_storefront_settings.dart';
import '../../providers/admin_settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin/admin_feedback.dart';
import '../../widgets/admin/admin_section.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoriesController = TextEditingController();
  final _brandsController = TextEditingController();
  final _discountController = TextEditingController();
  final _bannersController = TextEditingController();
  String? _loadedSignature;

  @override
  void dispose() {
    _categoriesController.dispose();
    _brandsController.dispose();
    _discountController.dispose();
    _bannersController.dispose();
    super.dispose();
  }

  void _sync(AdminStorefrontSettings settings) {
    final signature = [
      settings.categories.join('|'),
      settings.brands.join('|'),
      settings.globalDiscount.toStringAsFixed(2),
      settings.bannerUrls.join('|'),
    ].join('::');
    if (_loadedSignature == signature) {
      return;
    }
    _loadedSignature = signature;
    _categoriesController.text = settings.categories.join('\n');
    _brandsController.text = settings.brands.join('\n');
    _discountController.text = settings.globalDiscount == 0
        ? ''
        : settings.globalDiscount.toStringAsFixed(0);
    _bannersController.text = settings.bannerUrls.join('\n');
  }

  Future<void> _save(AdminSettingsProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final settings = AdminStorefrontSettings(
      categories: _lines(_categoriesController.text),
      brands: _lines(_brandsController.text),
      globalDiscount: double.tryParse(_discountController.text.trim()) ?? 0,
      bannerUrls: _lines(_bannersController.text),
    );
    await provider.save(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminSettingsProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<AdminStorefrontSettings>(
          stream: provider.settingsStream(),
          builder: (context, snapshot) {
            final settings =
                snapshot.data ?? AdminStorefrontSettings.defaults();
            _sync(settings);

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AdminFeedbackBanner(
                  error: provider.errorMessage,
                  success: provider.successMessage,
                  onClose: provider.clearMessages,
                ),
                AdminSection(
                  title: 'Admin Settings',
                  subtitle:
                      'Manage categories, brands, discounts, and storefront banners',
                  icon: Icons.settings_outlined,
                  child: Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 820;
                        final controls = [
                          _SettingsTextBox(
                            title: 'Categories',
                            icon: Icons.category_outlined,
                            controller: _categoriesController,
                            hint: 'Men\nWomen\nLuxury',
                          ),
                          _SettingsTextBox(
                            title: 'Brands',
                            icon: Icons.workspace_premium_outlined,
                            controller: _brandsController,
                            hint: 'Luxora\nRolex\nTitan',
                          ),
                          _DiscountBox(controller: _discountController),
                          _SettingsTextBox(
                            title: 'Banner URLs',
                            icon: Icons.image_outlined,
                            controller: _bannersController,
                            hint: 'https://...',
                            validatorRequired: false,
                          ),
                        ];

                        return Column(
                          children: [
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              const LinearProgressIndicator(minHeight: 3),
                            if (snapshot.hasError)
                              _InlineError(message: snapshot.error.toString()),
                            _SettingsSummaryStrip(settings: settings),
                            const SizedBox(height: 16),
                            if (isWide)
                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: controls
                                    .map(
                                      (control) => SizedBox(
                                        width: (constraints.maxWidth - 14) / 2,
                                        child: control,
                                      ),
                                    )
                                    .toList(growable: false),
                              )
                            else
                              Column(
                                children: controls
                                    .map(
                                      (control) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 14,
                                        ),
                                        child: control,
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                            const SizedBox(height: 18),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: provider.isSaving
                                      ? null
                                      : () => _save(provider),
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
                                  label: Text(
                                    provider.isSaving ? 'Saving' : 'Save',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> _lines(String value) {
    return value
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toSet()
        .toList();
  }
}

class _SettingsSummaryStrip extends StatelessWidget {
  final AdminStorefrontSettings settings;

  const _SettingsSummaryStrip({required this.settings});

  @override
  Widget build(BuildContext context) {
    return _AdminSummaryGrid(
      items: [
        _AdminSummaryItem(
          label: 'Categories',
          value: settings.categories.length.toString(),
          icon: Icons.category_outlined,
          color: AppColors.primary,
        ),
        _AdminSummaryItem(
          label: 'Brands',
          value: settings.brands.length.toString(),
          icon: Icons.workspace_premium_outlined,
          color: AppColors.accent,
        ),
        _AdminSummaryItem(
          label: 'Discount',
          value: '${settings.globalDiscount.toStringAsFixed(0)}%',
          icon: Icons.percent,
          color: AppColors.success,
        ),
        _AdminSummaryItem(
          label: 'Banners',
          value: settings.bannerUrls.length.toString(),
          icon: Icons.image_outlined,
          color: const Color(0xFF2563EB),
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
        if (constraints.maxWidth >= 760) {
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

class _SettingsTextBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final bool validatorRequired;

  const _SettingsTextBox({
    required this.title,
    required this.icon,
    required this.controller,
    required this.hint,
    this.validatorRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: 5,
      maxLines: 8,
      validator: validatorRequired
          ? (value) {
              if (_lines(value ?? '').isEmpty) {
                return 'Add at least one item';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: title,
        hintText: hint,
        alignLabelWithHint: true,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  List<String> _lines(String value) {
    return value
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
}

class _DiscountBox extends StatelessWidget {
  final TextEditingController controller;

  const _DiscountBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        labelText: 'Global discount %',
        helperText: 'Use this as a storefront-wide promotion control.',
        prefixIcon: const Icon(Icons.percent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
