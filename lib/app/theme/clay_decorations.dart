import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralised Claymorphism decoration tokens.
/// Every card/container in the app MUST use these — never hardcode shadows.
class ClayDecorations {
  ClayDecorations._();

  // ─── CARD (default claymorphism surface) ──────────────────────
  static BoxDecoration card({
    double borderRadius = 28,
    Color? color,
    bool isDark = false,
  }) {
    final baseColor = color ?? (isDark
        ? AppColors.adminCardBase.withOpacity(0.92)
        : Colors.white.withOpacity(0.92));

    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFE8001D).withOpacity(0.18),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.9),
          blurRadius: 12,
          spreadRadius: -2,
          offset: const Offset(-4, -4),
        ),
      ],
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.6),
        width: 1.5,
      ),
    );
  }

  // ─── FEATURE CARD (larger radius, stronger shadow) ────────────
  static BoxDecoration featureCard({bool isDark = false}) => card(
    borderRadius: 32,
    isDark: isDark,
  );

  // ─── BUTTON DECORATION ────────────────────────────────────────
  static BoxDecoration primaryButton() => BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primary, AppColors.primaryDark],
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.35),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.2),
        blurRadius: 8,
        spreadRadius: -2,
        offset: const Offset(-2, -2),
      ),
    ],
  );

  static BoxDecoration secondaryButton({bool isDark = false}) => BoxDecoration(
    color: isDark
        ? AppColors.adminCardBase.withOpacity(0.9)
        : Colors.white.withOpacity(0.92),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFE8001D).withOpacity(0.10),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(isDark ? 0.05 : 0.8),
        blurRadius: 8,
        spreadRadius: -2,
        offset: const Offset(-2, -2),
      ),
    ],
    border: Border.all(
      color: Colors.white.withOpacity(isDark ? 0.1 : 0.5),
      width: 1.5,
    ),
  );

  // ─── INPUT FIELD ──────────────────────────────────────────────
  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isDark = false,
  }) => InputDecoration(
    hintText: hintText,
    labelText: labelText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: isDark ? const Color(0xFF2A2A2E) : const Color(0xFFFFF5F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE0D0D0),
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE0D0D0),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE8001D), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  // ─── ICON CONTAINER ───────────────────────────────────────────
  static BoxDecoration iconContainer({
    Color accentColor = AppColors.primary,
    double radius = 14,
    bool isDark = false,
  }) => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accentColor.withOpacity(0.15),
        accentColor.withOpacity(0.08),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: accentColor.withOpacity(0.12),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
    border: Border.all(
      color: accentColor.withOpacity(0.2),
      width: 1,
    ),
  );

  // ─── BOTTOM NAV ───────────────────────────────────────────────
  static BoxDecoration bottomNav({bool isDark = false}) => BoxDecoration(
    color: isDark
        ? AppColors.adminCardBase.withOpacity(0.95)
        : Colors.white.withOpacity(0.95),
    borderRadius: BorderRadius.circular(32),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFE8001D).withOpacity(0.18),
        blurRadius: 24,
        spreadRadius: 0,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(isDark ? 0.05 : 0.9),
        blurRadius: 12,
        spreadRadius: -2,
        offset: const Offset(-4, -4),
      ),
    ],
    border: Border.all(
      color: Colors.white.withOpacity(isDark ? 0.1 : 0.6),
      width: 1.5,
    ),
  );

  // ─── CHIP ─────────────────────────────────────────────────────
  static BoxDecoration chip({bool isSelected = false}) => BoxDecoration(
    color: isSelected
        ? AppColors.primary
        : Colors.white.withOpacity(0.92),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: isSelected
            ? AppColors.primary.withOpacity(0.25)
            : const Color(0xFFE8001D).withOpacity(0.08),
        blurRadius: isSelected ? 12 : 8,
        offset: const Offset(0, 4),
      ),
      if (!isSelected)
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          blurRadius: 6,
          spreadRadius: -1,
          offset: const Offset(-2, -2),
        ),
    ],
    border: isSelected
        ? null
        : Border.all(color: Colors.white.withOpacity(0.5), width: 1),
  );

  // ─── STATUS BADGE ─────────────────────────────────────────────
  static BoxDecoration statusBadge(Color color) => BoxDecoration(
    color: color.withOpacity(0.12),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: color.withOpacity(0.3), width: 1),
  );
}
