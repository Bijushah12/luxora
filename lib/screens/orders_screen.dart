import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/watch_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

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
          padding: const EdgeInsets.all(16),
          child: Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              if (orderProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (orderProvider.errorMessage != null) {
                return _OrdersMessage(
                  icon: Icons.cloud_off_outlined,
                  title: 'Orders could not load',
                  subtitle: orderProvider.errorMessage!,
                );
              }

              final orders = orderProvider.orders;
              if (orders.isEmpty) {
                return const _OrdersMessage(
                  icon: Icons.shopping_bag_outlined,
                  title: 'No orders yet',
                  subtitle: 'Your Firestore orders will appear here',
                );
              }

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _OrderCard(order: orders[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final orderCode = order.id.length > 8
        ? order.id.substring(order.id.length - 8)
        : order.id;
    final statusColor = order.status.toLowerCase() == 'delivered'
        ? AppColors.success
        : AppColors.accent;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(Icons.receipt_long, color: statusColor, size: 24),
        ),
        title: Text(
          '#$orderCode',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          '${order.itemCount} items | Rs ${order.total.toStringAsFixed(2)} | ${order.status}',
          style: TextStyle(color: statusColor),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WatchCard(watch: item.watch),
                        const SizedBox(height: 6),
                        Text(
                          'Qty: ${item.quantity} | Rs ${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: AppColors.divider),
                _OrderMeta(label: 'Payment', value: order.paymentMethod),
                if (order.transactionId.isNotEmpty)
                  _OrderMeta(label: 'Transaction', value: order.transactionId),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: Rs ${order.total.toStringAsFixed(2)}',
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
  }
}

class _OrderMeta extends StatelessWidget {
  final String label;
  final String value;

  const _OrderMeta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: AppColors.textLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OrdersMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OrdersMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textLight.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
