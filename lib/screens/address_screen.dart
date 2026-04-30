import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final List<Map<String, String>> addresses = [
    {
      'name': 'Home',
      'address': '123 Luxury Avenue, Bandra West, Mumbai - 400050',
      'phone': '+91 98765 43210',
    },
    {
      'name': 'Office',
      'address': '456 Business Park, Andheri East, Mumbai - 400069',
      'phone': '+91 98765 43211',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Shipping Address',
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
          ...addresses.map((addr) => _buildAddressCard(addr)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add New Address'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, String> addr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Text(
                addr['name']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Edit', style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            addr['address']!,
            style: const TextStyle(
              color: AppColors.textLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            addr['phone']!,
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
