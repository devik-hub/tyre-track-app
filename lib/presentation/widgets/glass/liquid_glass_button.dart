import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tyre_management/app/theme/app_colors.dart';
import 'package:tyre_management/app/theme/app_text_styles.dart';
import 'package:tyre_management/app/theme/clay_decorations.dart';

enum GlassButtonVariant { primary, secondary, ghost, danger, success }

/// Claymorphism button with gradient primary, press animation, and 54px min height.
class LiquidGlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final GlassButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isDark;
  final double? width;
  final double height;

  const LiquidGlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = GlassButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isDark = false,
    this.width,
    this.height = 54,
  });

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  BoxDecoration get _decoration {
    if (!_isEnabled && !widget.isLoading) {
      return BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      );
    }

    switch (widget.variant) {
      case GlassButtonVariant.primary:
        return ClayDecorations.primaryButton();
      case GlassButtonVariant.secondary:
        return ClayDecorations.secondaryButton(isDark: widget.isDark);
      case GlassButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        );
      case GlassButtonVariant.danger:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [AppColors.error, AppColors.error.withOpacity(0.85)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case GlassButtonVariant.success:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [AppColors.success, AppColors.success.withOpacity(0.85)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
    }
  }

  Color get _textColor {
    if (!_isEnabled && !widget.isLoading) {
      return widget.isDark ? AppColors.adminTextTert : AppColors.textTertiary;
    }

    switch (widget.variant) {
      case GlassButtonVariant.primary:
      case GlassButtonVariant.danger:
      case GlassButtonVariant.success:
        return Colors.white;
      case GlassButtonVariant.secondary:
        return widget.isDark ? AppColors.adminTextPrimary : AppColors.textPrimary;
      case GlassButtonVariant.ghost:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _isEnabled
            ? (_) {
                _controller.forward();
                HapticFeedback.lightImpact();
              }
            : null,
        onTapUp: _isEnabled ? (_) => _controller.reverse() : null,
        onTapCancel: _isEnabled ? () => _controller.reverse() : null,
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: widget.width,
          height: widget.height,
          decoration: _decoration,
          child: widget.isLoading
              ? Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(_textColor),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: _textColor, size: 22),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: AppTextStyles.button.copyWith(color: _textColor),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
