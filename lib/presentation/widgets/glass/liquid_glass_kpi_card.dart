import 'package:flutter/material.dart';
import 'package:tyre_management/app/theme/app_colors.dart';
import 'package:tyre_management/app/theme/app_text_styles.dart';
import 'package:tyre_management/app/theme/clay_decorations.dart';

/// Claymorphism KPI card for admin dashboard stats.
class LiquidGlassKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isDark;

  const LiquidGlassKpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.accentColor = AppColors.primary,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.adminCardBase : Colors.white).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: (isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.9)),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(-4, -4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.1 : 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: ClayDecorations.iconContainer(
              accentColor: accentColor,
              radius: 14,
              isDark: isDark,
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.display2.copyWith(
              color: isDark ? AppColors.adminTextPrimary : AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.label2.copyWith(
              color: isDark ? AppColors.adminTextSec : AppColors.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTextStyles.label2.copyWith(color: accentColor, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}
