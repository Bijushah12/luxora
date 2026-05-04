import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_notification.dart';
import '../providers/cart_provider.dart';
import '../providers/notification_provider.dart';
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
  final String deliveryOption;
  final Map<String, dynamic> address;

  const PaymentScreen({
    super.key,
    this.subtotal = 0,
    this.shipping = 0,
    this.tax = 0,
    this.discount = 0,
    this.total = 0,
    this.itemCount = 0,
    this.preferredMethod = 'upi',
    this.deliveryOption = 'standard',
    this.address = const {},
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _upiController = TextEditingController();

  late _PaymentMethod _method;
  String _bank = 'HDFC Bank';
  String _wallet = 'Google Pay';
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

  String _transactionId() {
    return 'LUX${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(90) + 10}';
  }

  Future<void> _payNow(CartProvider cart, OrderProvider orders) async {
    final amount = _payableAmount(cart);
    if (amount <= 0) {
      _showSnack('Add items to cart before making a payment.');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notificationProvider = context.read<NotificationProvider>();

    setState(() => _isProcessing = true);
    final transactionId = _transactionId();

    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) {
        return;
      }

      final order = await orders.placeOrder(
        cartItems: cart.items.values,
        subtotal: widget.subtotal > 0 ? widget.subtotal : cart.totalPrice,
        shipping: widget.shipping,
        tax: widget.tax,
        discount: widget.discount,
        total: amount,
        paymentMethod: _methodName,
        paymentStatus: _method == _PaymentMethod.cod ? 'Pending' : 'Paid',
        transactionId: transactionId,
        deliveryOption: widget.deliveryOption,
        address: widget.address,
      );

      await notificationProvider.addNotification(
        AppNotification(
          id: 'order-${DateTime.now().microsecondsSinceEpoch}',
          type: 'order',
          title: 'Order placed successfully',
          subtitle:
              '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'} confirmed for Rs ${amount.toStringAsFixed(0)}.',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      );
      cart.clearCart();

      if (!mounted) {
        return;
      }
      setState(() => _isProcessing = false);
      await _showSuccessSheet(amount, transactionId);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isProcessing = false);
      _showSnack('Order could not be saved. Please try again.');
    }
  }

  Future<void> _showSuccessSheet(double amount, String paymentId) {
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

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldBg,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textDark),
            title: const Text(
              'Secure Payment',
              style: TextStyle(
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
                _SectionCard(
                  title: 'Choose Payment Method',
                  icon: Icons.payments_outlined,
                  child: Column(
                    children: [
                      _MethodTile(
                        icon: Icons.qr_code_2,
                        title: 'UPI',
                        subtitle: 'Fast demo payment',
                        selected: _method == _PaymentMethod.upi,
                        onTap: () =>
                            setState(() => _method = _PaymentMethod.upi),
                      ),
                      _MethodTile(
                        icon: Icons.credit_card,
                        title: 'Credit / Debit Card',
                        subtitle: 'Demo card payment',
                        selected: _method == _PaymentMethod.card,
                        onTap: () =>
                            setState(() => _method = _PaymentMethod.card),
                      ),
                      _MethodTile(
                        icon: Icons.account_balance,
                        title: 'Net Banking',
                        subtitle: 'Select your bank',
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
        return _UpiDetails(
          key: const ValueKey('upi'),
          controller: _upiController,
        );
      case _PaymentMethod.card:
        return const _StaticDetails(
          key: ValueKey('card'),
          label: 'Demo Card',
          value: 'Card payment will be simulated for this order.',
        );
      case _PaymentMethod.netBanking:
        return _DropdownDetails(
          key: const ValueKey('bank'),
          label: 'Select Bank',
          value: _bank,
          values: const [
            'HDFC Bank',
            'ICICI Bank',
            'SBI',
            'Axis Bank',
            'Kotak Mahindra Bank',
          ],
          onChanged: (value) => setState(() => _bank = value ?? _bank),
        );
      case _PaymentMethod.wallet:
        return _DropdownDetails(
          key: const ValueKey('wallet'),
          label: 'Select Wallet',
          value: _wallet,
          values: const [
            'Google Pay',
            'PhonePe',
            'Paytm Wallet',
            'Amazon Pay',
            'Mobikwik',
          ],
          onChanged: (value) => setState(() => _wallet = value ?? _wallet),
        );
      case _PaymentMethod.cod:
        return const _StaticDetails(
          key: ValueKey('cod'),
          label: 'COD',
          value: 'Keep exact cash or UPI ready when your order arrives.',
        );
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

class _UpiDetails extends StatelessWidget {
  final TextEditingController controller;

  const _UpiDetails({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'UPI ID',
        hintText: 'name@bank',
        prefixIcon: const Icon(
          Icons.alternate_email,
          color: AppColors.textLight,
        ),
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
      validator: (value) {
        final upi = value?.trim() ?? '';
        if (!RegExp(r'^[a-zA-Z0-9.\-_]{2,}@[a-zA-Z]{2,}$').hasMatch(upi)) {
          return 'Enter a valid UPI ID';
        }
        return null;
      },
    );
  }
}

class _DropdownDetails extends StatelessWidget {
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  const _DropdownDetails({
    super.key,
    required this.label,
    required this.value,
    required this.values,
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
        prefixIcon: const Icon(
          Icons.account_balance,
          color: AppColors.textLight,
        ),
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

class _StaticDetails extends StatelessWidget {
  final String label;
  final String value;

  const _StaticDetails({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return _InfoStrip(label: label, value: value);
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
