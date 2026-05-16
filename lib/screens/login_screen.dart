import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_auth_service.dart';
import '../theme/app_colors.dart';
import 'signup_screen.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AdminAuthService _adminAuthService = AdminAuthService();

  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email required";
    if (!value.contains("@")) return "Enter valid email";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password required";
    if (value.length < 6) return "Minimum 6 characters";
    return null;
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'missing-user',
          message: 'No Firebase user was returned after login.',
        );
      }

      final isAdmin = await _adminAuthService.isAdmin(user);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        if (user.email != null) 'email': user.email,
        if (user.displayName != null && user.displayName!.trim().isNotEmpty)
          'name': user.displayName,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      if (isAdmin) {
        Navigator.of(context).pushNamedAndRemoveUntil('/admin', (_) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            settings: const RouteSettings(name: '/main'),
            builder: (_) => const MainNavigation(),
          ),
          (_) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";

      if (e.code == 'user-not-found') {
        message = "User not found";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to verify account role. $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 320,
                    width: double.infinity,
                    color: AppColors.primary,
                    child: Opacity(
                      opacity: 0.4,
                      child: Image.network(
                        "https://images.unsplash.com/photo-1523170335258-f5ed11844a49",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 54,
                  left: 0,
                  right: 0,
                  child: const _LuxoraLogo(
                    markSize: 54,
                    titleSize: 28,
                    subtitle: 'PREMIUM WATCHES',
                    subtitleSize: 10,
                    markColor: AppColors.accent,
                    textColor: Colors.white,
                    subtitleColor: Colors.white70,
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    TextFormField(
                      controller: emailController,
                      validator: validateEmail,
                      style: const TextStyle(color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: "Email Address",
                        hintStyle: const TextStyle(color: AppColors.textLight),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.textDark,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: passwordController,
                      validator: validatePassword,
                      obscureText: hidePassword,
                      style: const TextStyle(color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(color: AppColors.textLight),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.textDark,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.textDark,
                          ),
                          onPressed: () =>
                              setState(() => hidePassword = !hidePassword),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: isLoading ? null : loginUser,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "LOGIN",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "New to Luxora?",
                          style: TextStyle(color: AppColors.textLight),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 80,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _LuxoraLogo extends StatelessWidget {
  final double markSize;
  final String subtitle;
  final Color markColor;
  final Color textColor;
  final Color subtitleColor;
  final double titleSize;
  final double subtitleSize;

  const _LuxoraLogo({
    required this.markSize,
    required this.titleSize,
    required this.subtitle,
    required this.subtitleSize,
    required this.markColor,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
    final base = Path()
      ..moveTo(size.width * 0.24, size.height * 0.80)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.91,
        size.width * 0.76,
        size.height * 0.80,
      )
      ..lineTo(size.width * 0.72, size.height * 0.94)
      ..lineTo(size.width * 0.28, size.height * 0.94)
      ..close();
    canvas.drawPath(base, stroke);
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
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.56),
      Offset(size.width * 0.68, size.height * 0.62),
      stroke,
    );
  }

  @override
  bool shouldRepaint(_LuxoraMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
