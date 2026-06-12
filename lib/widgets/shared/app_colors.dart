import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color brown = Color(0xFF594020);
  static const Color green = Color(0xFF768E2E);
  static const Color darkGreen = Color(0xFF002319);
  static const Color brownDark = Color(0xFF3D2B15);

  // ✅ Text colors - ADD textMuted HERE
  static const Color textWhite = Colors.white;
  static const Color textWhiteMuted = Color(0xE6FFFFFF);
  static const Color textBrown = Color(0xFF2C241B);
  static const Color textMuted = Color(0xFF6B5D4F);  // ✅ ADD THIS LINE

  // UI colors
  static const Color surfaceWhite = Color(0xFFF8F9F5);
  static const Color surfaceBeige = Color(0xFFFAFAF8);
  static const Color borderLight = Color(0xFFE8E4DC);

  // Shadows
  static const Color shadowBrown = Color(0x14594020);
  static const Color shadowGreen = Color(0x14768E2E);

  // Gradients
  static final LinearGradient brownGradient = LinearGradient(
    colors: const [brown, brownDark],
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
  static Color brownWithOpacity(double opacity) => brown.withOpacity(opacity);
  static Color greenWithOpacity(double opacity) => green.withOpacity(opacity);
  static Color whiteWithOpacity(double opacity) => textWhite.withOpacity(opacity);
}