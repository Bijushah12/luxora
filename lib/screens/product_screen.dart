import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/watch_model.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';

class ProductScreen extends StatelessWidget {
  final Watch watch;

  const ProductScreen(this.watch, {super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(watch.name),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 HERO IMAGE
            Hero(
              tag: watch.id,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(30)),
                child: Image.network(
                  watch.image,
                  height: 320,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// 🔥 CONTENT
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// NAME
                  Text(
                    watch.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// PRICE
                  Text(
                    "₹${watch.price}",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DESCRIPTION CARD (GLASS STYLE)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      watch.description,
                      style: TextStyle(
                        color: AppColors.textDark,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔥 ADD TO CART BUTTON (PREMIUM)
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        cart.addToCart(watch);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Added to cart 🛒"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.accent,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Add To Cart",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}