import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LuxoraLogo extends StatelessWidget {
  final double markSize;
  final bool showText;
  final Axis direction;
  final String title;
  final String? subtitle;
  final Color markColor;
  final Color textColor;
  final Color? subtitleColor;
  final double titleSize;
  final double subtitleSize;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const LuxoraLogo({
    super.key,
    this.markSize = 44,
    this.showText = true,
    this.direction = Axis.vertical,
    this.title = 'LUXORA',
    this.subtitle,
    this.markColor = AppColors.accent,
    this.textColor = AppColors.textDark,
    this.subtitleColor,
    this.titleSize = 22,
    this.subtitleSize = 10,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox.square(
      dimension: markSize,
      child: CustomPaint(painter: LuxoraMarkPainter(color: markColor)),
    );

    if (!showText) {
      return mark;
    }

    final textBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: direction == Axis.horizontal
          ? CrossAxisAlignment.start
          : crossAxisAlignment,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign:
              direction == Axis.horizontal ||
                  crossAxisAlignment == CrossAxisAlignment.start
              ? TextAlign.start
              : TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign:
                direction == Axis.horizontal ||
                    crossAxisAlignment == CrossAxisAlignment.start
                ? TextAlign.start
                : TextAlign.center,
            style: TextStyle(
              color: subtitleColor ?? textColor.withValues(alpha: 0.72),
              fontSize: subtitleSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ],
    );

    if (direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          mark,
          SizedBox(width: markSize * 0.22),
          textBlock,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        mark,
        SizedBox(height: markSize * 0.12),
        textBlock,
      ],
    );
  }
}

class LuxoraMarkPainter extends CustomPainter {
  final Color color;

  const LuxoraMarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.045;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.2, 0),
        Offset(size.width * 0.86, size.height),
        [
          color.withValues(alpha: 0.86),
          AppColors.goldAccent,
          color.withValues(alpha: 0.72),
        ],
        [0, 0.52, 1],
      );
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black.withValues(alpha: 0.08);

    void drawPath(Path path) {
      canvas.drawPath(
        path.shift(Offset(strokeWidth * 0.65, strokeWidth)),
        shadow,
      );
      canvas.drawPath(path, stroke);
    }

    final crown = Path()
      ..moveTo(size.width * 0.18, size.height * 0.41)
      ..lineTo(size.width * 0.08, size.height * 0.18)
      ..lineTo(size.width * 0.33, size.height * 0.31)
      ..lineTo(size.width * 0.50, size.height * 0.04)
      ..lineTo(size.width * 0.67, size.height * 0.31)
      ..lineTo(size.width * 0.92, size.height * 0.18)
      ..lineTo(size.width * 0.82, size.height * 0.41);
    drawPath(crown);

    final circleCenter = Offset(size.width * 0.50, size.height * 0.55);
    final circleRadius = size.width * 0.31;
    canvas.drawCircle(
      circleCenter + Offset(strokeWidth * 0.65, strokeWidth),
      circleRadius,
      shadow,
    );
    canvas.drawCircle(circleCenter, circleRadius, stroke);

    final base = Path()
      ..moveTo(size.width * 0.22, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.88,
        size.width * 0.78,
        size.height * 0.78,
      )
      ..lineTo(size.width * 0.73, size.height * 0.94)
      ..lineTo(size.width * 0.27, size.height * 0.94)
      ..close();
    drawPath(base);

    final handPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.85
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    canvas.drawLine(
      Offset(size.width * 0.51, size.height * 0.56),
      Offset(size.width * 0.68, size.height * 0.62),
      handPaint,
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
    textPainter.paint(
      canvas,
      Offset(
        circleCenter.dx - textPainter.width * 0.55,
        circleCenter.dy - textPainter.height * 0.63,
      ),
    );

    final ticks = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.75
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.24),
      Offset(size.width * 0.50, size.height * 0.27),
      ticks,
    );
    canvas.drawLine(
      Offset(size.width * 0.20, size.height * 0.55),
      Offset(size.width * 0.23, size.height * 0.55),
      ticks,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, size.height * 0.84),
      Offset(size.width * 0.50, size.height * 0.81),
      ticks,
    );

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.87, size.height * 0.56),
          width: strokeWidth * 1.4,
          height: strokeWidth * 2.3,
        ),
        Radius.circular(strokeWidth * 0.2),
      ),
      dotPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.91, size.height * 0.56),
          width: strokeWidth * 1.3,
          height: strokeWidth * 1.3,
        ),
        Radius.circular(strokeWidth * 0.1),
      ),
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(LuxoraMarkPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
