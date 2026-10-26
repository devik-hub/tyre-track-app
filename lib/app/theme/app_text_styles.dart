import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Claymorphism typography system — Poppins throughout.
/// No Inter fallback needed — Poppins for everything per spec.
class AppTextStyles {
  AppTextStyles._();

  // ── Helper with guaranteed fallback ────────────────────────────
  static TextStyle _poppins({
    required double fontSize,
    required FontWeight fontWeight,
    double letterSpacing = 0,
    double height = 1.2,
    Color? color,
  }) {
    try {
      return GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Poppins',
        fontFamilyFallback: const ['Helvetica Neue', 'Arial', 'sans-serif'],
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
  }

  // ─── DISPLAY (hero text, screen titles) ─ 22–28px Bold ────────
  static final TextStyle display1 = _poppins(
    fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.8, height: 1.1,
  );
  static final TextStyle display2 = _poppins(
    fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.6, height: 1.15,
  );

  // ─── HEADINGS ─ Poppins Bold, 22–28px ─────────────────────────
  static final TextStyle h1 = _poppins(
    fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4, height: 1.2,
  );
  static final TextStyle h2 = _poppins(
    fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3, height: 1.25,
  );
  static final TextStyle h3 = _poppins(
    fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.3,
  );

  // ─── BODY ─ Poppins Regular, 14–16px ──────────────────────────
  static final TextStyle body1 = _poppins(
    fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: -0.1, height: 1.5,
  );
  static final TextStyle body2 = _poppins(
    fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.5,
  );

  // ─── LABELS ─ Poppins SemiBold, 12–14px, letterSpacing 0.5 ───
  static final TextStyle label1 = _poppins(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.3,
  );
  static final TextStyle label2 = _poppins(
    fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.3,
  );
  static final TextStyle labelCaps = _poppins(
    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, height: 1.2,
  );

  // ─── MONOSPACE (order IDs, codes) ─────────────────────────────
  static final TextStyle mono = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontFamilyFallback: const ['Courier New', 'monospace'],
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // ─── BUTTON ───────────────────────────────────────────────────
  static final TextStyle button = _poppins(
    fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3, height: 1.2,
    color: Colors.white,
  );
  static final TextStyle buttonSm = _poppins(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.3,
    color: Colors.white,
  );

  // ─── LEGACY ALIASES ───────────────────────────────────────────
  static TextStyle get headingHero => display2;
  static TextStyle get heading1 => h1;
  static TextStyle get heading2 => h2;
  static TextStyle get heading3 => h3;
  static TextStyle get buttonLabel => button;
  static TextStyle get titleLarge => h1;
  static TextStyle get titleMedium => h2;
  static TextStyle get titleSmall => h3;
  static TextStyle get labelLarge => label1;
  static TextStyle get labelMedium => label1;
  static TextStyle get labelSmall => label2;
  static TextStyle get bodyLarge => body1;
  static TextStyle get bodyMedium => body2;
  static TextStyle get bodySmall => _poppins(fontSize: 12, fontWeight: FontWeight.normal);
  static TextStyle get caption => bodySmall;
}
