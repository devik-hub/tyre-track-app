import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tyre_management/app/theme/app_colors.dart';
import 'package:tyre_management/app/theme/app_text_styles.dart';

/// Claymorphism Button.
/// Specifications:
/// - RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
/// - Primary: Gradient #E8001D to #B0001A with inner highlight & clay shadow
/// - Minimum height: 54px
/// - Press animation: AnimatedScale(scale: 0.96)
class ClayButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final Widget? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? customColor;
  final bool isDark;

  const ClayButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = true,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 54,
    this.customColor,
    this.isDark = false,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null && !widget.isLoading;

    final child = AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: widget.width ?? double.infinity,
        height: widget.height,
        decoration: widget.isPrimary
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(-2, -2),
                  ),
                ],
              )
            : BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: widget.isDark
                    ? AppColors.adminCardBase.withOpacity(0.92)
                    : Colors.white.withOpacity(0.92),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8001D).withOpacity(0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(widget.isDark ? 0.05 : 0.85),
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(-3, -3),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(widget.isDark ? 0.1 : 0.6),
                  width: 1.5,
                ),
              ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Subtle top-inner highlight for clay/pill feel
              if (widget.isPrimary)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isPrimary ? Colors.white : AppColors.primary,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            widget.icon!,
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: widget.isPrimary
                                  ? Colors.white
                                  : (widget.isDark
                                      ? AppColors.adminTextPrimary
                                      : AppColors.textPrimary),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!isEnabled) {
      return Opacity(opacity: 0.5, child: child);
    }

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: child,
    );
  }
}
