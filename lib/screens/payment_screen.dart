import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_colors.dart';

enum _PaymentMethod { upi, card, netBanking, wallet, cod }

class PaymentScreen extends StatefulWidget {
  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;
  final int itemCount;
  final String preferredMethod;

  const PaymentScreen({
    super.key,
    this.subtotal = 0,
    this.shipping = 0,
    this.tax = 0,
    this.discount = 0,
    this.total = 0,
    this.itemCount = 0,
    this.preferredMethod = 'upi',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _upiController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  late _PaymentMethod _method;
  String _bank = 'HDFC Bank';
  String _wallet = 'Google Pay';
  bool _saveMethod = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _method = widget.preferredMethod == 'cod'
        ? _PaymentMethod.cod
        : _PaymentMethod.upi;
  }

  @override
  void dispose() {
    _upiController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String get _methodName {
    switch (_method) {
      case _PaymentMethod.upi:
        return 'UPI';
      case _PaymentMethod.card:
        return 'Card';
      case _PaymentMethod.netBanking:
        return 'Net Banking';
      case _PaymentMethod.wallet:
        return 'Wallet';
      case _PaymentMethod.cod:
        return 'Cash on Delivery';
    }
  }

  double _payableAmount(CartProvider cart) {
    if (widget.total > 0) {
      return widget.total;
    }
    return cart.totalPrice;
  }

  bool _hasCheckoutAmount(CartProvider cart) => _payableAmount(cart) > 0;

  Future<void> _payNow(CartProvider cart, OrderProvider orders) async {
    final amount = _payableAmount(cart);
    if (amount <= 0) {
      _showSnack('Add items to cart before making a payment.');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }

    final watches = cart.items.values.map((item) => item.watch).toList();
    orders.placeOrder(watches, amount);
    cart.clearCart();

    setState(() => _isProcessing = false);
    await _showSuccessSheet(amount);
  }

  Future<void> _showSuccessSheet(double amount) {
    final paymentId =
        'LUX${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(90) + 10}';

    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Payment Successful',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs ${amount.toStringAsFixed(2)} paid using $_methodName',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _InfoStrip(label: 'Transaction ID', value: paymentId),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textInverse,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'DONE',
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

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, OrderProvider>(
      builder: (context, cart, orders, child) {
        final amount = _payableAmount(cart);
        final hasCheckout = _hasCheckoutAmount(cart);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldBg,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textDark),
            title: Text(
              hasCheckout ? 'Secure Payment' : 'Payment Methods',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 118),
              children: [
                _PaymentHeader(
                  amount: amount,
                  itemCount: widget.itemCount == 0
                      ? cart.totalItems
                      : widget.itemCount,
                ),
                const SizedBox(height: 16),
                _SecurityBanner(methodName: _methodName),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Choose Payment Method',
                  icon: Icons.payments_outlined,
                  child: Column(
                    children: [
                      _MethodTile(
                        icon: Icons.qr_code_2,
                        title: 'UPI',
                        subtitle: 'Pay with any UPI app',
                        selected: _method == _PaymentMethod.upi,
                        onTap: () =>
                            setState(() => _method = _PaymentMethod.upi),
                      ),
                      _MethodTile(
                        icon: Icons.credit_card,
                        title: 'Credit / Debit Card',
                        subtitle: 'Visa, Mastercard, RuPay',
                        selected: _method == _PaymentMethod.card,
                        onTap: () =>
                            setState(() => _method = _PaymentMethod.card),
                      ),
                      _MethodTile(
                        icon: Icons.account_balance,
                        title: 'Net Banking',
                        subtitle: 'Pay from your bank account',
                        selected: _method == _PaymentMethod.netBanking,
                        onTap: () =>
                            setState(() => _method = _PaymentMethod.netBanking),
                      ),
                      _MethodTile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Wallet',
                        subtitle: 'Google Pay, Paytm, PhonePe',
                        selected: _method == _PaymentMethod.wallet,
                        onTap: () =>
                            setState(() => _method = _PaymentMethod.wallet),
                      ),
                      _MethodTile(
                        icon: Icons.money,
                        title: 'Cash on Delivery',
                        subtitle: 'Pay after delivery verification',
                        selected: _method == _PaymentMethod.cod,
                        onTap: () =>
                            setState(() => _method = _PaymentMethod.cod),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Payment Details',
                  icon: Icons.lock_outline,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _detailsForMethod(),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Price Summary',
                  icon: Icons.receipt_long_outlined,
                  child: Column(
                    children: [
                      _PriceRow(
                        label: 'Subtotal',
                        value: widget.subtotal > 0
                            ? widget.subtotal
                            : cart.totalPrice,
                      ),
                      _PriceRow(
                        label: 'Shipping',
                        value: widget.shipping,
                        freeText: widget.shipping == 0 ? 'Free' : null,
                      ),
                      _PriceRow(label: 'Taxes & fees', value: widget.tax),
                      if (widget.discount > 0)
                        _PriceRow(
                          label: 'Discount',
                          value: -widget.discount,
                          isDiscount: true,
                        ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Payable Amount',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Rs ${amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 22,
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
          bottomNavigationBar: _PaymentBottomBar(
            amount: amount,
            isProcessing: _isProcessing,
            methodName: _methodName,
            onPay: () => _payNow(cart, orders),
          ),
        );
      },
    );
  }

  Widget _detailsForMethod() {
    switch (_method) {
      case _PaymentMethod.upi:
        return _UpiForm(key: const ValueKey('upi'), controller: _upiController);
      case _PaymentMethod.card:
        return _CardForm(
          key: const ValueKey('card'),
          numberController: _cardNumberController,
          nameController: _cardNameController,
          expiryController: _expiryController,
          cvvController: _cvvController,
          saveMethod: _saveMethod,
          onSaveChanged: (value) => setState(() => _saveMethod = value ?? true),
        );
      case _PaymentMethod.netBanking:
        return _DropdownForm(
          key: const ValueKey('bank'),
          value: _bank,
          values: const [
            'HDFC Bank',
            'ICICI Bank',
            'SBI',
            'Axis Bank',
            'Kotak Mahindra Bank',
          ],
          label: 'Select Bank',
          icon: Icons.account_balance,
          onChanged: (value) => setState(() => _bank = value ?? _bank),
        );
      case _PaymentMethod.wallet:
        return _DropdownForm(
          key: const ValueKey('wallet'),
          value: _wallet,
          values: const [
            'Google Pay',
            'PhonePe',
            'Paytm Wallet',
            'Amazon Pay',
            'Mobikwik',
          ],
          label: 'Select Wallet',
          icon: Icons.account_balance_wallet_outlined,
          onChanged: (value) => setState(() => _wallet = value ?? _wallet),
        );
      case _PaymentMethod.cod:
        return const _CodDetails(key: ValueKey('cod'));
    }
  }
}

class _PaymentHeader extends StatelessWidget {
  final double amount;
  final int itemCount;

  const _PaymentHeader({required this.amount, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.textInverse.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.watch_outlined,
              color: AppColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemCount > 0
                      ? '$itemCount item${itemCount == 1 ? '' : 's'} in this order'
                      : 'Ready for checkout',
                  style: const TextStyle(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rs ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
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

class _SecurityBanner extends StatelessWidget {
  final String methodName;

  const _SecurityBanner({required this.methodName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Secured $methodName payment with order confirmation after successful verification.',
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
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

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
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
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
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

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.divider,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accent.withValues(alpha: 0.16)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.accent : AppColors.textLight,
              ),
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
                      fontWeight: FontWeight.w900,
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
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.accent : AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _UpiForm extends StatelessWidget {
  final TextEditingController controller;

  const _UpiForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaymentTextField(
          controller: controller,
          label: 'UPI ID',
          hint: 'name@bank',
          icon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final upi = value?.trim() ?? '';
            if (!RegExp(r'^[a-zA-Z0-9.\-_]{2,}@[a-zA-Z]{2,}$').hasMatch(upi)) {
              return 'Enter a valid UPI ID';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        const _InfoStrip(
          label: 'Verification',
          value: 'A collect request will be sent to your UPI app.',
        ),
      ],
    );
  }
}

class _CardForm extends StatelessWidget {
  final TextEditingController numberController;
  final TextEditingController nameController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final bool saveMethod;
  final ValueChanged<bool?> onSaveChanged;

  const _CardForm({
    super.key,
    required this.numberController,
    required this.nameController,
    required this.expiryController,
    required this.cvvController,
    required this.saveMethod,
    required this.onSaveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaymentTextField(
          controller: numberController,
          label: 'Card Number',
          hint: '1234 5678 9012 3456',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            _CardNumberFormatter(),
          ],
          validator: (value) {
            final digits = (value ?? '').replaceAll(' ', '');
            if (digits.length < 13) {
              return 'Enter a valid card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _PaymentTextField(
          controller: nameController,
          label: 'Name on Card',
          hint: 'Full name',
          icon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if ((value ?? '').trim().length < 3) {
              return 'Enter card holder name';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PaymentTextField(
                controller: expiryController,
                label: 'Expiry',
                hint: 'MM/YY',
                icon: Icons.calendar_month_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryFormatter(),
                ],
                validator: (value) {
                  if (!RegExp(
                    r'^(0[1-9]|1[0-2])\/[0-9]{2}$',
                  ).hasMatch(value ?? '')) {
                    return 'Invalid expiry';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PaymentTextField(
                controller: cvvController,
                label: 'CVV',
                hint: '123',
                icon: Icons.password,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  final cvv = value ?? '';
                  if (cvv.length < 3) {
                    return 'Invalid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: saveMethod,
          onChanged: onSaveChanged,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'Save this card securely',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownForm extends StatelessWidget {
  final String value;
  final List<String> values;
  final String label;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DropdownForm({
    super.key,
    required this.value,
    required this.values,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class _CodDetails extends StatelessWidget {
  const _CodDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _InfoStrip(
          label: 'COD Limit',
          value: 'Available for orders after delivery confirmation.',
        ),
        SizedBox(height: 10),
        _InfoStrip(
          label: 'Reminder',
          value: 'Keep exact cash or a UPI app ready at delivery.',
        ),
      ],
    );
  }
}

class _PaymentTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?) validator;

  const _PaymentTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoStrip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

class _PaymentBottomBar extends StatelessWidget {
  final double amount;
  final bool isProcessing;
  final String methodName;
  final VoidCallback onPay;

  const _PaymentBottomBar({
    required this.amount,
    required this.isProcessing,
    required this.methodName,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isProcessing ? null : onPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
              disabledBackgroundColor: AppColors.textLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isProcessing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.textInverse,
                    ),
                  )
                : Text(
                    amount > 0
                        ? 'PAY Rs ${amount.toStringAsFixed(0)} WITH ${methodName.toUpperCase()}'
                        : 'ADD PAYMENT METHOD',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
