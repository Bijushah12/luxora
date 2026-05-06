import 'package:flutter/material.dart';

import '../screens/chatbot_screen.dart';
import '../theme/app_colors.dart';

class ChatbotLauncher extends StatelessWidget {
  const ChatbotLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'luxora-chatbot-launcher',
      tooltip: 'Ask Luxora Concierge',
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.accent,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: const RouteSettings(name: '/chatbot'),
            builder: (_) => const ChatbotScreen(),
          ),
        );
      },
      child: const Icon(Icons.auto_awesome_outlined),
    );
  }
}
