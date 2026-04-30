import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Notifications',
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
            icon: const Icon(Icons.mark_email_read_outlined, color: AppColors.textDark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read!')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle(title: 'Today'),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.shopping_bag,
            title: 'Order #1234 Delivered',
            subtitle: 'Your luxury watch has arrived',
            time: '2 mins ago',
            isRead: false,
          ),
          _buildNotificationCard(
            icon: Icons.favorite,
            title: 'Watch added to your wishlist',
            subtitle: 'Rolex Submariner saved',
            time: '10 mins ago',
            isRead: true,
          ),
          const SizedBox(height: 24),
          
          const _SectionTitle(title: 'Yesterday'),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.payments,
            title: 'Payment Successful',
            subtitle: '₹25,000 charged to card ending ****1234',
            time: '1 day ago',
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.local_shipping,
            title: 'Order #1233 Shipped',
            subtitle: 'Estimated delivery: Tomorrow',
            time: '2 days ago',
            isRead: false,
          ),
          
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star, color: AppColors.accent, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('20% OFF Luxury Collection', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      Text('Valid till 31 Dec', style: TextStyle(color: AppColors.textLight)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Shop Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required bool isRead,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? AppColors.border : AppColors.accent.withOpacity(0.3),
          width: isRead ? 1 : 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.accent, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            color: isRead ? AppColors.textLight : AppColors.textDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: const TextStyle(color: AppColors.textLight)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          ],
        ),
        trailing: isRead ? null : const Icon(Icons.circle, color: AppColors.error, size: 10),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }
}
