import 'package:flutter/material.dart';

/// Painter for the decorative mountain ridges on the Home and Daily challenge screens.
class MountainsPainter extends CustomPainter {
  final bool isDark;

  MountainsPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()..style = PaintingStyle.fill;

    // Distant ridge
    final ridge = Path()
      ..moveTo(0, h * .65)
      ..lineTo(w * .16, h * .45)
      ..lineTo(w * .27, h * .63)
      ..lineTo(w * .39, h * .42)
      ..lineTo(w * .54, h * .65)
      ..lineTo(w * .70, h * .48)
      ..lineTo(w * .83, h * .62)
      ..lineTo(w, h * .44)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    paint.color = isDark ? const Color(0xFF1D2842) : const Color(0xFFEFE7D2);
    canvas.drawPath(ridge, paint);

    // Foreground flat plane
    paint.color = isDark ? const Color(0xFF18223A) : const Color(0xFFF4EEDE);
    canvas.drawRect(Rect.fromLTRB(0, h * .75, w, h), paint);
  }

  @override
  bool shouldRepaint(covariant MountainsPainter oldDelegate) => oldDelegate.isDark != isDark;
}
