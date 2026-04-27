import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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
          'Notifications',
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.darkBg, AppColors.primaryGold.withOpacity(0.3)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_as_unread, color: Colors.white),
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
          // Today's Notifications
          Text(
            'Today',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBg,
            ),
          ),
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
          
          // Yesterday
          Text(
            'Yesterday',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBg,
            ),
          ),
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
          // Promo
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGold.withOpacity(0.1), AppColors.accentGold.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: AppColors.primaryGold, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('20% OFF Luxury Collection', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Valid till 31 Dec', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.darkBg,
                  ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 2 : 6,
      shadowColor: isRead ? Colors.grey : AppColors.primaryGold,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isRead ? Colors.transparent : AppColors.primaryGold.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryGold, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            color: isRead ? Colors.grey[700] : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: isRead ? null : const Icon(Icons.circle, color: Colors.red, size: 12),
      ),
    );
  }
}
