import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../models/watch_model.dart';
import '../theme/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = 'card';
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGold.withOpacity(0.05),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 92,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Secure Payment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              Shadow(offset: Offset(0, 2), blurRadius: 8, color: Color(0x80000000)),
              Shadow(offset: Offset(0, -2), blurRadius: 8, color: AppColors.primaryGold),
            ],
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.darkBg, AppColors.primaryGold.withOpacity(0.3)],
            ),
          ),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final items = cart.items.values.map((e) => e.watch).toList();
          final total = cart.totalPrice;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order Summary Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Order Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ...items.map((watch) => ListTile(
                          dense: true,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(watch.image, width: 50, height: 50, fit: BoxFit.cover),
                          ),
                          title: Text(watch.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text('${watch.brand}'),
                          trailing: Text('₹${watch.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        )),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Method Selection
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Method', style: Theme.of(context).textTheme.titleLarge),
                        RadioListTile<String>(
                          title: const Text('Credit/Debit Card'),
                          subtitle: const Text('Visa, Mastercard'),
                          value: 'card',
                          groupValue: selectedMethod,
                          onChanged: (value) => setState(() => selectedMethod = value!),
                        ),
                        RadioListTile<String>(
                          title: const Text('UPI'),
                          subtitle: const Text('Google Pay, PhonePe'),
                          value: 'upi',
                          groupValue: selectedMethod,
                          onChanged: (value) => setState(() => selectedMethod = value!),
                        ),
                        RadioListTile<String>(
                          title: const Text('Wallet'),
                          subtitle: const Text('Paytm, Amazon Pay'),
                          value: 'wallet',
                          groupValue: selectedMethod,
                          onChanged: (value) => setState(() => selectedMethod = value!),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (selectedMethod == 'card') ...[
                  // Card Form
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            controller: cardNumberController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Card Number',
                              prefixIcon: const Icon(Icons.credit_card),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (value) {
                              if (value.length > 19) {
                                cardNumberController.text = value.substring(0, 19);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: expiryController,
                                  keyboardType: TextInputType.datetime,
                                  decoration: InputDecoration(
                                    labelText: 'Expiry MM/YY',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: cvvController,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'CVV',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else if (selectedMethod == 'upi') ...[
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.account_balance_wallet),
                      title: const Text('UPI ID'),
                      subtitle: const Text('yourupi@paytm'),
                      trailing: const Icon(Icons.edit),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Pay Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handlePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text('Pay ₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

Future<void> _handlePayment() async {
  setState(() => isLoading = true);

  await Future.delayed(const Duration(seconds: 2));

  final cart = Provider.of<CartProvider>(context, listen: false);
  final orderProvider = Provider.of<OrderProvider>(context, listen: false);

  final items = cart.items.values.map((e) => e.watch).toList();
  final total = cart.totalPrice;

  orderProvider.placeOrder(items, total);
  cart.clearCart();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Payment Successful! Your order has been placed 🤩'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );

  await Future.delayed(const Duration(seconds: 2));

  Navigator.of(context).popUntil((route) => route.isFirst);

  setState(() => isLoading = false);
}

  @override
  void dispose() {
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.dispose();
  }
}
