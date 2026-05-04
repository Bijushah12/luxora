import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AdminFeedbackBanner extends StatelessWidget {
  final String? error;
  final String? success;
  final VoidCallback onClose;

  const AdminFeedbackBanner({
    super.key,
    required this.error,
    required this.success,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final message = error ?? success;
    if (message == null || message.isEmpty) {
      return const SizedBox.shrink();
    }

    final isError = error != null;
    final color = isError ? AppColors.error : AppColors.success;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: color, size: 20),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
