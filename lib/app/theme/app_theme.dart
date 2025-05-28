import 'package:flutter/material.dart';

/// Centralized theme settings for the app.
/// This helps keep the UI consistent across all screens.
class AppTheme {
  // Define custom color palette
  static const Color primaryColor = Color(0xFF0056B3); // deep blue
  static const Color accentColor = Color(0xFF29B6F6); // light blue
  static const Color backgroundColor = Color(0xFFF4F4F4); // light gray

  // Light mode theme setup
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // Enables Material Design 3
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
