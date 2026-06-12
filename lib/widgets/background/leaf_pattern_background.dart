import 'dart:math';
import 'package:flutter/material.dart';
import '../../shared/app_colors.dart';

/// Elegant leaf background with vertical floating animation
class LeafPatternBackground extends StatefulWidget {
  final Widget child;
  final bool animate;

  const LeafPatternBackground({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<LeafPatternBackground> createState() => _LeafPatternBackgroundState();
}

class _LeafPatternBackgroundState extends State<LeafPatternBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Leaf> _leaves;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    if (widget.animate) _controller.repeat();
    _leaves = [];
  }

  void _generateLeaves(Size size) {
    if (_leaves.isNotEmpty) return;

    final cols = (size.width / 100).ceil();
    final rows = (size.height / 120).ceil();

    for (int row = 0; row <= rows; row++) {
      for (int col = 0; col <= cols; col++) {
        double dx = col * 100 + (row % 2 == 0 ? 50 : 0);
        double dy = row * 120;
        _leaves.add(_Leaf(
          initialOffset: Offset(dx, dy),
          swayAmplitude: 5 + _random.nextDouble() * 5,
          swayPhase: _random.nextDouble() * 2 * pi,
          verticalAmplitude: 5 + _random.nextDouble() * 5,
          verticalPhase: _random.nextDouble() * 2 * pi,
        ));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _generateLeaves(constraints.biggest);

        return Stack(
          children: [
            Container(color: AppColors.surfaceWhite), // white background

            // Leaves layer
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _LeafPainter(
                      leaves: _leaves,
                      animationValue: _controller.value,
                      leafColor: AppColors.darkGreen.withOpacity(0.50),
                      leafSize: 50,
                    ),
                  );
                },
              ),
            ),

            // Optional vignette overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Colors.transparent,
                        AppColors.darkGreen.withOpacity(0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            widget.child,
          ],
        );
      },
    );
  }
}

class _Leaf {
  final Offset initialOffset;
  final double swayAmplitude;
  final double swayPhase;
  final double verticalAmplitude;
  final double verticalPhase;

  _Leaf({
    required this.initialOffset,
    required this.swayAmplitude,
    required this.swayPhase,
    required this.verticalAmplitude,
    required this.verticalPhase,
  });
}

class _LeafPainter extends CustomPainter {
  final List<_Leaf> leaves;
  final double animationValue;
  final Color leafColor;
  final double leafSize;

  _LeafPainter({
    required this.leaves,
    required this.animationValue,
    required this.leafColor,
    required this.leafSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var leaf in leaves) {
      final dx = leaf.initialOffset.dx +
          leaf.swayAmplitude * sin(animationValue * 2 * pi + leaf.swayPhase);
      final dy = leaf.initialOffset.dy +
          leaf.verticalAmplitude * sin(animationValue * 2 * pi + leaf.verticalPhase);

      _drawLeaf(canvas, Offset(dx, dy), leafSize, paint);
    }
  }

  void _drawLeaf(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.4);
    path.cubicTo(
      center.dx + size * 0.3, center.dy + size * 0.1,
      center.dx + size * 0.25, center.dy - size * 0.2,
      center.dx, center.dy - size * 0.25,
    );
    path.cubicTo(
      center.dx - size * 0.25, center.dy - size * 0.2,
      center.dx - size * 0.3, center.dy + size * 0.1,
      center.dx, center.dy + size * 0.4,
    );
    path.moveTo(center.dx, center.dy - size * 0.2);
    path.lineTo(center.dx, center.dy + size * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LeafPainter old) => true;
}