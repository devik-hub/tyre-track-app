import 'package:flutter/material.dart';
import 'package:tyre_management/app/theme/app_text_styles.dart';

/// Claymorphism status badge — subtle clay pill.
class LiquidGlassStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool glow;

  const LiquidGlassStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelCaps.copyWith(color: color),
      ),
    );
  }
}
