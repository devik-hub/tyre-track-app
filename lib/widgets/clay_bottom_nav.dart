import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tyre_management/app/theme/app_colors.dart';
import 'package:tyre_management/app/theme/app_text_styles.dart';
import 'package:tyre_management/app/theme/clay_decorations.dart';

/// Item definition for [ClayBottomNav].
class ClayBottomNavItem {
  final Widget icon;
  final Widget? activeIcon;
  final String label;

  const ClayBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// Floating Claymorphism Bottom Navigation Bar.
/// Specifications:
/// - Margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16)
/// - BorderRadius: 32px
/// - Background: white with dual clay shadows
/// - Selected: #E8001D dot indicator below icon
/// - Unselected: #5C5C5C
class ClayBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ClayBottomNavItem> items;
  final bool isDark;

  const ClayBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, (bottomInset > 0 ? bottomInset : 16)),
      child: Container(
        height: 68,
        decoration: ClayDecorations.bottomNav(isDark: isDark),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(index);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.12 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.adminTextTert
                                : AppColors.textSecondary),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Red dot indicator below selected icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 5 : 0,
                      height: isSelected ? 5 : 0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
