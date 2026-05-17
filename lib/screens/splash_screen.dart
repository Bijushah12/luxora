import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
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
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/login'),
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
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

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: compactWidth ? 16 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _LuxoraLogo(
                        markSize: logoSize,
                        titleSize: compactWidth ? 35 : 25,
                        subtitle: 'LUXURY WATCH',
                        subtitleSize: compactWidth ? 20 : 20,
                        markColor: AppColors.accent,
                        textColor: AppColors.textDark,
                        subtitleColor: AppColors.textLight,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildWatchShowcase(watchSize),
                            SizedBox(height: compactWidth ? 22 : 28),
                            SizedBox(
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
                            const SizedBox(height: 14),
                            Text(
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: _buildSwipeButton(),
                      ),
                    ],
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
            decoration: BoxDecoration(
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
                  decoration: BoxDecoration(
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
                decoration: BoxDecoration(
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

class _LuxoraLogo extends StatelessWidget {
  final double markSize;
  final String? subtitle;
  final Color markColor;
  final Color textColor;
  final Color? subtitleColor;
  final double titleSize;
  final double subtitleSize;

  const _LuxoraLogo({
    required this.markSize,
    this.subtitle,
    required this.markColor,
    required this.textColor,
    this.subtitleColor,
    required this.titleSize,
    required this.subtitleSize,
  });

  @override
  Widget build(BuildContext context) {
    AppColors.watch(context);
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
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              color: subtitleColor ?? textColor,
              fontSize: subtitleSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
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
  bool shouldRepaint(_LuxoraMarkPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
