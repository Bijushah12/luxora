import 'dart:async';

import 'package:flutter/material.dart';

import '../services/customer_support_service.dart';
import '../services/luxora_assistant_engine.dart';
import '../theme/app_colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final CustomerSupportService _supportService = CustomerSupportService();
  final ScrollController _chatController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          'Hi, I am Luxora Concierge. Ask me about watches, delivery, warranty, returns, gifting, or order support.',
      isUser: false,
    ),
  ];

  bool _isTyping = false;

  static const List<String> _quickQuestions = [
    'Is every watch authentic?',
    'How long is delivery?',
    'What is the return policy?',
    'Help me pick a gift watch',
  ];

  @override
  void dispose() {
    _chatController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _send([String? quickQuestion]) {
    final question = (quickQuestion ?? _inputController.text).trim();
    if (question.isEmpty || _isTyping) return;

    _inputController.clear();
    setState(() {
      _messages.add(_ChatMessage(text: question, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    Future<void>.delayed(const Duration(milliseconds: 340), () {
      if (!mounted) return;
      final reply = LuxoraAssistantEngine.answer(question);

      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(text: reply.answer, isUser: false));
      });
      _scrollToBottom();

      unawaited(
        _supportService
            .submitChatExchange(
              question: question,
              answer: reply.answer,
              intent: reply.intent,
            )
            .catchError((Object _) {}),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatController.hasClients) return;
      _chatController.animateTo(
        _chatController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Luxora Concierge')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              children: [
                const _AssistantHeader(),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListView.builder(
                      controller: _chatController,
                      padding: const EdgeInsets.all(14),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _messages.length) {
                          return const _TypingBubble();
                        }
                        return _ChatBubble(message: _messages[index]);
                      },
                    ),
                  ),
                ),
                _QuickQuestionBar(
                  questions: _quickQuestions,
                  isDisabled: _isTyping,
                  onTap: _send,
                ),
                _Composer(
                  controller: _inputController,
                  isDisabled: _isTyping,
                  onSend: () => _send(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssistantHeader extends StatelessWidget {
  const _AssistantHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Watch Concierge',
                  style: TextStyle(
                    color: AppColors.textInverse,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Instant help for buying, delivery, warranty, returns, and support.',
                  style: TextStyle(
                    color: Color(0xFFD1D5DB),
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _QuickQuestionBar extends StatelessWidget {
  final List<String> questions;
  final bool isDisabled;
  final ValueChanged<String> onTap;

  const _QuickQuestionBar({
    required this.questions,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: questions.map((question) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              onPressed: isDisabled ? null : () => onTap(question),
              label: Text(question),
              labelStyle: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              backgroundColor: AppColors.card,
              disabledColor: AppColors.surface,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isDisabled;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.isDisabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Ask your watch question...',
                prefixIcon: const Icon(Icons.chat_bubble_outline),
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
              onSubmitted: isDisabled ? null : (_) => onSend(),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 50,
            height: 50,
            child: FilledButton(
              onPressed: isDisabled ? null : onSend,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textInverse,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.arrow_upward),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: Radius.circular(isUser ? 8 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 8),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? AppColors.textInverse : AppColors.textDark,
            height: 1.42,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Concierge is checking...',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}
