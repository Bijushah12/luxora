import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Header
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.darkBg,
                        Color(0xFF2C2410),
                        AppColors.accentGold,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -30,
                        right: -20,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGold.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGold.withOpacity(0.06),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 16,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: AppColors.primaryGold.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.watch,
                          color: AppColors.primaryGold,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'LUXORA',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Timeless Elegance, Crafted for You',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Our Story
                  _buildSectionTitle('Our Story'),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: const Text(
                      'Founded in 2018, Luxora began with a simple mission: to make luxury timepieces accessible to discerning individuals who appreciate fine craftsmanship. What started as a small boutique in Mumbai has grown into India\'s premier destination for luxury, smart, and sports watches.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mission
                  _buildSectionTitle('Our Mission'),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildMissionItem(
                          icon: Icons.verified,
                          title: 'Authenticity Guaranteed',
                          description: 'Every watch is 100% authentic with original certification and warranty.',
                          color: const Color(0xFFD5F5E3),
                          iconColor: const Color(0xFF58D68D),
                        ),
                        const Divider(height: 24),
                        _buildMissionItem(
                          icon: Icons.diamond,
                          title: 'Premium Quality',
                          description: 'We curate only the finest timepieces from world-renowned brands and artisans.',
                          color: const Color(0xFFF5EEF8),
                          iconColor: const Color(0xFFAF7AC5),
                        ),
                        const Divider(height: 24),
                        _buildMissionItem(
                          icon: Icons.headset_mic,
                          title: 'Exceptional Service',
                          description: 'Our dedicated team provides personalized assistance before, during, and after your purchase.',
                          color: const Color(0xFFD4E6F1),
                          iconColor: const Color(0xFF5DADE2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  _buildSectionTitle('By The Numbers'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          number: '50K+',
                          label: 'Happy Customers',
                          icon: Icons.people,
                          color: const Color(0xFFFADBD8),
                          iconColor: const Color(0xFFEC7063),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          
                          number: '500+',
                          label: 'Watch Collection',
                          icon: Icons.watch,
                          color: const Color(0xFFE8D5B7),
                          iconColor: AppColors.primaryGold,
                        ),
                      ),
                    ],

                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          number: '25+',
                          label: 'Brand Partners',
                          icon: Icons.handshake,
                          color: const Color(0xFFD5F5E3),
                          iconColor: const Color(0xFF58D68D),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          number: '4.8',
                          label: 'Average Rating',
                          icon: Icons.star,
                          color: const Color(0xFFF5EEF8),
                          iconColor: const Color(0xFFAF7AC5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Contact
                  _buildSectionTitle('Get In Touch'),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildContactItem(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          value: 'luxora@gmail.com',
                          color: const Color(0xFFD4E6F1),
                          iconColor: const Color(0xFF5DADE2),
                        ),
                        const Divider(height: 20),
                        _buildContactItem(
                          icon: Icons.phone_outlined,
                          title: 'Phone',
                          value: '+91 98765 43210',
                          color: const Color(0xFFD5F5E3),
                          iconColor: const Color(0xFF58D68D),
                        ),
                        const Divider(height: 20),
                        _buildContactItem(
                          icon: Icons.location_on_outlined,
                          title: 'Address',
                          value: '123 Luxury Avenue, Bandra West, Mumbai - 400050',
                          color: const Color(0xFFFADBD8),
                          iconColor: const Color(0xFFEC7063),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Footer
                  Center(
                    child: Text(
                      '© 2024 Luxora Watches. All rights reserved.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.darkBg,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: child,
    );
  }

  Widget _buildMissionItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.darkBg,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String number,
    required String label,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBg,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.darkBg,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

