import "package:flutter/cupertino.dart";

/// AppColors defines the color palette for the entire application.
///
/// This follows Apple's Human Interface Guidelines with a professional,
/// medical-grade appearance suitable for bloodwork analysis applications.

class AppColors {
  /// Primary blue color for main actions, brand elements, and active states
  /// Used in primary buttons, links, progress indicators
  static const Color primaryBlue = Color(0xFF007AFF);

  /// Main background color for pages, cards, and dialog backgrounds
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  /// Main text color for headings, body text, and icons
  static const Color foregroundDark = Color(0xFF1C1C1E);

  // Secondary colors

  /// Light gray for secondary UI elements, subtle backgrounds, input fields
  static const Color lightGray = Color(0xFFF2F2F7);

  /// Used for secondary text, placeholders, and muted content
  static const Color mediumGray = Color(0xFF8E8E93);

  /// Used for borders, dividers, and subtle separations between elements
  static const Color borderGray = Color(0xFFDCDCDC);

  // Accent colors

  /// Green color for success states, positive feedback, checkmarks
  static const Color successGreen = Color(0xFF34C759);

  /// Orange color for warning states, processing notices, important info
  static const Color warningOrange = Color(0xFFFF9500);

  /// Red color for error states, delete actions, and critical alerts
  static const Color destructiveRed = Color(0xFFFF3B30);

  // Gradient colors

  /// Starting color for primary gradient (matches primaryBlue)
  static const Color gradientStart = Color(0xFF007AFF);

  /// Ending color for primary gradient
  static const Color gradientEnd = Color(0xFF5856D6);

  // Additional utility colors

  /// Shadow color with 10% opacity for subtle elevation effects
  static const Color shadowColor = Color(0x1A000000);

  /// Pure white for text on dark backgrounds and overlay elements
  static const Color white = Color(0xFFFFFFFF);

  /// Primary gradient applied from top-left to bottom-right (135 degrees)
  /// Used for premium element and brand highligts
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );
}
