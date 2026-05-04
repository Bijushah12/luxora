import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items.values.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text(
          "My Cart (${cartProvider.totalItems})",
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppColors.textLight.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Your cart is empty",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final watch = item.watch;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              watch.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),

                          title: Text(
                            watch.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "₹${watch.price}",
                                style: const TextStyle(
                                  color: AppColors.goldAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Qty: ${item.quantity}"),
                            ],
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: AppColors.textDark,
                                ),
                                onPressed: () {
                                  cartProvider.decreaseQty(watch.id);
                                },
                              ),

                              Text(
                                item.quantity.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: AppColors.textDark,
                                ),
                                onPressed: () {
                                  cartProvider.increaseQty(watch.id);
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
                                onPressed: () {
                                  cartProvider.removeFromCart(watch.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // TOTAL + BUTTON
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              "₹${cartProvider.totalPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldAccent,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CheckoutScreen(),
                                ),
                              );
                            },
                            child: const Text("Checkout"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
