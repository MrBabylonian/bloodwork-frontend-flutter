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

  /// Page title style - alias for title1
  static const TextStyle pageTitle = title1;

  /// Card title style - alias for title3
  static const TextStyle title = title3;

  /// Subtitle style for secondary headings
  static const TextStyle subtitle = TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
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

  /// Bold primary body text style
  static const TextStyle bodyBold = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 17.0,
    fontWeight: FontWeight.bold,
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

  /// Footnote text style for ancillary information
  static const TextStyle footnote = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 13.0,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.08,
    color: AppColors.mediumGray, // Changed to AppColors.mediumGray
    height: 1.4,
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
    fontSize: 12.0, // Ensure this is defined
    fontWeight: FontWeight.normal,
    letterSpacing: 0.0,
    color: AppColors.mediumGray, // Ensure this is defined
    height: 1.3,
  );

  /// Style for error messages
  static const TextStyle error = TextStyle(
    fontFamily: 'SF Pro Text',
    fontSize: 13.0,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.08,
    color: AppColors.destructiveRed,
    height: 1.4,
  );
}
