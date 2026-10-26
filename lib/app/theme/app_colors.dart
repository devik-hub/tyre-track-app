import 'dart:ui';
import 'package:flutter/material.dart';

/// Claymorphism Design Tokens for Jagadale Retreads / MRF Franchise.
/// EVERY colour used in the app MUST come from this file — never hardcode.
class AppColors {
  AppColors._();

  // ─── MRF BRAND (EXACT HEX — DO NOT ALTER) ─────────────────────
  static const Color primary       = Color(0xFFE8001D); // MRF Red
  static const Color primaryDark   = Color(0xFFB0001A); // Deep MRF Red
  static const Color secondary     = Color(0xFFFFD700); // MRF Gold/Yellow
  static const Color success       = Color(0xFF2ECC71);
  static const Color warning       = Color(0xFFF39C12);
  static const Color error         = Color(0xFFE74C3C);

  // ─── SURFACES ──────────────────────────────────────────────────
  static const Color surface       = Color(0xFFFFF5F5); // Warm White
  static const Color background    = Color(0xFFF5E6E6); // Soft Pinkish White
  static const Color cardBase      = Color(0xFFFFFFFF);

  // ─── TEXT ──────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5C5C5C);
  static const Color textOnRed     = Color(0xFFFFFFFF);
  static const Color textTertiary  = Color(0xFF9A9A9A);

  // ─── CLAY SHADOWS (computed from primary) ──────────────────────
  static const Color clayShadowRed   = Color(0x2EE8001D); // primary @ 0.18
  static const Color clayShadowWhite = Color(0xE6FFFFFF); // white @ 0.9

  // ─── ADMIN / DARK MODE ─────────────────────────────────────────
  static const Color adminBg1        = Color(0xFF0D0D0F);
  static const Color adminBg2        = Color(0xFF141416);
  static const Color adminBg3        = Color(0xFF1C1C1F);
  static const Color adminTextPrimary = Color(0xFFF0F0F0);
  static const Color adminTextSec    = Color(0xFFAAAAAA);
  static const Color adminTextTert   = Color(0xFF666666);
  static const Color adminCardBase   = Color(0xFF1E1E22);

  // ─── LEGACY ALIASES (deprecated — use modern design system tokens) ──
  @Deprecated('Use AppColors.primary instead')
  static const Color mrfRed       = primary;
  @Deprecated('Use AppColors.primaryDark instead')
  static const Color mrfDarkRed   = primaryDark;
  @Deprecated('Use AppColors.secondary instead')
  static const Color mrfGold      = secondary;
  @Deprecated('Use AppColors.success instead')
  static const Color mrfGreen     = success;
  @Deprecated('Use AppColors.warning instead')
  static const Color mrfOrange    = warning;
  @Deprecated('Use AppColors.clayShadowRed instead')
  static const Color mrfRedGlow   = clayShadowRed;
  @Deprecated('Use AppColors.primary with alpha instead')
  static const Color mrfRedTint   = Color(0x15E8001D);
  @Deprecated('Use AppColors.textPrimary or AppColors.adminBg1 instead')
  static const Color mrfBlack     = textPrimary;
  @Deprecated('Use AppColors.cardBase instead')
  static const Color mrfWhite     = cardBase;
  @Deprecated('Use AppColors.surface instead')
  static const Color mrfLightGrey = surface;
  @Deprecated('Use AppColors.background instead')
  static const Color lightBg1     = background;
  @Deprecated('Use AppColors.surface instead')
  static const Color lightBg2     = Color(0xFFF0E0E0);
  @Deprecated('Use AppColors.surface instead')
  static const Color lightBg3     = Color(0xFFEDDADA);

  // Glass aliases (for screens still referencing them during migration)
  static const Color glassWhite       = Color(0xEBFFFFFF);
  static const Color glassWhiteThin   = Color(0x80FFFFFF);
  static const Color glassWhiteThick  = Color(0xF2FFFFFF);
  static const Color glassBorder      = Color(0x99FFFFFF);
  static const Color glassSpecular    = Color(0x60FFFFFF);
  static const Color glassShadow      = Color(0x1A000000);
  static const Color glassDark        = Color(0xFF1E1E22);
  static const Color glassDarkBorder  = Color(0x40FFFFFF);
  static const Color glassDarkSpecular = Color(0x20FFFFFF);
  static const Color glassDarkThick   = Color(0xF2141416);
  static const Color glassDarkThin    = Color(0x40000000);
  static const Color glassRedTinted   = Color(0x20E8001D);
  static const Color glassShadowDeep  = Color(0x33000000);
  static const Color glassMidnightBlue = Color(0x801A1A2E);

  // Background gradient
  static const Color gradientTop  = Color(0xFFFFF5F5);
  static const Color gradientMid  = Color(0xFFF5E6E6);
  static const Color gradientBtm  = Color(0xFFEFE0E0);

  // Admin background aliases
  static const Color adminBg4     = Color(0xFF242428);
  static const Color adminRedZone = Color(0xFF1A0000);
}
