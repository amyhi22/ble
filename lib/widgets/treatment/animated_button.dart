import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/app_colors.dart';
import '../shared/app_animations.dart';

class AnimatedButton extends StatefulWidget {
  final Widget? child;
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isOutlined;

  const AnimatedButton({
    super.key,
    this.child,
    this.label,
    this.icon,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) {
    _controller.reverse().then((_) {
      if (mounted) {
        HapticFeedback.lightImpact();
        widget.onPressed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: widget.isOutlined ? null : AppColors.brownGradient,
            color: widget.isOutlined ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(15),
            border: widget.isOutlined
                ? Border.all(color: AppColors.greenWithOpacity(0.6), width: 1.5)
                : null,
            boxShadow: widget.isOutlined ? null : [
              BoxShadow(
                color: AppColors.shadowGreen,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.child ?? _buildDefaultContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    if (widget.label == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: _getTextColor()),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label!,
          style: TextStyle(
            color: _getTextColor(),
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getTextColor() => widget.isOutlined ? AppColors.green : AppColors.textWhite;
}