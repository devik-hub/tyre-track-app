import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tyre_management/app/theme/app_colors.dart';
import 'package:tyre_management/app/theme/app_text_styles.dart';

/// Claymorphism App Bar.
/// Specifications:
/// - Background: #E8001D gradient with white clay card layered below
/// - Logo/Brand: MRF / Jagadale Retreads text in bold + tyre/brand icon
/// - Action buttons with clay circle button styling
class ClayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBrandHeader;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final bool isDark;

  const ClayAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.showBrandHeader = false,
    this.showBackButton = true,
    this.onBackPressed,
    this.bottom,
    this.isDark = false,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0) + (showBrandHeader ? 20 : 8));

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPadding + 4, bottom: 8, left: 16, right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.adminBg2, AppColors.adminBg1]
              : [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top brand subtitle if enabled
          if (showBrandHeader) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.disc, size: 14, color: AppColors.secondary),
                const Gap(6),
                Text(
                  'MRF RETREADS • JAGADALE RETREADS',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Gap(6),
          ],
          // Main bar row
          Row(
            children: [
              if (leading != null)
                leading!
              else if (showBackButton && canPop)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (onBackPressed != null) {
                      onBackPressed!();
                    } else {
                      Navigator.maybePop(context);
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.chevronLeft,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 4),
              const Gap(12),
              Expanded(
                child: titleWidget ??
                    Text(
                      title ?? '',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          if (bottom != null) bottom!,
        ],
      ),
    );
  }
}
