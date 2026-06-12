import 'package:flutter/material.dart';

class AppColors {
  // ✅ Your brand colors
  static const Color primaryBrown = Color(0xFF594020);
  static const Color secondaryGreen = Color(0xFF768E2E);
  static const Color darkGreen = Color(0xFF002319);

  // Variations
  static const Color brownDark = Color(0xFF3D2B15);
  static const Color greenLight = Color(0xFF8FA545);

  // Text
  static const Color textWhite = Colors.white;
  static const Color textBrown = Color(0xFF2C241B);
  static const Color textMuted = Color(0xFF6B5D4F);
  static const Color textError = Color(0xFFD32F2F);

  // UI
  static const Color surfaceWhite = Colors.white;
  static const Color surfaceBeige = Color(0xFFFAFAF8);
  static const Color borderLight = Color(0xFFE8E4DC);
  static const Color borderError = Color(0xFFEF9A9A);

  // Shadows
  static const Color shadowBrown = Color(0x14594020);
  static const Color shadowGreen = Color(0x14768E2E);

  // Gradients
  static final LinearGradient brownGradient = LinearGradient(
    colors: const [primaryBrown, brownDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: const [darkGreen, Color(0xFF003326), Color(0xFF0A2E24), darkGreen],
    stops: const [0.0, 0.4, 0.7, 1.0],
  );

  // Helpers
  static Color brownWithOpacity(double opacity) => primaryBrown.withOpacity(opacity);
  static Color greenWithOpacity(double opacity) => secondaryGreen.withOpacity(opacity);
  static Color whiteWithOpacity(double opacity) => textWhite.withOpacity(opacity);
}