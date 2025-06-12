/// AppDimensions defines consistent spacing, sizing, and layout constants
/// used throughout the application.
///
/// These values help maintain visual rhythm and responsive behavior
/// across different screen sizes, particularly optimized for web-first
/// but supporting mobile layouts.
class AppDimensions {
  // Spacing/Padding values

  /// Tiny spacing - used for minimal separation (4px)
  static const double spacingXs = 4.0;

  /// Small spacing - used for tight elements (8px)
  static const double spacingS = 8.0;

  /// Medium spacing - default spacing for most elements (16px)
  static const double spacingM = 16.0;

  /// Large spacing - used for section separation (24px)
  static const double spacingL = 24.0;

  /// Extra large spacing - used for major section separation (32px)
  static const double spacingXl = 32.0;

  /// Double extra large spacing - used for very significant breaks (48px)
  static const double spacingXxl = 48.0;

  // Border radius values

  /// Small radius - used for subtle rounding (4px)
  static const double radiusSmall = 4.0;

  /// Medium radius - default for most elements (8px)
  static const double radiusMedium = 8.0;

  /// Large radius - used for prominent elements (12px)
  static const double radiusLarge = 12.0;

  /// Full radius - used for pill shapes (9999px)
  static const double radiusFull = 9999.0;

  // Element sizing

  /// Small button/input height (32px)
  static const double buttonHeightSmall = 32.0;

  /// Standard button/input height (44px)
  static const double buttonHeightMedium = 44.0;

  /// Large button/input height (56px)
  static const double buttonHeightLarge = 56.0;

  /// Icon size - small (16px)
  static const double iconSizeSmall = 16.0;

  /// Icon size - medium (24px)
  static const double iconSizeMedium = 24.0;

  /// Icon size - large (32px)
  static const double iconSizeLarge = 32.0;

  // Responsive breakpoints for web

  /// Small mobile breakpoint (320px)
  static const double breakpointXs = 320.0;

  /// Regular mobile breakpoint (480px)
  static const double breakpointS = 480.0;

  /// Tablet breakpoint (768px)
  static const double breakpointM = 768.0;

  /// Desktop breakpoint (1024px)
  static const double breakpointL = 1024.0;

  /// Large desktop breakpoint (1280px)
  static const double breakpointXl = 1280.0;

  /// Wide desktop breakpoint (1440px)
  static const double breakpointXxl = 1440.0;

  // Layout constants

  /// Maximum content width on large screens (1200px)
  static const double maxContentWidth = 1200.0;

  /// Standard card elevation (2.0)
  static const double cardElevation = 2.0;

  /// Border width for outlines, dividers (1.0px)
  static const double borderWidth = 1.0;

  /// Larger border width for emphasis (2.0px)
  static const double borderWidthLarge = 2.0;

  /// Content padding for containers (16px)
  static const double contentPadding = 16.0;

  /// Page padding for main content on edges (24px)
  static const double pagePadding = 24.0;
}
