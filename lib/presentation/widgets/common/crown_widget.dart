import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Replicates the signature Sudoku King gold crown illustration.
class CrownWidget extends StatelessWidget {
  final double size;
  final bool isDark;

  const CrownWidget({
    super.key,
    this.size = 48,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.1),
      painter: _CrownPainter(isDark: isDark),
    );
  }
}

class _CrownPainter extends CustomPainter {
  final bool isDark;

  _CrownPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.45;
    final s = size.width;

    final paint = Paint()..style = PaintingStyle.fill;

    // Crown Spikes
    final path = Path()
      ..moveTo(cx - s * .48, cy - s * .12)
      ..lineTo(cx - s * .36, cy - s * .43)
      ..lineTo(cx - s * .10, cy - s * .18)
      ..lineTo(cx, cy - s * .52)
      ..lineTo(cx + s * .14, cy - s * .18)
      ..lineTo(cx + s * .40, cy - s * .43)
      ..lineTo(cx + s * .48, cy - s * .12)
      ..close();

    paint.color = AppColors.gold;
    canvas.drawPath(path, paint);

    // Crown Band
    paint.color = AppColors.goldLight;
    final bandRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - s * .46, cy - s * .08, cx + s * .46, cy + s * .17),
      const Radius.circular(5),
    );
    canvas.drawRRect(bandRect, paint);

    // Sudoku Mini Grid Box Base
    paint.color = AppColors.surface(isDark);
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - s * .37, cy + s * .23, cx + s * .37, cy + s * .99),
      const Radius.circular(8),
    );
    canvas.drawRRect(boxRect, paint);

    // Grid Lines
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isDark ? AppColors.gold : AppColors.blue;

    for (var i = 1; i < 3; i++) {
      final x = cx - s * .37 + i * s * .247;
      canvas.drawLine(Offset(x, cy + s * .23), Offset(x, cy + s * .99), strokePaint);
      final y = cy + s * .23 + i * s * .253;
      canvas.drawLine(Offset(cx - s * .37, y), Offset(cx + s * .37, y), strokePaint);
    }

    // Numbers 9 and 5 in mini grid
    _drawText(canvas, '9', cx - s * .245, cy + s * .37, s * .25, strokePaint.color);
    _drawText(canvas, '5', cx + s * .245, cy + s * .63, s * .25, strokePaint.color);
  }

  void _drawText(Canvas canvas, String text, double x, double y, double fontSize, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CrownPainter oldDelegate) => oldDelegate.isDark != isDark;
}
