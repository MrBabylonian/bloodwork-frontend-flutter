import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

/// AppTextStyles defines typography for the entire application.
///
/// This follows a professional medical aesthetic with clear hierarchy
/// and readability optimized for both web and mobile platforms.
class AppTextStyles {
  // Heading styles

  /// Large title style used for main page headings
  static const TextStyle largeTitle = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 34.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.41,
    color: AppColors.foregroundDark,
    height: 1.2,
  );

  /// Title style used for section headings
  static const TextStyle title1 = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.41,
    color: AppColors.foregroundDark,
    height: 1.3,
  );

  /// Secondary heading style
  static const TextStyle title2 = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.24,
    color: AppColors.foregroundDark,
    height: 1.3,
  );

  /// Small heading style used for card titles and subsections
  static const TextStyle title3 = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.24,
    color: AppColors.foregroundDark,
    height: 1.4,
  );

  // Body text styles

  /// Primary body text style used for most content
  static const TextStyle body = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 17.0,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.41,
    color: AppColors.foregroundDark,
    height: 1.5,
  );

  /// Secondary, smaller body text for details and descriptions
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 15.0,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.24,
    color: AppColors.foregroundDark,
    height: 1.5,
  );

  // Button and interactive element styles

  /// Text style for primary buttons
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    color: AppColors.white,
    height: 1.3,
  );

  /// Text style for secondary buttons
  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    color: AppColors.foregroundDark,
    height: 1.3,
  );

  // Form and input styles

  /// Style for form labels
  static const TextStyle formLabel = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.24,
    color: AppColors.foregroundDark,
    height: 1.3,
  );

  /// Style for form input text
  static const TextStyle formInput = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 17.0,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.41,
    color: AppColors.foregroundDark,
    height: 1.5,
  );

  /// Style for placeholder/hint text in form inputs
  static const TextStyle formPlaceholder = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 17.0,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.41,
    color: AppColors.mediumGray,
    height: 1.5,
  );

  // Utility text styles

  /// Style for captions and annotations
  static const TextStyle caption = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.0,
    color: AppColors.mediumGray,
    height: 1.3,
  );
}
