import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tyre_management/app/theme/app_colors.dart';
import 'package:tyre_management/app/theme/app_text_styles.dart';

/// Claymorphism app bar — clay card style with MRF red gradient header.
/// Replaces every AppBar() in the app.
class LiquidGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool isDark;
  final bool centerTitle;
  final Widget? titleWidget;
  final double blurStrength; // Kept for API compat
  final bool showBrandSubtitle;

  const LiquidGlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.isDark = false,
    this.centerTitle = true,
    this.titleWidget,
    this.blurStrength = 0,
    this.showBrandSubtitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    const overlayStyle = SystemUiOverlayStyle.light;

    final hasLeading = leading != null || Navigator.canPop(context);
    final hasActions = actions != null && actions!.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Container(
        height: 64 + MediaQuery.of(context).padding.top,
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
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.adminCardBase : Colors.white).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (leading != null)
                  leading!
                else if (Navigator.canPop(context))
                  _buildBackButton(context)
                else if (hasActions && centerTitle)
                  const SizedBox(width: 36),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: titleWidget ??
                        (showBrandSubtitle
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: centerTitle
                                    ? CrossAxisAlignment.center
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.h2.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Authorized MRF Franchise',
                                    textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 10,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                title,
                                textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.h2.copyWith(
                                  color: Colors.white,
                                ),
                              )),
                  ),
                ),
                if (hasActions)
                  Row(mainAxisSize: MainAxisSize.min, children: actions!)
                else if (hasLeading && centerTitle)
                  const SizedBox(width: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
