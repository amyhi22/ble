import 'package:flutter/animation.dart';

class AppAnimations {
  // ✅ Animation curves
  static const Curve elegantEntrance = Cubic(0.34, 1.56, 0.64, 1.0);
  static const Curve smoothFade = Cubic(0.4, 0.0, 0.2, 1.0);
  static const Curve elasticBounce = Cubic(0.68, -0.55, 0.265, 1.55);

  // ✅ Animation durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration elegantDuration = Duration(milliseconds: 450);

  // ✅ ADD THIS ALIAS so AppAnimations.elegant works
  static Duration get elegant => elegantDuration;  // ✅ Alias

  static const Duration luxurious = Duration(milliseconds: 700);

  // ✅ Helper
  static Duration stagger(int index) => Duration(milliseconds: index * 80);
}