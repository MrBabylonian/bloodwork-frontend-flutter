import 'package:flutter/material.dart';

/// AppColors defines the color palette for the entire application.
///
/// This follows Apple's Human Interface Guidelines with a professional,
/// medical-grade appearance suitable for bloodwork analysis applications.

class AppColors {
  /// Primary blue color for main actions, brand elements, and active states
  /// Used in primary buttons, links, progress indicators
  static const Color primaryBlue = Color(0xFF007AFF);

  /// Foreground color for elements on an accent background (e.g., text on a primaryBlue button)
  static const Color accentForeground = Color(0xFFFFFFFF); // White

  /// Background color for popover elements like dropdowns, menus
  static const Color popoverBackground = Color(0xFFFFFFFF); // Typically white

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

  /// General border color, can be an alias for borderGray or a slightly different shade
  static const Color border = borderGray;

  // Semantic Aliases (derived from base palette for clarity)

  /// Color for secondary text elements (often same as mediumGray)
  static const Color textSecondary = mediumGray;

  /// Color for disabled text elements
  static const Color textDisabled = Color(
    0x618E8E93,
  ); // mediumGray at 38% opacity

  /// Color for secondary backgrounds (e.g., input fields, selected items)
  static const Color backgroundSecondary = lightGray;

  /// Color for disabled backgrounds or components
  static const Color backgroundDisabled = Color(
    0xFFE5E5EA,
  ); // A slightly darker, less vibrant gray

  /// Color for error text and icons (often same as destructiveRed)
  static const Color error = destructiveRed;

  // Accent colors

  /// Green color for success states, positive feedback, checkmarks
  static const Color successGreen = Color(0xFF34C759);

  /// Orange color for warning states, processing notices, important info
  static const Color warningOrange = Color(0xFFFF9500);

  /// Red color for error states, delete actions, and critical alerts
  static const Color destructiveRed = Color(0xFFFF3B30);

  /// Alias for error red color
  static const Color errorRed = destructiveRed;

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

  /// Transparent color
  static const Color transparent = Color(0x00000000);

  /// Muted background color
  static const Color muted = Color(0xFFF1F5F9); // Example: A light gray

  /// Muted foreground color (text on muted background)
  static const Color mutedForeground = Color(
    0xFF64748B,
  ); // Example: A darker gray

  /// Primary gradient applied from top-left to bottom-right (135 degrees)
  /// Used for premium element and brand highligts
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );
}
