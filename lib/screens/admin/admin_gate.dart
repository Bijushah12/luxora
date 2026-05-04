import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_auth_provider.dart';
import '../../theme/app_colors.dart';
import 'admin_login_screen.dart';
import 'admin_shell.dart';

class AdminGate extends StatelessWidget {
  const AdminGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAuthProvider>(
      builder: (context, auth, child) {
        if (auth.isChecking) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.user == null) {
          return const AdminLoginScreen();
        }

        if (!auth.isAdmin) {
          return _AccessDenied(
            message:
                auth.errorMessage ??
                'Your current account does not have admin access.',
          );
        }

        return const AdminShell();
      },
    );
  }
}

class _AccessDenied extends StatelessWidget {
  final String message;

  const _AccessDenied({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppColors.error,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Admin Access Required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.read<AdminAuthProvider>().signOut(),
                    icon: const Icon(Icons.logout),
                    label: const Text('LOG OUT'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
