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
      backgroundColor: AppColors.primaryGold.withOpacity(0.05),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 92,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "My Cart (${cartProvider.totalItems})",
          style: const TextStyle(
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

      body: cartItems.isEmpty
          ? const Center(child: Text("Cart is Empty"))
          : Column(
              children: [

                // 🛒 LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {

                      final item = cartItems[index]; // 🔥 CartItem
                      final watch = item.watch;

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: Image.network(
                            watch.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),

                          title: Text(watch.name),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("₹${watch.price}"),
                              Text("Qty: ${item.quantity}"),
                            ],
                          ),

                          // ➕➖ Quantity controls
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  cartProvider.decreaseQty(watch.id);
                                },
                              ),

                              Text(item.quantity.toString()),

                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  cartProvider.increaseQty(watch.id);
                                },
                              ),

                              IconButton(
                                icon: const Icon(Icons.delete),
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

                // 💰 TOTAL + BUTTON
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        color: Colors.black.withOpacity(0.1),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Total: ₹${cartProvider.totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
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
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}