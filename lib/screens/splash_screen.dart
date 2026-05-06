import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _shineController;
  late AnimationController _rotateController;

  late Animation<double> _shineAnimation;
  late Animation<double> _rotateAnimation;

  double _dragPosition = 0.0;

  final String watchImage =
      "https://images.unsplash.com/photo-1547996160-81dfa63595aa"; // NEW PREMIUM WATCH

  @override
  void initState() {
    super.initState();

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _shineAnimation = Tween<double>(begin: 0, end: 1).animate(_shineController);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _rotateAnimation = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shineController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _navigate() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/login'),
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxDrag = MediaQuery.of(context).size.width - 120;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 🔥 TOP ICON
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.diamond_outlined,
                color: AppColors.accent,
                size: 30,
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 TITLE
            Text(
              "LUXORA",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 28, letterSpacing: 6),
            ),

            const SizedBox(height: 40),

            // 🔥 3D WATCH + SHINE
            AnimatedBuilder(
              animation: Listenable.merge([_shineAnimation, _rotateAnimation]),
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_rotateAnimation.value)
                    ..rotateX(_rotateAnimation.value / 2),
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.card,
                      boxShadow: [
                        BoxShadow(color: AppColors.shadow, blurRadius: 20),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        children: [
                          Image.network(
                            watchImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),

                          // ✨ CLEAN SHINE
                          Align(
                            alignment: Alignment(
                              -1 + _shineAnimation.value * 2,
                              0,
                            ),
                            child: Container(
                              width: 70,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // 🔥 HEADLINE
            Text(
              "THE ART OF TIMEKEEPING",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 SUBTEXT
            Text(
              "Luxury Watches crafted for distinction",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textLight,
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),

            // 🔥 SWIPE BUTTON
            Padding(
              padding: const EdgeInsets.all(24),
              child: Stack(
                children: [
                  Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "SWIPE TO ENTER",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // DRAG WATCH
                  GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _dragPosition += details.delta.dx;
                        if (_dragPosition < 0) _dragPosition = 0;
                        if (_dragPosition > maxDrag) {
                          _dragPosition = maxDrag;
                        }
                      });
                    },
                    onHorizontalDragEnd: (_) {
                      if (_dragPosition > maxDrag * 0.7) {
                        _navigate();
                      } else {
                        setState(() {
                          _dragPosition = 0;
                        });
                      }
                    },
                    child: Transform.translate(
                      offset: Offset(_dragPosition, 0),
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                        child: const Icon(Icons.watch, color: Colors.white),
                      ),
                    ),
                  ),

                  // ARROW
                  Positioned(
                    right: 8,
                    top: 8,
                    bottom: 8,
                    child: Container(
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
