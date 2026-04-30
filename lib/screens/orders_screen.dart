import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../models/watch_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/watch_card.dart';


class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              if (orderProvider.orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: AppColors.textLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your orders will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  // Provider already notifies, but can add future if needed
                },
                child: ListView.builder(
                  itemCount: orderProvider.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderProvider.orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.success.withOpacity(0.1),
                          child: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
                        ),
                        title: Text(
                          '#${order.id.substring(order.id.length - 8)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        subtitle: Text(
                          'Total: \$${order.total.toStringAsFixed(2)} • Delivered',
                          style: TextStyle(color: AppColors.success),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...order.items.map((watch) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: WatchCard(watch: watch),
                                )),
                                const Divider(color: AppColors.divider),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Total: \$${order.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
