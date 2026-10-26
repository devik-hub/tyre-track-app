import 'package:flutter/material.dart';
import 'package:tyre_management/app/theme/app_colors.dart';

/// Soft pinkish-white claymorphism background for customer screens.
/// Uses #F5E6E6 as specified by MRF Brand design tokens.
class CustomerBackground extends StatelessWidget {
  final Widget child;
  final bool showRedOrb;

  const CustomerBackground({
    super.key,
    required this.child,
    this.showRedOrb = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          // Subtle warm ambient radial gradient at top-right
          if (showRedOrb)
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          // Subtle secondary warmth at bottom-left
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.06),
                    AppColors.secondary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Content
          child,
        ],
      ),
    );
  }
}
