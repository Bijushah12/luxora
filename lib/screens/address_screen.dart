import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_address.dart';
import '../providers/address_provider.dart';
import '../theme/app_colors.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  Future<void> _openAddressSheet(
    BuildContext context, {
    AppAddress? address,
  }) async {
    final result = await showModalBottomSheet<AppAddress>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressFormSheet(address: address),
    );

    if (result == null || !context.mounted) return;

    final provider = context.read<AddressProvider>();
    if (address == null) {
      await provider.addAddress(result);
    } else {
      await provider.updateAddress(result);
    }
  }

  Future<void> _confirmDelete(BuildContext context, AppAddress address) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Address'),
        content: Text('Remove ${address.label} from your saved addresses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      await context.read<AddressProvider>().removeAddress(address.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Shipping Address',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Add address',
            onPressed: () => _openAddressSheet(context),
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
        ],
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          if (!provider.isLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          final addresses = provider.addresses;
          if (addresses.isEmpty) {
            return _EmptyAddressState(onAdd: () => _openAddressSheet(context));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _AddressSummary(count: addresses.length),
              const SizedBox(height: 16),
              ...addresses.map(
                (address) => _AddressCard(
                  address: address,
                  onEdit: () => _openAddressSheet(context, address: address),
                  onDelete: () => _confirmDelete(context, address),
                  onSetDefault: () => provider.setDefaultAddress(address.id),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _openAddressSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Address'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddressSummary extends StatelessWidget {
  final int count;

  const _AddressSummary({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count saved ${count == 1 ? 'address' : 'addresses'}',
                  style: const TextStyle(
                    color: AppColors.textInverse,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a default address for faster checkout.',
                  style: TextStyle(
                    color: AppColors.textInverse.withValues(alpha: 0.72),
                    fontSize: 12,
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

class _AddressCard extends StatelessWidget {
  final AppAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: address.isDefault ? AppColors.accent : AppColors.border,
          width: address.isDefault ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForLabel(address.label),
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          _DefaultChip(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.fullName,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'default') onSetDefault();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (!address.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Text('Make Default'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            address.addressLine,
            style: const TextStyle(color: AppColors.textLight, height: 1.5),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                color: AppColors.textLight,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                address.phone,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForLabel(String label) {
    final value = label.toLowerCase();
    if (value.contains('office') || value.contains('work')) {
      return Icons.business_outlined;
    }
    if (value.contains('other')) {
      return Icons.location_on_outlined;
    }
    return Icons.home_outlined;
  }
}

class _DefaultChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Default',
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyAddressState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyAddressState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 40,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No saved address',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your delivery address to make checkout faster.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, height: 1.5),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  final AppAddress? address;

  const _AddressFormSheet({this.address});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late String _label;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _label = address?.label ?? 'Home';
    _isDefault = address?.isDefault ?? false;
    _fullNameController = TextEditingController(text: address?.fullName ?? '');
    _phoneController = TextEditingController(text: address?.phone ?? '');
    _addressController = TextEditingController(
      text: address?.addressLine ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().microsecondsSinceEpoch;
    Navigator.pop(
      context,
      AppAddress(
        id: widget.address?.id ?? 'address-$now',
        label: _label,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine: _addressController.text.trim(),
        isDefault: _isDefault,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEditing ? 'Edit Address' : 'Add Address',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    children: ['Home', 'Office', 'Other'].map((label) {
                      return ChoiceChip(
                        label: Text(label),
                        selected: _label == label,
                        onSelected: (_) => setState(() => _label = label),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _AddressTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().length < 2) {
                        return 'Enter a valid name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _AddressTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().length < 10) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _AddressTextField(
                    controller: _addressController,
                    label: 'Complete Address',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().length < 10) {
                        return 'Enter a complete address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() => _isDefault = value ?? false);
                    },
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.accent,
                    title: const Text(
                      'Make this my default address',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(isEditing ? 'Save Changes' : 'Save Address'),
                    ),
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

class _AddressTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _AddressTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.accent),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}
