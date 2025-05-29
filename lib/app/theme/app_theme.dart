import 'package:flutter/material.dart';

// @formatter:on
/// Centralized app theme configuration.
/// Easily switch to darkTheme or add global fonts.
class AppTheme {
  static const Color primaryColor = Color(0xFF0056B3); // Deep blue
  static const Color accentColor = Color(0xFF29B6F6); // Sky blue
  static const Color backgroundColor = Color(0xFFF4F4F4); // Light gray

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),

    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
