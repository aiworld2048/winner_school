import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    final base = ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        textStyle: base.displayLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: -1,
      ),
      displayMedium: GoogleFonts.poppins(
        textStyle: base.displayMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.poppins(
        textStyle: base.displaySmall,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.poppins(
        textStyle: base.headlineLarge,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.poppins(
        textStyle: base.headlineSmall,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.poppins(
        textStyle: base.titleMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      titleSmall: GoogleFonts.poppins(
        textStyle: base.titleSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: base.bodyLarge,
        height: 1.4,
      ),
      bodyMedium: GoogleFonts.inter(
        textStyle: base.bodyMedium,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.inter(
        textStyle: base.bodySmall,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.poppins(
        textStyle: base.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: GoogleFonts.poppins(
        textStyle: base.labelMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      labelSmall: GoogleFonts.poppins(
        textStyle: base.labelSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
}

