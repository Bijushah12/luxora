import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/luxora_logo.dart';
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
      'https://images.unsplash.com/photo-1547996160-81dfa63595aa';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactWidth = constraints.maxWidth < 390;
            final logoSize = (constraints.maxWidth * 0.12)
                .clamp(44.0, 58.0)
                .toDouble();
            final watchSize = (constraints.maxWidth * 0.56)
                .clamp(210.0, 260.0)
                .toDouble();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compactWidth ? 16 : 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 24),
                              LuxoraLogo(
                                markSize: logoSize,
                                titleSize: compactWidth ? 21 : 24,
                                subtitle: 'LUXURY WATCH',
                                subtitleSize: compactWidth ? 9 : 10,
                                markColor: AppColors.accent,
                                textColor: AppColors.textDark,
                                subtitleColor: AppColors.textLight,
                              ),
                              SizedBox(height: compactWidth ? 28 : 38),
                              _buildWatchShowcase(watchSize),
                              SizedBox(height: compactWidth ? 24 : 30),
                              const SizedBox(
                                width: double.infinity,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'THE ART OF TIMEKEEPING',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 3,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Luxury Watches crafted for distinction',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textLight,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 28, bottom: 24),
                            child: _buildSwipeButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWatchShowcase(double watchSize) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shineAnimation, _rotateAnimation]),
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_rotateAnimation.value)
            ..rotateX(_rotateAnimation.value / 2),
          child: Container(
            width: watchSize,
            height: watchSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.card,
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 20)],
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
                  Align(
                    alignment: Alignment(-1 + _shineAnimation.value * 2, 0),
                    child: Container(
                      width: watchSize * 0.27,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.5, 1],
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
    );
  }

  Widget _buildSwipeButton() {
    const knobSize = 65.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = (constraints.maxWidth - knobSize)
            .clamp(0.0, double.infinity)
            .toDouble();
        final dragPosition = _dragPosition.clamp(0.0, maxDrag).toDouble();

        return Stack(
          children: [
            Container(
              height: knobSize,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(40),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 74),
              child: Text(
                'SWIPE TO ENTER',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragPosition = (_dragPosition + details.delta.dx)
                      .clamp(0.0, maxDrag)
                      .toDouble();
                });
              },
              onHorizontalDragEnd: (_) {
                if (_dragPosition > maxDrag * 0.7) {
                  _navigate();
                } else {
                  setState(() => _dragPosition = 0);
                }
              },
              child: Transform.translate(
                offset: Offset(dragPosition, 0),
                child: Container(
                  width: knobSize,
                  height: knobSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                  ),
                  child: const Icon(Icons.watch, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              bottom: 8,
              child: Container(
                width: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
