import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Primary (Poppins)
  static TextStyle headingHero = GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold);
  static TextStyle heading1 = GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold);
  static TextStyle heading2 = GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle heading3 = GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600);
  
  static TextStyle buttonLabel = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle label = GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500);

  // Body (Roboto)
  static TextStyle bodyLarge = GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.normal);
  static TextStyle bodyMedium = GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.normal);
  static TextStyle bodySmall = GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.normal);
}
