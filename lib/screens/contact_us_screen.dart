import 'package:flutter/material.dart';

import '../services/customer_support_service.dart';
import '../theme/app_colors.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final CustomerSupportService _supportService = CustomerSupportService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedTopic = 'Product guidance';
  bool _isSending = false;

  static const List<String> _topics = [
    'Product guidance',
    'Order support',
    'Warranty',
    'Bulk enquiry',
    'Feedback',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _isSending = true);
    try {
      await _supportService.submitContactMessage(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        topic: _selectedTopic,
        subject: _subjectController.text,
        message: _messageController.text,
      );

      if (!mounted) return;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _subjectController.clear();
      _messageController.clear();
      setState(() => _selectedTopic = 'Product guidance');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent. Luxora support will contact you soon.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send message. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Contact Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ContactHeader(),
                const SizedBox(height: 16),
                _ContactForm(
                  formKey: _formKey,
                  topics: _topics,
                  selectedTopic: _selectedTopic,
                  isSending: _isSending,
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  subjectController: _subjectController,
                  messageController: _messageController,
                  onTopicChanged: (topic) {
                    if (topic != null) {
                      setState(() => _selectedTopic = topic);
                    }
                  },
                  onSubmit: _submit,
                ),
                const SizedBox(height: 16),
                const _SupportDirectory(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactHeader extends StatelessWidget {
  const _ContactHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.support_agent_outlined,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Talk to Luxora Support',
                  style: TextStyle(
                    color: AppColors.textInverse,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Product questions, order help, warranty, returns, bulk enquiry, or feedback. Your message goes directly to Firestore for follow-up.',
                  style: TextStyle(
                    color: Color(0xFFD1D5DB),
                    height: 1.45,
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

class _ContactForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<String> topics;
  final String selectedTopic;
  final bool isSending;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController subjectController;
  final TextEditingController messageController;
  final ValueChanged<String?> onTopicChanged;
  final VoidCallback onSubmit;

  const _ContactForm({
    required this.formKey,
    required this.topics,
    required this.selectedTopic,
    required this.isSending,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.subjectController,
    required this.messageController,
    required this.onTopicChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _ContactTextField(
              controller: nameController,
              label: 'Full name',
              icon: Icons.person_outline,
              validator: (value) => _required(value, 'Enter your name'),
            ),
            const SizedBox(height: 12),
            _ContactTextField(
              controller: emailController,
              label: 'Email address',
              icon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 12),
            _ContactTextField(
              controller: phoneController,
              label: 'Phone number',
              icon: Icons.call_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Enter your phone number';
                if (text.length < 8) return 'Enter a valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedTopic,
              decoration: _fieldDecoration('Topic', Icons.category_outlined),
              items: topics
                  .map(
                    (topic) => DropdownMenuItem<String>(
                      value: topic,
                      child: Text(topic),
                    ),
                  )
                  .toList(),
              onChanged: isSending ? null : onTopicChanged,
            ),
            const SizedBox(height: 12),
            _ContactTextField(
              controller: subjectController,
              label: 'Subject',
              icon: Icons.subject_outlined,
              validator: (value) => _required(value, 'Enter a subject'),
            ),
            const SizedBox(height: 12),
            _ContactTextField(
              controller: messageController,
              label: 'Message',
              icon: Icons.notes_outlined,
              minLines: 4,
              maxLines: 7,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Write your message';
                if (text.length < 12) return 'Please add a little more detail';
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: isSending ? null : onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textInverse,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textInverse,
                        ),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(
                  isSending ? 'Sending...' : 'Send Message',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportDirectory extends StatelessWidget {
  const _SupportDirectory();

  @override
  Widget build(BuildContext context) {
    const items = [
      _DirectoryItem(Icons.mail_outline, 'Email', 'luxora@gmail.com'),
      _DirectoryItem(Icons.call_outlined, 'Phone', '+91 98765 43210'),
      _DirectoryItem(
        Icons.location_on_outlined,
        'Studio',
        '123 Luxury Avenue, Bandra West, Mumbai - 400050',
      ),
    ];

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.value,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ContactTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ContactTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      decoration: _fieldDecoration(label, icon),
    );
  }
}

InputDecoration _fieldDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
      borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error),
    ),
  );
}

String? _required(String? value, String message) {
  if ((value ?? '').trim().isEmpty) {
    return message;
  }
  return null;
}

String? _emailValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Enter your email address';
  final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
  if (!isValid) return 'Enter a valid email address';
  return null;
}

class _DirectoryItem {
  final IconData icon;
  final String label;
  final String value;

  const _DirectoryItem(this.icon, this.label, this.value);
}
