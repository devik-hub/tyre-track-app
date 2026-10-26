import 'package:flutter/material.dart';
import 'package:tyre_management/app/theme/app_colors.dart';
import 'package:tyre_management/app/theme/app_text_styles.dart';
import 'package:tyre_management/app/theme/clay_decorations.dart';

/// Claymorphism text field — filled with warm white, 16px radius, red focus border.
class LiquidGlassTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool isDark;
  final int maxLines;
  final bool enabled;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;

  const LiquidGlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixWidget,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.isDark = false,
    this.maxLines = 1,
    this.enabled = true,
    this.textInputAction,
    this.focusNode,
    this.onEditingComplete,
    this.onFieldSubmitted,
  });

  @override
  State<LiquidGlassTextField> createState() => _LiquidGlassTextFieldState();
}

class _LiquidGlassTextFieldState extends State<LiquidGlassTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTextStyles.label1.copyWith(
              color: widget.isDark ? AppColors.adminTextSec : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: -2,
                      offset: const Offset(-2, -2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.7),
                      blurRadius: 6,
                      spreadRadius: -1,
                      offset: const Offset(-2, -2),
                    ),
                  ],
          ),
          child: Focus(
            onFocusChange: (focused) => setState(() => _isFocused = focused),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              onChanged: widget.onChanged,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              textInputAction: widget.textInputAction,
              focusNode: widget.focusNode,
              onEditingComplete: widget.onEditingComplete,
              onFieldSubmitted: widget.onFieldSubmitted,
              style: AppTextStyles.body1.copyWith(
                color: widget.isDark ? AppColors.adminTextPrimary : AppColors.textPrimary,
              ),
              decoration: ClayDecorations.inputDecoration(
                hintText: widget.hintText,
                isDark: widget.isDark,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? AppColors.primary
                            : (widget.isDark ? AppColors.adminTextSec : AppColors.textSecondary),
                        size: 22,
                      )
                    : null,
                suffixIcon: widget.suffixWidget,
              ).copyWith(
                hintStyle: AppTextStyles.body1.copyWith(
                  color: widget.isDark ? AppColors.adminTextTert : AppColors.textTertiary,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: widget.maxLines > 1 ? 16 : 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
