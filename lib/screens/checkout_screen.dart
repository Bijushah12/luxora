import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_address.dart';
import '../providers/address_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _flatController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String _deliveryOption = 'standard';
  String _paymentOption = 'upi';
  String _addressType = 'home';
  bool _makeDefaultAddress = false;

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    _flatController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  double _shippingFor(double subtotal) {
    if (subtotal <= 0 || subtotal >= 5000) {
      return 0;
    }
    return _deliveryOption == 'express' ? 199 : 99;
  }

  double _taxFor(double subtotal) => subtotal * 0.03;

  double _discountFor(double subtotal) =>
      subtotal >= 25000 ? subtotal * 0.08 : 0;

  Map<String, String> _areaForPincode(String pincode) {
    final prefix = pincode.substring(0, 2);
    final areas = {
      '11': {'city': 'New Delhi', 'state': 'Delhi'},
      '30': {'city': 'Jaipur', 'state': 'Rajasthan'},
      '36': {'city': 'Rajkot', 'state': 'Gujarat'},
      '38': {'city': 'Ahmedabad', 'state': 'Gujarat'},
      '40': {'city': 'Mumbai', 'state': 'Maharashtra'},
      '50': {'city': 'Hyderabad', 'state': 'Telangana'},
      '56': {'city': 'Bengaluru', 'state': 'Karnataka'},
      '60': {'city': 'Chennai', 'state': 'Tamil Nadu'},
      '70': {'city': 'Kolkata', 'state': 'West Bengal'},
    };

    return areas[prefix] ?? {'city': 'Your City', 'state': 'Your State'};
  }

  void _showContactDetailsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              18,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Contact Details',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _CheckoutField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (_) => null,
                ),
                const SizedBox(height: 12),
                _CheckoutField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.call_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (_) => null,
                ),
                const SizedBox(height: 12),
                _CheckoutField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (_) => null,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textInverse,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'SAVE DETAILS',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _detectLocation() {
    final locationPincodeController = TextEditingController(
      text: _pincodeController.text,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        String errorText = '';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Detect Delivery Location',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Enter your current pincode and we will fill city and state automatically.',
                      style: TextStyle(
                        color: AppColors.textLight,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: locationPincodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Current Pincode',
                        errorText: errorText.isEmpty ? null : errorText,
                        prefixIcon: const Icon(
                          Icons.my_location,
                          color: AppColors.textLight,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          final pincode = locationPincodeController.text.trim();
                          if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(pincode)) {
                            setSheetState(
                              () => errorText =
                                  'Enter a valid 6-digit Indian pincode',
                            );
                            return;
                          }

                          final area = _areaForPincode(pincode);
                          setState(() {
                            _pincodeController.text = pincode;
                            _cityController.text = area['city']!;
                            _stateController.text = area['state']!;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textInverse,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'USE THIS LOCATION',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(locationPincodeController.dispose);
  }

  Future<void> _proceedToPayment(CartProvider cart) async {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final subtotal = cart.totalPrice;
    final shipping = _shippingFor(subtotal);
    final tax = _taxFor(subtotal);
    final discount = _discountFor(subtotal);
    final grandTotal = subtotal + shipping + tax - discount;
    final flat = _flatController.text.trim();
    final addressLine = _addressController.text.trim();
    final line1 = [
      if (flat.isNotEmpty) flat,
      addressLine,
    ].where((part) => part.trim().isNotEmpty).join(', ');
    final deliveryAddress = {
      'fullName': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'line1': line1,
      'address': addressLine,
      'flat': flat,
      'line2': _landmarkController.text.trim(),
      'landmark': _landmarkController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'addressType': _addressType,
      'makeDefault': _makeDefaultAddress,
    };

    if (_makeDefaultAddress) {
      await context.read<AddressProvider>().addAddress(
        AppAddress(
          id: 'checkout-${DateTime.now().microsecondsSinceEpoch}',
          label: _labelForAddressType(_addressType),
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          addressLine: [
            line1,
            _landmarkController.text.trim(),
            _cityController.text.trim(),
            _stateController.text.trim(),
            _pincodeController.text.trim(),
          ].where((part) => part.trim().isNotEmpty).join(', '),
          isDefault: true,
        ),
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          subtotal: subtotal,
          shipping: shipping,
          tax: tax,
          discount: discount,
          total: grandTotal,
          itemCount: cart.totalItems,
          preferredMethod: _paymentOption,
          deliveryOption: _deliveryOption,
          address: deliveryAddress,
        ),
      ),
    );
  }

  String _labelForAddressType(String value) {
    switch (value) {
      case 'office':
        return 'Office';
      case 'other':
        return 'Other';
      default:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final cartItems = cart.items.values.toList();
        final subtotal = cart.totalPrice;
        final shipping = _shippingFor(subtotal);
        final tax = _taxFor(subtotal);
        final discount = _discountFor(subtotal);
        final grandTotal = subtotal + shipping + tax - discount;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldBg,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textDark),
            title: const Text(
              'Checkout',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            centerTitle: true,
          ),
          body: cartItems.isEmpty
              ? const _EmptyCheckout()
              : Column(
                  children: [
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                          children: [
                            const _CheckoutStepper(),
                            const SizedBox(height: 22),
                            _SectionCard(
                              title: 'Add New Address',
                              icon: Icons.location_on_outlined,
                              child: _AddressForm(
                                contactName: _nameController.text.trim(),
                                contactEmail: _emailController.text.trim(),
                                addressController: _addressController,
                                flatController: _flatController,
                                landmarkController: _landmarkController,
                                phoneController: _phoneController,
                                pincodeController: _pincodeController,
                                cityController: _cityController,
                                stateController: _stateController,
                                makeDefaultAddress: _makeDefaultAddress,
                                addressType: _addressType,
                                onContactTap: _showContactDetailsSheet,
                                onDetectLocation: _detectLocation,
                                onDefaultChanged: (value) {
                                  setState(
                                    () => _makeDefaultAddress = value ?? false,
                                  );
                                },
                                onAddressTypeChanged: (value) {
                                  setState(() => _addressType = value);
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Delivery Speed',
                              icon: Icons.local_shipping_outlined,
                              child: Column(
                                children: [
                                  _ChoiceTile(
                                    title: 'Standard Delivery',
                                    subtitle: subtotal >= 5000
                                        ? 'Free delivery in 3-5 days'
                                        : 'Rs 99, delivery in 3-5 days',
                                    value: 'standard',
                                    groupValue: _deliveryOption,
                                    onChanged: (value) =>
                                        setState(() => _deliveryOption = value),
                                  ),
                                  const Divider(height: 1),
                                  _ChoiceTile(
                                    title: 'Express Delivery',
                                    subtitle: subtotal >= 5000
                                        ? 'Free priority delivery in 1-2 days'
                                        : 'Rs 199, delivery in 1-2 days',
                                    value: 'express',
                                    groupValue: _deliveryOption,
                                    onChanged: (value) =>
                                        setState(() => _deliveryOption = value),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Payment Preference',
                              icon: Icons.payments_outlined,
                              child: Column(
                                children: [
                                  _ChoiceTile(
                                    title: 'UPI / Wallet',
                                    subtitle: 'Fast and secure digital payment',
                                    value: 'upi',
                                    groupValue: _paymentOption,
                                    onChanged: (value) =>
                                        setState(() => _paymentOption = value),
                                  ),
                                  const Divider(height: 1),
                                  _ChoiceTile(
                                    title: 'Cash on Delivery',
                                    subtitle: 'Pay after the order reaches you',
                                    value: 'cod',
                                    groupValue: _paymentOption,
                                    onChanged: (value) =>
                                        setState(() => _paymentOption = value),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Order Summary',
                              icon: Icons.receipt_long_outlined,
                              trailing: '${cart.totalItems} items',
                              child: Column(
                                children: [
                                  ...cartItems.map(
                                    (item) => _CheckoutItem(
                                      item: item,
                                      onIncrease: () =>
                                          cart.increaseQty(item.watch.id),
                                      onDecrease: () =>
                                          cart.decreaseQty(item.watch.id),
                                      onRemove: () =>
                                          cart.removeFromCart(item.watch.id),
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  _PriceRow(label: 'Subtotal', value: subtotal),
                                  _PriceRow(
                                    label: 'Shipping',
                                    value: shipping,
                                    freeText: shipping == 0 ? 'Free' : null,
                                  ),
                                  _PriceRow(label: 'Taxes & fees', value: tax),
                                  if (discount > 0)
                                    _PriceRow(
                                      label: 'Member discount',
                                      value: -discount,
                                      isDiscount: true,
                                    ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Grand Total',
                                        style: TextStyle(
                                          color: AppColors.textDark,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        'Rs ${grandTotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AppColors.success,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _CheckoutBottomBar(
                      total: grandTotal,
                      onCancel: () => Navigator.of(context).pop(),
                      onPressed: () => _proceedToPayment(cart),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _EmptyCheckout extends StatelessWidget {
  const _EmptyCheckout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.textLight.withValues(alpha: 0.5),
            size: 76,
          ),
          const SizedBox(height: 14),
          const Text(
            'No items to checkout',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add a watch to your cart first.',
            style: TextStyle(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final String? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CheckoutStepper extends StatelessWidget {
  const _CheckoutStepper();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: const [
          Expanded(child: _StepLabel(text: '01 Cart', isDone: true)),
          _StepLine(),
          Expanded(
            child: _StepLabel(text: '02 Delivery Information', isActive: true),
          ),
          _StepLine(),
          Expanded(child: _StepLabel(text: '03 Payment')),
        ],
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final String text;
  final bool isActive;
  final bool isDone;

  const _StepLabel({
    required this.text,
    this.isActive = false,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isActive
            ? AppColors.accent
            : isDone
            ? AppColors.textDark
            : AppColors.textLight.withValues(alpha: 0.55),
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) {
    return Container(width: 28, height: 1, color: AppColors.border);
  }
}

class _AddressForm extends StatelessWidget {
  final String contactName;
  final String contactEmail;
  final TextEditingController addressController;
  final TextEditingController flatController;
  final TextEditingController landmarkController;
  final TextEditingController phoneController;
  final TextEditingController pincodeController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final bool makeDefaultAddress;
  final String addressType;
  final VoidCallback onContactTap;
  final VoidCallback onDetectLocation;
  final ValueChanged<bool?> onDefaultChanged;
  final ValueChanged<String> onAddressTypeChanged;

  const _AddressForm({
    required this.contactName,
    required this.contactEmail,
    required this.addressController,
    required this.flatController,
    required this.landmarkController,
    required this.phoneController,
    required this.pincodeController,
    required this.cityController,
    required this.stateController,
    required this.makeDefaultAddress,
    required this.addressType,
    required this.onContactTap,
    required this.onDetectLocation,
    required this.onDefaultChanged,
    required this.onAddressTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        Widget rowOrColumn(Widget first, Widget second) {
          if (!isWide) {
            return Column(
              children: [first, const SizedBox(height: 14), second],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 18),
              Expanded(child: second),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onContactTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: AppColors.textDark),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phoneController.text.trim().isEmpty
                                ? 'Add contact details for this order'
                                : '${contactName.isEmpty ? 'Contact' : contactName}, +91 ${phoneController.text.trim()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (contactEmail.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              contactEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: SizedBox(
                width: isWide ? 430 : double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: onDetectLocation,
                  icon: const Icon(Icons.my_location, size: 20),
                  label: const Text(
                    'DETECT MY LOCATION',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textInverse,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Click to use current Location',
                style: TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            rowOrColumn(
              _CheckoutField(
                controller: addressController,
                label: 'Address (Building Name, Street, Area) *',
                icon: Icons.home_outlined,
                maxLines: 5,
                helperText: 'Example: Prestige apartment, Electronic city',
                validator: (value) {
                  if (value == null || value.trim().length < 12) {
                    return 'Enter a complete address';
                  }
                  return null;
                },
              ),
              Column(
                children: [
                  _CheckoutField(
                    controller: flatController,
                    label: 'Flat/House Number',
                    icon: Icons.apartment_outlined,
                    helperText: 'Example: F-106',
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 14),
                  _CheckoutField(
                    controller: landmarkController,
                    label: 'Landmark',
                    icon: Icons.place_outlined,
                    validator: (_) => null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            rowOrColumn(
              _CheckoutField(
                controller: pincodeController,
                label: 'Pincode *',
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final pin = value?.trim() ?? '';
                  if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(pin)) {
                    return 'Enter valid pincode';
                  }
                  return null;
                },
              ),
              _CheckoutField(
                controller: cityController,
                label: 'City *',
                icon: Icons.location_city_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter city';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 18),
            rowOrColumn(
              _CheckoutField(
                controller: stateController,
                label: 'State *',
                icon: Icons.map_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter state';
                  }
                  return null;
                },
              ),
              _CheckoutField(
                controller: phoneController,
                label: 'Phone Number *',
                icon: Icons.call_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final phone = value?.trim() ?? '';
                  if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
                    return 'Enter valid 10-digit number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: makeDefaultAddress,
              onChanged: onDefaultChanged,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Make this my default address',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _AddressTypeChip(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  selected: addressType == 'home',
                  onTap: () => onAddressTypeChanged('home'),
                ),
                _AddressTypeChip(
                  label: 'Office',
                  icon: Icons.work_outline,
                  selected: addressType == 'office',
                  onTap: () => onAddressTypeChanged('office'),
                ),
                _AddressTypeChip(
                  label: 'Other',
                  icon: Icons.person_outline,
                  selected: addressType == 'other',
                  onTap: () => onAddressTypeChanged('other'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _AddressTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _AddressTypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.textInverse : AppColors.textDark,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.textInverse : AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? helperText;
  final String? Function(String?) validator;

  const _CheckoutField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon, color: AppColors.textLight),
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _ChoiceTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.accent : AppColors.textLight,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
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
    );
  }
}

class _CheckoutItem extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CheckoutItem({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final watch = item.watch;
    final itemTotal = watch.price * item.quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              watch.image,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 64,
                height: 64,
                color: AppColors.surface,
                child: const Icon(Icons.watch, color: AppColors.textLight),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  watch.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${watch.brand} | ${watch.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QtyButton(icon: Icons.remove, onTap: onDecrease),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _QtyButton(icon: Icons.add, onTap: onIncrease),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onRemove,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rs ${itemTotal.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 16, color: AppColors.textDark),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final String? freeText;
  final bool isDiscount;

  const _PriceRow({
    required this.label,
    required this.value,
    this.freeText,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            freeText ??
                '${isDiscount ? '-' : ''}Rs ${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: isDiscount || freeText != null
                  ? AppColors.success
                  : AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  final double total;
  final VoidCallback onCancel;
  final VoidCallback onPressed;

  const _CheckoutBottomBar({
    required this.total,
    required this.onCancel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textInverse,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'ADD ADDRESS - Rs ${total.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
