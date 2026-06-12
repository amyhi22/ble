import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_animations.dart';

class AnimatedAuthButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;

  const AnimatedAuthButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
  });

  @override
  State<AnimatedAuthButton> createState() => _AnimatedAuthButtonState();
}

class _AnimatedAuthButtonState extends State<AnimatedAuthButton>
    with SingleTickerProviderStateMixin {
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

  void _onTapDown(TapDownDetails _) {
    if (!widget.isLoading) _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse().then((_) {
      if (!widget.isLoading) {
        HapticFeedback.mediumImpact();
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: widget.isSecondary ? null : AppColors.brownGradient,
            color: widget.isSecondary ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(16),
            border: widget.isSecondary
                ? Border.all(color: AppColors.secondaryGreen, width: 1.5)
                : null,
            boxShadow: widget.isSecondary ? null : [
              BoxShadow(
                color: AppColors.shadowBrown,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.isLoading
              ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: widget.isSecondary
                  ? AppColors.secondaryGreen
                  : AppColors.textWhite,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    size: 20,
                    color: widget.isSecondary
                        ? AppColors.secondaryGreen
                        : AppColors.textWhite),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isSecondary
                      ? AppColors.secondaryGreen
                      : AppColors.textWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}