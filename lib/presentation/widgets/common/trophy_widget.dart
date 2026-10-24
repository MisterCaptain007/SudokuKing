import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Replicates the victory trophy illustration with laurels and star.
class TrophyWidget extends StatelessWidget {
  final double size;
  final bool isDark;

  const TrophyWidget({
    super.key,
    this.size = 80,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrophyPainter(isDark: isDark),
    );
  }
}

class _TrophyPainter extends CustomPainter {
  final bool isDark;

  _TrophyPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = size.width / 100.0;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale, scale);

    final laurelColor = isDark ? AppColors.gold : AppColors.goldDark;
    final paint = Paint()..color = laurelColor;

    // Branches
    final strokePaint = Paint()
      ..color = laurelColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final leftBranch = Path()
      ..moveTo(-39, 34)
      ..quadraticBezierTo(-53, 8, -37, -20);
    canvas.drawPath(leftBranch, strokePaint);

    final rightBranch = Path()
      ..moveTo(39, 34)
      ..quadraticBezierTo(53, 8, 37, -20);
    canvas.drawPath(rightBranch, strokePaint);

    // Laurel leaves
    for (var i = 0; i < 4; i++) {
      final y = 24.0 - i * 13;
      // Left leaf
      canvas.save();
      canvas.translate(-39.0 + (i % 2) * 2, y);
      canvas.rotate(-35 * pi / 180);
      canvas.drawOval(const Rect.fromLTRB(-9, -8, 7, 1), paint);
      canvas.restore();

      // Right leaf
      canvas.save();
      canvas.translate(39.0 - (i % 2) * 2, y);
      canvas.rotate(35 * pi / 180);
      canvas.drawOval(const Rect.fromLTRB(-7, -8, 9, 1), paint);
      canvas.restore();
    }

    // Handles
    final handlePaint = Paint()
      ..color = AppColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawOval(const Rect.fromLTRB(-39, -22, -25, 8), handlePaint);
    canvas.drawOval(const Rect.fromLTRB(25, -22, 39, 8), handlePaint);

    // Cup Body
    final cupPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;
    final cup = Path()
      ..moveTo(-31, -29)
      ..lineTo(31, -29)
      ..lineTo(25, 2)
      ..quadraticBezierTo(21, 18, 0, 23)
      ..quadraticBezierTo(-21, 18, -25, 2)
      ..close();
    canvas.drawPath(cup, cupPaint);

    // Cup Rim
    final rimPaint = Paint()..color = const Color(0xFFFFDE74);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(-34, -34, 34, -26), const Radius.circular(3)),
      rimPaint,
    );

    // Star in Center of Cup
    final starPaint = Paint()..color = const Color(0xFFFFEEA4);
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -pi / 2 + i * pi / 5;
      final radius = i % 2 == 0 ? 13.0 : 6.0;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius - 5;
      if (i == 0) {
        star.moveTo(x, y);
      } else {
        star.lineTo(x, y);
      }
    }
    star.close();
    canvas.drawPath(star, starPaint);

    // Base Stem & Pedestal
    final basePaint = Paint()..color = AppColors.goldDark;
    canvas.drawRect(const Rect.fromLTRB(-5, 22, 5, 33), basePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(-18, 32, 18, 38), const Radius.circular(3)),
      basePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(-23, 38, 23, 44), const Radius.circular(3)),
      basePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TrophyPainter oldDelegate) => oldDelegate.isDark != isDark;
}
