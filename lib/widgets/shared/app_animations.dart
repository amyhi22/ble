import 'package:flutter/animation.dart';

class AppAnimations {
  // ✅ Curves (rename to avoid conflict)
  static const Curve elegantCurve = Cubic(0.34, 1.56, 0.64, 1.0);
  static const Curve smoothCurve = Cubic(0.4, 0.0, 0.2, 1.0);

  // ✅ Durations (rename to avoid conflict)
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration elegantDuration = Duration(milliseconds: 450);  // ✅ Renamed
  static const Duration luxurious = Duration(milliseconds: 700);

  // ✅ Helpers
  static Duration stagger(int index) => Duration(milliseconds: index * 80);
}