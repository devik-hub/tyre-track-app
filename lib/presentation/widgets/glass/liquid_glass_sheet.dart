import 'package:flutter/material.dart';
import 'package:tyre_management/app/theme/app_colors.dart';

/// Claymorphism bottom sheet replacement.
/// No glassmorphism / backdrop blur. Pure clay container with rounded top.
void showLiquidGlassSheet(
  BuildContext context, {
  required Widget child,
  bool isDark = false,
  bool isDismissible = true,
  double initialChildSize = 0.5,
  double maxChildSize = 0.95,
  double minChildSize = 0.25,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: isDismissible,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      maxChildSize: maxChildSize,
      minChildSize: minChildSize,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            color: isDark ? AppColors.adminCardBase : Colors.white.withOpacity(0.96),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE8001D).withOpacity(0.18),
                blurRadius: 28,
                spreadRadius: 0,
                offset: const Offset(0, -8),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(isDark ? 0.05 : 0.9),
                blurRadius: 12,
                spreadRadius: -2,
                offset: const Offset(0, -2),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                width: 1.5,
              ),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isDark ? Colors.white24 : const Color(0xFFE0D0D0),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
