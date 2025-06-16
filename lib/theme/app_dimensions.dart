/// AppDimensions defines consistent spacing, sizing, and layout constants
/// used throughout the application.
///
/// These values help maintain visual rhythm and responsive behavior
/// across different screen sizes, particularly optimized for web-first
/// but supporting mobile layouts.
class AppDimensions {
  // Spacing/Padding values

  /// Extra extra small spacing - used for fine-grained adjustments (2px)
  static const double spacingXxs = 2.0;

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

  // Semantic Aliases for Padding (can map to spacing or be distinct)
  // For consistency, we'll map them directly to spacing values for now.
  // If more specific padding values are needed later, they can be defined separately.

  /// Small padding (maps to spacingS)
  static const double paddingSmall = spacingS;

  /// Medium padding (maps to spacingM)
  static const double paddingMedium = spacingM;

  /// Large padding (maps to spacingL)
  static const double paddingLarge = spacingL;

  // Border radius values

  /// Small radius - used for subtle rounding (8px)
  static const double radiusSmall = 8.0;

  /// Medium radius - default for most elements (12px)
  static const double radiusMedium = 12.0;

  /// Large radius - used for prominent elements (16px)
  static const double radiusLarge = 16.0;

  /// Full radius - used for pill shapes (9999px)
  static const double radiusFull = 9999.0;

  // Semantic Aliases for Border Radius

  /// Small border radius (maps to radiusSmall)
  static const double borderRadiusSmall = radiusSmall;

  /// Medium border radius (maps to radiusMedium)
  static const double borderRadiusMedium = radiusMedium;

  /// Large border radius (maps to radiusLarge)
  static const double borderRadiusLarge = radiusLarge;

  // Element sizing

  /// Small button height (36px)
  static const double buttonHeightSmall = 36.0;

  /// Standard button height (40px)
  static const double buttonHeightMedium = 40.0;

  /// Large button height (44px)
  static const double buttonHeightLarge = 44.0;

  /// Button widths - minimum widths for consistent sizing
  /// Small button minimum width (80px)
  static const double buttonWidthSmall = 80.0;

  /// Medium button minimum width (120px)
  static const double buttonWidthMedium = 120.0;

  /// Large button minimum width (160px)
  static const double buttonWidthLarge = 160.0;

  /// Button horizontal padding
  /// Small button padding (12px)
  static const double buttonPaddingSmall = 12.0;

  /// Medium button padding (16px)
  static const double buttonPaddingMedium = 16.0;

  /// Large button padding (32px)
  static const double buttonPaddingLarge = 32.0;

  /// Icon size - extra small (12px) - Added for finer icon control
  static const double iconSizeXs = 12.0;

  /// Icon size - small (16px)
  static const double iconSizeSmall = 16.0;

  /// Icon size - medium (24px)
  static const double iconSizeMedium = 24.0;

  /// Icon size - large (32px)
  static const double iconSizeLarge = 32.0;

  /// Standard width for borders (1.0px)
  static const double borderWidth = 1.0;

  /// Standard avatar radius (20px, for a 40px diameter avatar)
  static const double avatarRadiusStandard = 20.0;

  // Existing avatar radii - these might be for different contexts or can be reviewed later
  /// Small avatar radius (16px)
  static const double avatarRadiusSmall = 16.0;

  /// Medium avatar radius (24px)
  static const double avatarRadiusMedium = 24.0;

  /// Large avatar radius (32px)
  static const double avatarRadiusLarge = 32.0;

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

  /// Larger border width for emphasis (2.0px)
  static const double borderWidthLarge = 2.0;

  /// Content padding for containers (16px)
  static const double contentPadding = 16.0;

  /// Page padding for main content on edges (24px)
  static const double pagePadding = 24.0;
}
