import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.mrfRed,
      scaffoldBackgroundColor: AppColors.mrfLightGrey,
      colorScheme: const ColorScheme.light(
        primary: AppColors.mrfRed,
        secondary: AppColors.mrfBlack,
        error: AppColors.mrfOrange,
        surface: AppColors.mrfWhite,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.mrfRed,
        foregroundColor: AppColors.mrfWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.mrfWhite,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mrfRed,
          foregroundColor: AppColors.mrfWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 2,
          minimumSize: const Size(double.infinity, 48),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mrfRed,
          side: const BorderSide(color: AppColors.mrfRed, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          minimumSize: const Size(double.infinity, 48),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.mrfWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.mrfWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.mrfMidGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.mrfMidGrey.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.mrfRed, width: 2),
        ),
        labelStyle: GoogleFonts.roboto(color: AppColors.mrfMidGrey),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.mrfWhite,
        selectedItemColor: AppColors.mrfRed,
        unselectedItemColor: AppColors.mrfMidGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.robotoTextTheme(),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.mrfRed,
      scaffoldBackgroundColor: AppColors.mrfBlack,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.mrfRed,
        secondary: AppColors.mrfLightGrey,
        error: AppColors.mrfOrange,
        surface: AppColors.mrfDarkGrey,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.mrfDarkGrey,
        foregroundColor: AppColors.mrfWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.mrfWhite,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.mrfDarkGrey,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
    );
  }
}
