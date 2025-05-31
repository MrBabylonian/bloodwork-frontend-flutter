import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// @formatter:on
class AppTheme {
  // Core colors
  static const Color primaryColor = Color(0xFF0056B3);
  static const Color accentColor = Color(0xFF29B6F6);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  // Additional colors for enhanced UI
  static const Color secondaryColor = Color(0xFF4A86E8);
  static const Color successColor = Color(0xFF34A853);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color dangerColor = Color(0xFFEA4335);
  static const Color neutralDarkColor = Color(0xFF2D3142);
  static const Color neutralColor = Color(0xFF6D7278);
  static const Color neutralLightColor = Color(0xFFECEFF1);
  static const Color cardBgColor = Color(0xFFFFFFFF);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,

    // Apply Google Fonts to entire theme
    textTheme: TextTheme(
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: neutralDarkColor,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: neutralDarkColor,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: neutralDarkColor,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: neutralDarkColor,
      ),
      bodyLarge: GoogleFonts.workSans(
        fontSize: 16,
        height: 1.5,
        color: neutralDarkColor,
      ),
      bodyMedium: GoogleFonts.workSans(
        fontSize: 14,
        height: 1.5,
        color: neutralDarkColor,
      ),
      bodySmall: GoogleFonts.workSans(
        fontSize: 12,
        height: 1.5,
        color: neutralColor,
      ),
    ),

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: cardBgColor,
      error: dangerColor,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    cardTheme: CardTheme(
      color: cardBgColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: cardBgColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: neutralDarkColor,
      ),
      iconTheme: const IconThemeData(color: primaryColor),
    ),
  );
}
