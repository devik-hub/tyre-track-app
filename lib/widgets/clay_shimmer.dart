import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tyre_management/app/theme/app_colors.dart';

/// Claymorphic shimmer loading placeholder.
class ClayShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ClayShimmerCard({
    super.key,
    this.height = 80,
    this.width,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.background,
      highlightColor: Colors.white,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
