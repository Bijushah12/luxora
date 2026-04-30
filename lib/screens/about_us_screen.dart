import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Luxora',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Luxora is your premier destination for luxury timepieces. We bring you an exclusive collection of watches from world-renowned brands, crafted with precision and elegance.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textLight,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Why Choose Us',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    icon: Icons.verified,
                    title: 'Authenticity Guaranteed',
                    description: 'Every watch is 100% authentic with original certification and warranty.',
                    color: const Color(0xFFD5F5E3),
                    iconColor: const Color(0xFF58D68D),
                  ),
                  _buildFeatureCard(
                    icon: Icons.diamond,
                    title: 'Curated Collection',
                    description: 'We curate only the finest timepieces from world-renowned brands and artisans.',
                    color: const Color(0xFFF5EEF8),
                    iconColor: const Color(0xFFAF7AC5),
                  ),
                  _buildFeatureCard(
                    icon: Icons.support_agent,
                    title: 'Expert Support',
                    description: 'Our dedicated team provides personalized assistance before, during, and after your purchase.',
                    color: const Color(0xFFD4E6F1),
                    iconColor: const Color(0xFF5DADE2),
                  ),
                  _buildFeatureCard(
                    icon: Icons.people,
                    title: 'Community',
                    description: 'Join a community of watch enthusiasts and collectors.',
                    color: const Color(0xFFFADBD8),
                    iconColor: const Color(0xFFEC7063),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    icon: Icons.email,
                    title: 'Email',
                    value: 'luxora@gmail.com',
                    color: const Color(0xFFD4E6F1),
                    iconColor: const Color(0xFF5DADE2),
                  ),
                  _buildContactCard(
                    icon: Icons.phone,
                    title: 'Phone',
                    value: '+91 98765 43210',
                    color: const Color(0xFFD5F5E3),
                    iconColor: const Color(0xFF58D68D),
                  ),
                  _buildContactCard(
                    icon: Icons.location_on,
                    title: 'Address',
                    value: '123 Luxury Avenue, Bandra West, Mumbai - 400050',
                    color: const Color(0xFFFADBD8),
                    iconColor: const Color(0xFFEC7063),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.background,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.1),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'About Us',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
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

