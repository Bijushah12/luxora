import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_coupon.dart';
import '../../providers/admin_coupons_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/admin/admin_empty_state.dart';
import '../../widgets/admin/admin_feedback.dart';
import '../../widgets/admin/admin_luxury_widgets.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  final _searchController = TextEditingController();
  bool _activeOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCouponForm([AdminCoupon? coupon]) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AdminCouponsProvider>(),
        child: _CouponFormDialog(coupon: coupon),
      ),
    );
  }

  List<AdminCoupon> _filterCoupons(List<AdminCoupon> coupons) {
    final query = _searchController.text.trim().toLowerCase();
    return coupons
        .where((coupon) {
          final matchesStatus =
              !_activeOnly || (coupon.isActive && !coupon.isExpired);
          final matchesQuery =
              query.isEmpty ||
              coupon.code.toLowerCase().contains(query) ||
              coupon.title.toLowerCase().contains(query);
          return matchesStatus && matchesQuery;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminCouponsProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<AdminCoupon>>(
          stream: provider.couponsStream(),
          builder: (context, snapshot) {
            final coupons = snapshot.data ?? const <AdminCoupon>[];
            final filteredCoupons = _filterCoupons(coupons);

            return AdminLuxuryBackground(
              child: ListView(
                children: [
                  AdminFeedbackBanner(
                    error: provider.errorMessage,
                    success: provider.successMessage,
                    onClose: provider.clearMessages,
                  ),
                  AdminGlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdminSectionHeader(
                          icon: Icons.confirmation_number_outlined,
                          title: 'Coupon Management',
                          subtitle:
                              'Create premium offers, control usage limits, and sync discounts with Firestore.',
                          trailing: ElevatedButton.icon(
                            onPressed: () => _openCouponForm(),
                            icon: const Icon(Icons.add),
                            label: const Text('New Coupon'),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _CouponSummary(coupons: coupons),
                        const SizedBox(height: 18),
                        _CouponToolbar(
                          controller: _searchController,
                          activeOnly: _activeOnly,
                          onSearchChanged: (_) => setState(() {}),
                          onActiveOnlyChanged: (value) {
                            setState(() => _activeOnly = value);
                          },
                        ),
                        const SizedBox(height: 18),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: const LinearProgressIndicator(
                              minHeight: 4,
                              color: AppColors.accent,
                            ),
                          )
                        else if (snapshot.hasError)
                          _DarkError(message: snapshot.error.toString())
                        else if (coupons.isEmpty)
                          SizedBox(
                            height: 320,
                            child: AdminEmptyState(
                              icon: Icons.confirmation_number_outlined,
                              title: 'No coupons yet',
                              message:
                                  'Create your first Luxora coupon for campaigns.',
                              action: ElevatedButton.icon(
                                onPressed: () => _openCouponForm(),
                                icon: const Icon(Icons.add),
                                label: const Text('Create Coupon'),
                              ),
                            ),
                          )
                        else if (filteredCoupons.isEmpty)
                          const SizedBox(
                            height: 260,
                            child: AdminEmptyState(
                              icon: Icons.search_off,
                              title: 'No matching coupons',
                              message: 'Adjust search text or filters.',
                            ),
                          )
                        else
                          _CouponsGrid(
                            coupons: filteredCoupons,
                            provider: provider,
                            onEdit: _openCouponForm,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CouponSummary extends StatelessWidget {
  final List<AdminCoupon> coupons;

  const _CouponSummary({required this.coupons});

  @override
  Widget build(BuildContext context) {
    final active = coupons
        .where((coupon) => coupon.isActive && !coupon.isExpired)
        .length;
    final expired = coupons.where((coupon) => coupon.isExpired).length;
    final used = coupons.fold<int>(0, (sum, coupon) => sum + coupon.usedCount);

    return AdminResponsiveGrid(
      minItemWidth: 210,
      children: [
        _SummaryTile(label: 'Total Coupons', value: coupons.length.toString()),
        _SummaryTile(label: 'Active', value: active.toString()),
        _SummaryTile(label: 'Expired', value: expired.toString()),
        _SummaryTile(label: 'Total Uses', value: used.toString()),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textInverse,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponToolbar extends StatelessWidget {
  final TextEditingController controller;
  final bool activeOnly;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onActiveOnlyChanged;

  const _CouponToolbar({
    required this.controller,
    required this.activeOnly,
    required this.onSearchChanged,
    required this.onActiveOnlyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = AdminLuxuryTextField(
          controller: controller,
          label: 'Search coupons',
          icon: Icons.search,
          onChanged: onSearchChanged,
        );
        final toggle = SwitchListTile.adaptive(
          value: activeOnly,
          onChanged: onActiveOnlyChanged,
          activeThumbColor: AppColors.accent,
          title: const Text(
            'Active only',
            style: TextStyle(
              color: AppColors.textInverse,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: const Text(
            'Hide expired and paused offers',
            style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 12),
          ),
        );

        if (constraints.maxWidth >= 720) {
          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 14),
              SizedBox(width: 260, child: toggle),
            ],
          );
        }
        return Column(children: [search, const SizedBox(height: 10), toggle]);
      },
    );
  }
}

class _CouponsGrid extends StatelessWidget {
  final List<AdminCoupon> coupons;
  final AdminCouponsProvider provider;
  final ValueChanged<AdminCoupon> onEdit;

  const _CouponsGrid({
    required this.coupons,
    required this.provider,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AdminResponsiveGrid(
      minItemWidth: 310,
      children: coupons
          .map(
            (coupon) => _CouponCard(
              coupon: coupon,
              isDeleting: provider.isDeleting(coupon.id),
              onEdit: () => onEdit(coupon),
              onDelete: () => provider.delete(coupon.id),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final AdminCoupon coupon;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CouponCard({
    required this.coupon,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = coupon.isExpired
        ? AppColors.error
        : coupon.isActive
        ? AppColors.success
        : AppColors.warning;
    final status = coupon.isExpired
        ? 'Expired'
        : coupon.isActive
        ? 'Active'
        : 'Paused';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  coupon.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              AdminStatusPill(label: status, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            coupon.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textInverse,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CouponDetail(
                  label: 'Discount',
                  value: coupon.displayDiscount,
                ),
              ),
              Expanded(
                child: _CouponDetail(
                  label: 'Min Order',
                  value: 'Rs ${coupon.minOrderValue.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _CouponDetail(
                  label: 'Uses',
                  value: '${coupon.usedCount}/${coupon.maxUses}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Delete coupon',
                onPressed: isDeleting ? null : onDelete,
                icon: isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CouponDetail extends StatelessWidget {
  final String label;
  final String value;

  const _CouponDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFD1D5DB),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textInverse,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CouponFormDialog extends StatefulWidget {
  final AdminCoupon? coupon;

  const _CouponFormDialog({this.coupon});

  @override
  State<_CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends State<_CouponFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _discountController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _maxUsesController = TextEditingController();
  final _expiryController = TextEditingController();
  String _discountType = 'percentage';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final coupon = widget.coupon;
    if (coupon != null) {
      _codeController.text = coupon.code;
      _titleController.text = coupon.title;
      _discountController.text = coupon.discountValue.toStringAsFixed(0);
      _minOrderController.text = coupon.minOrderValue.toStringAsFixed(0);
      _maxUsesController.text = coupon.maxUses.toString();
      _expiryController.text = coupon.expiresAt == null
          ? ''
          : _formatDate(coupon.expiresAt!);
      _discountType = coupon.discountType;
      _isActive = coupon.isActive;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _discountController.dispose();
    _minOrderController.dispose();
    _maxUsesController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _save(AdminCouponsProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final coupon = (widget.coupon ?? AdminCoupon.empty()).copyWith(
      code: _codeController.text,
      title: _titleController.text,
      discountType: _discountType,
      discountValue: double.tryParse(_discountController.text.trim()) ?? 0,
      minOrderValue: double.tryParse(_minOrderController.text.trim()) ?? 0,
      maxUses: int.tryParse(_maxUsesController.text.trim()) ?? 0,
      isActive: _isActive,
      expiresAt: _expiryController.text.trim().isEmpty
          ? null
          : DateTime.tryParse(_expiryController.text.trim()),
    );
    final saved = await provider.save(coupon);
    if (saved && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminCouponsProvider>(
      builder: (context, provider, child) {
        return AlertDialog(
          title: Text(widget.coupon == null ? 'Create Coupon' : 'Edit Coupon'),
          content: SizedBox(
            width: 560,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Coupon Code',
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _discountType,
                      decoration: const InputDecoration(
                        labelText: 'Discount Type',
                        prefixIcon: Icon(Icons.percent_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'percentage',
                          child: Text('Percentage'),
                        ),
                        DropdownMenuItem(value: 'flat', child: Text('Flat')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _discountType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Discount',
                              prefixIcon: Icon(Icons.local_offer_outlined),
                            ),
                            validator: _number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _minOrderController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Min Order',
                              prefixIcon: Icon(Icons.currency_rupee),
                            ),
                            validator: _number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _maxUsesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max Uses',
                              prefixIcon: Icon(Icons.repeat_outlined),
                            ),
                            validator: _integer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _expiryController,
                            decoration: const InputDecoration(
                              labelText: 'Expiry yyyy-mm-dd',
                              prefixIcon: Icon(Icons.event_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                      title: const Text('Active Coupon'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: provider.isSaving
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: provider.isSaving ? null : () => _save(provider),
              icon: provider.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(provider.isSaving ? 'Saving' : 'Save Coupon'),
            ),
          ],
        );
      },
    );
  }
}

class _DarkError extends StatelessWidget {
  final String message;

  const _DarkError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.24)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textInverse,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String? _number(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) {
    return 'Required';
  }
  if (double.tryParse(raw) == null) {
    return 'Enter a number';
  }
  return null;
}

String? _integer(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) {
    return 'Required';
  }
  if (int.tryParse(raw) == null) {
    return 'Enter a whole number';
  }
  return null;
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
