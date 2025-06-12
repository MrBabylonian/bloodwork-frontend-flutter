import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

/// Defines gradient styles used throughout the application.
///
/// This class provides consistent gradient definitions that match
/// the application's color palette and design language.
class AppGradients {
  /// Primary gradient applied from top-left to bottom-right (135 degrees)
  /// Used for premium elements and brand highlights
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientStart, // #007AFF (Primary Blue)
      AppColors.gradientEnd, // #5856D6 (Purple)
    ],
  );

  /// Success gradient that transitions from light to dark green
  /// Used for positive feedback and success states
  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4CD964), // Light green
      AppColors.successGreen,
    ],
  );

  /// Warning gradient that transitions from yellow to orange
  /// Used for warning states and notifications
  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFCC00), // Yellow
      AppColors.warningOrange,
    ],
  );

  /// Destructive gradient that transitions from light to dark red
  /// Used for error states and destructive actions
  static const LinearGradient destructive = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B), // Light red
      AppColors.destructiveRed,
    ],
  );

  /// Subtle gradient for backgrounds and cards
  /// Provides a barely noticeable depth to flat surfaces
  static const LinearGradient subtle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.backgroundWhite,
      Color(0xFFF8F8F8), // Very subtle off-white
    ],
  );

  /// Glass effect gradient for translucent UI elements
  /// Creates a frosted glass appearance
  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF), // Semi-transparent white
      Color(0x10FFFFFF), // More transparent white
    ],
  );
}
