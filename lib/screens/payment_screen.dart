import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPaymentMethod(
            icon: Icons.credit_card,
            name: 'Credit/Debit Card',
            subtitle: '**** **** **** 4242',
            isDefault: true,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethod(
            icon: Icons.account_balance,
            name: 'Net Banking',
            subtitle: 'HDFC Bank',
            isDefault: false,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethod(
            icon: Icons.wallet,
            name: 'UPI / Wallets',
            subtitle: 'Google Pay',
            isDefault: false,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethod(
            icon: Icons.money,
            name: 'Cash on Delivery',
            subtitle: 'Pay when you receive',
            isDefault: false,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add New Payment Method'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String name,
    required String subtitle,
    required bool isDefault,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault ? AppColors.accent : AppColors.border,
          width: isDefault ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent, size: 24),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textLight),
        ),
        trailing: isDefault
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
      ),
    );
  }
}
