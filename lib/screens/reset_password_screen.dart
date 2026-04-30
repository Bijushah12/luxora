import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_textfield.dart';
import 'home_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Reset Password',
          style: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.lock_reset, size: 80, color: AppColors.accent.withOpacity(0.5)),
            const SizedBox(height: 30),
            const Text(
              "Create New Password",
              style: TextStyle(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter your new password below",
              style: TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
            const SizedBox(height: 40),
            const CustomTextField(hint: "New Password"),
            const CustomTextField(hint: "Confirm Password"),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text("Continue"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
