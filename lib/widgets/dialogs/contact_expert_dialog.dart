import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/app_colors.dart';

class ContactExpertDialog extends StatelessWidget {
  final String? diseaseName;

  const ContactExpertDialog({super.key, this.diseaseName});

  @override
  Widget build(BuildContext context) {
    final message = diseaseName != null
        ? context.tr(
            'expert.personalized_guidance',
            namedArgs: {'diseaseName': diseaseName!},
          )
        : context.tr('expert.connect_specialists');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.darkGreen, Color(0xFF0A2E24)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.green.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.agriculture_rounded,
                color: AppColors.green,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('expert.need_help_title'),
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textWhiteMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    onPressed: () => Navigator.pop(context),
                    isSecondary: true,
                    child: Text(context.tr('common.cancel')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    onPressed: () {
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                    },
                    child: Text(context.tr('expert.connect_now')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool isSecondary;

  const _DialogButton({
    required this.child,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scale = Tween(begin: 1.0, end: 0.98).animate(
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
    _controller.reverse().then((_) => widget.onPressed());
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: widget.isSecondary ? null : AppColors.brownGradient,
            color: widget.isSecondary ? AppColors.surfaceWhite : null,
            borderRadius: BorderRadius.circular(14),
            border: widget.isSecondary
                ? Border.all(
                    color: AppColors.green.withOpacity(0.6),
                    width: 1.5,
                  )
                : null,
          ),
          child: Center(
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: widget.isSecondary ? AppColors.green : AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}