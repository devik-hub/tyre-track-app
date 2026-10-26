import 'package:flutter/material.dart';
import 'package:tyre_management/app/theme/app_colors.dart';

/// Dark gradient background with subtle MRF red ambient glow for admin screens.
class AdminBackground extends StatelessWidget {
  final Widget child;

  const AdminBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.adminBg1,
            AppColors.adminBg2,
            AppColors.adminBg1,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle MRF red glow at top
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width / 2 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    AppColors.primary.withOpacity(0.0),
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
