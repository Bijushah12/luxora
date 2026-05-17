import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_auth_provider.dart';
import '../../theme/app_colors.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AdminAuthProvider>();
    await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 840;
          final brandPanel = Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(8),
                topRight: Radius.circular(isWide ? 0 : 8),
                bottomLeft: Radius.circular(isWide ? 8 : 0),
              ),
            ),
            child: const _BrandPanel(),
          );
          final loginForm = Padding(
            padding: EdgeInsets.all(isWide ? 34 : 24),
            child: _LoginForm(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              onTogglePassword: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              onSubmit: _submit,
            ),
          );

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 920 : 460),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    children: isWide
                        ? [
                            Expanded(flex: 5, child: brandPanel),
                            Expanded(flex: 6, child: loginForm),
                          ]
                        : [brandPanel, loginForm],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LuxoraLogo(
          markSize: 58,
          titleSize: 30,
          subtitle: 'Admin Console',
          subtitleSize: 15,
          markColor: AppColors.accent,
          textColor: AppColors.textInverse,
          subtitleColor: AppColors.accent,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        const SizedBox(height: 18),
        const Text(
          'Manage products, orders, users, and storefront operations from one Firebase-backed workspace.',
          style: TextStyle(
            color: Color(0xFFD1D5DB),
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LuxoraLogo extends StatelessWidget {
  final double markSize;
  final String subtitle;
  final Color markColor;
  final Color textColor;
  final Color subtitleColor;
  final double titleSize;
  final double subtitleSize;
  final CrossAxisAlignment crossAxisAlignment;

  const _LuxoraLogo({
    required this.markSize,
    required this.titleSize,
    required this.subtitle,
    required this.subtitleSize,
    required this.markColor,
    required this.textColor,
    required this.subtitleColor,
    required this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        SizedBox.square(
          dimension: markSize,
          child: CustomPaint(painter: _LuxoraMarkPainter(markColor)),
        ),
        SizedBox(height: markSize * 0.1),
        Text(
          'LUXORA',
          style: TextStyle(
            color: textColor,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: subtitleColor,
            fontSize: subtitleSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _LuxoraMarkPainter extends CustomPainter {
  final Color color;

  const _LuxoraMarkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final crown = Path()
      ..moveTo(size.width * 0.18, size.height * 0.42)
      ..lineTo(size.width * 0.08, size.height * 0.18)
      ..lineTo(size.width * 0.34, size.height * 0.32)
      ..lineTo(size.width * 0.50, size.height * 0.05)
      ..lineTo(size.width * 0.66, size.height * 0.32)
      ..lineTo(size.width * 0.92, size.height * 0.18)
      ..lineTo(size.width * 0.82, size.height * 0.42);
    canvas.drawPath(crown, stroke);
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.56),
      size.width * 0.31,
      stroke,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'L',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.34,
          fontWeight: FontWeight.w900,
          fontFamily: 'Times New Roman',
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(size.width * 0.38, size.height * 0.39));
  }

  @override
  bool shouldRepaint(_LuxoraMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
    return Consumer<AdminAuthProvider>(
      builder: (context, auth, child) {
        return AutofillGroup(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign In',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Use an email/password account marked as admin in Firebase.',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      auth.errorMessage!,
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Admin Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) {
                    if ((value ?? '').trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => auth.isSigningIn ? null : onSubmit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: onTogglePassword,
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: auth.isSigningIn ? null : onSubmit,
                    icon: auth.isSigningIn
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.textInverse,
                            ),
                          )
                        : const Icon(Icons.login),
                    label: Text(auth.isSigningIn ? 'SIGNING IN' : 'SIGN IN'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
