import 'package:flutter/material.dart';

/// Palette matching Sudoku King's original warm ivory, navy, and gold theme.
class AppColors {
  AppColors._();

  // Core Brand Colors
  static const Color blue = Color(0xFF274385);
  static const Color deepBlue = Color(0xFF1C3065);
  static const Color ink = Color(0xFF1C2B4E);
  static const Color gold = Color(0xFFEFBE39);
  static const Color goldDark = Color(0xFFCA9218);
  static const Color goldLight = Color(0xFFFFDE74);
  static const Color muted = Color(0xFF6F7C94);
  static const Color pale = Color(0xFFFAF6EB);
  static const Color line = Color(0xFFE0D8C4);

  // Difficulty Accents
  static const Color easyAccent = Color(0xFF429F75);
  static const Color mediumAccent = Color(0xFFCA9218);
  static const Color hardAccent = Color(0xFFC3564D);
  static const Color expertAccent = Color(0xFF1C3065);

  // Status & Feedback
  static const Color error = Color(0xFFAD3836);
  static const Color heart = Color(0xFFDC574D);
  static const Color success = Color(0xFF43AE84);
  static const Color streakOrange = Color(0xFFEB743F);

  // Theme-dependent Colors
  static Color background(bool dark) =>
      dark ? const Color(0xFF141B30) : const Color(0xFFFAF7EE);

  static Color surface(bool dark) =>
      dark ? const Color(0xFF232E4A) : const Color(0xFFFFFDF7);

  static Color primaryText(bool dark) =>
      dark ? const Color(0xFFF0EDE0) : ink;

  static Color mutedText(bool dark) =>
      dark ? const Color(0xFFABB4C7) : muted;

  static Color gridLine(bool dark) =>
      dark ? const Color(0xFF444F6A) : line;

  static Color gridBlockLine(bool dark) =>
      dark ? const Color(0xFF7D8DB1) : deepBlue;

  static Color cellSelected(bool dark) =>
      dark ? const Color(0xFF384C74) : const Color(0xFFE7EEF9);

  static Color cellHighlighted(bool dark) =>
      dark ? const Color(0xFF2E3B59) : const Color(0xFFFAF3DE);

  static Color cellMatchValue(bool dark) =>
      dark ? const Color(0xFF3B4866) : const Color(0xFFF6E8BC);

  static Color navBarBorder(bool dark) =>
      dark ? const Color(0x5A1D2538) : const Color(0x1C1D2538);
}
