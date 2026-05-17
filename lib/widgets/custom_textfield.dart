import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hint;

  const CustomTextField({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        style: TextStyle(color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textLight),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}
