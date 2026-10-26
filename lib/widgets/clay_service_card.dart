import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tyre_management/app/theme/app_colors.dart';
import 'package:tyre_management/app/theme/app_text_styles.dart';
import 'package:tyre_management/app/theme/clay_decorations.dart';
import 'clay_card.dart';

/// Service listing card with Claymorphism design.
/// Specifications:
/// - 16px internal padding
/// - Leading clay icon container (48x48, radius 14, gradient background)
/// - Title + Subtitle stack
/// - Optional price / trailing badge / action
class ClayServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color accentColor;
  final bool isDark;

  const ClayServiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.trailing,
    this.accentColor = AppColors.primary,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      onTap: onTap,
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 48x48 Clay icon container
          Container(
            width: 48,
            height: 48,
            decoration: ClayDecorations.iconContainer(
              accentColor: accentColor,
              radius: 14,
              isDark: isDark,
            ),
            child: Center(child: icon),
          ),
          const Gap(16),
          // Title + Subtitle stack
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark ? AppColors.adminTextPrimary : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.adminTextSec : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const Gap(12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
