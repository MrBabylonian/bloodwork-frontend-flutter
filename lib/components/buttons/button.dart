import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

/// Button size variants
enum ButtonSize {
  /// Small button (height: 36px)
  small,

  /// Default/medium button (height: 44px)
  medium,

  /// Large button (height: 52px)
  large,

  /// Icon-only button (square dimensions)
  icon,
}

/// Button variants
enum ButtonVariant {
  /// Primary button with filled background
  primary,

  /// Secondary button with light background
  secondary,

  /// Destructive button for dangerous actions
  destructive,

  /// Outline button with border
  outline,

  /// Ghost button with transparent background
  ghost,

  /// Link button with underline styling
  link,
}

/// Main Button component
///
/// This is the primary button component that supports all variants and sizes.
class Button extends StatelessWidget {
  /// Creates a button with the specified properties
  const Button({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.disabled = false,
    this.width,
    this.borderRadius,
  });

  /// Callback that is called when the button is tapped
  final VoidCallback? onPressed;

  /// Widget to display as the button's content
  final Widget child;

  /// Visual variant of the button
  final ButtonVariant variant;

  /// Size variant of the button
  final ButtonSize size;

  /// Whether the button should show a loading indicator
  final bool isLoading;

  /// Whether the button is disabled
  final bool disabled;

  /// Optional explicit width for the button
  final double? width;

  /// Custom border radius
  final BorderRadius? borderRadius;

  /// Get button height based on size
  double get _buttonHeight {
    switch (size) {
      case ButtonSize.small:
        return AppDimensions.buttonHeightSmall;
      case ButtonSize.medium:
        return AppDimensions.buttonHeightMedium;
      case ButtonSize.large:
        return AppDimensions.buttonHeightLarge;
      case ButtonSize.icon:
        return AppDimensions.buttonHeightMedium; // Square for icon
    }
  }

  /// Get button width based on size - uses minimum width constants from AppDimensions
  double? get _buttonWidth {
    if (width != null && width!.isFinite) return width;

    switch (size) {
      case ButtonSize.small:
        return AppDimensions.buttonWidthSmall;
      case ButtonSize.medium:
        return AppDimensions.buttonWidthMedium;
      case ButtonSize.large:
        return AppDimensions.buttonWidthLarge;
      case ButtonSize.icon:
        return _buttonHeight; // Square for icon buttons
    }
  }

  /// Get horizontal padding based on size
  double get _horizontalPadding {
    switch (size) {
      case ButtonSize.small:
        return AppDimensions.buttonPaddingSmall; // 12px (px-3)
      case ButtonSize.medium:
        return AppDimensions.buttonPaddingMedium; // 16px (px-4)
      case ButtonSize.large:
        return AppDimensions.buttonPaddingLarge; // 32px (px-8)
      case ButtonSize.icon:
        return 0; // No padding for icon buttons
    }
  }

  /// Get border radius based on size
  BorderRadius get _borderRadius {
    if (borderRadius != null) return borderRadius!;

    switch (size) {
      case ButtonSize.small:
        return BorderRadius.circular(AppDimensions.radiusSmall);
      case ButtonSize.medium:
      case ButtonSize.icon:
        return BorderRadius.circular(AppDimensions.radiusMedium);
      case ButtonSize.large:
        return BorderRadius.circular(AppDimensions.radiusLarge);
    }
  }

  /// Get background color based on variant and state (for Material style)
  Color get _backgroundColor {
    if (disabled) return AppColors.lightGray.withValues(alpha: 0.5);

    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primaryBlue;
      case ButtonVariant.secondary:
        return AppColors.lightGray;
      case ButtonVariant.destructive:
        return AppColors.destructiveRed;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
      case ButtonVariant.link:
        return Colors.transparent;
    }
  }

  /// Get text color based on variant and state
  Color get _textColor {
    if (disabled) return AppColors.mediumGray;

    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.destructive:
        return AppColors.white;
      case ButtonVariant.secondary:
        return AppColors.foregroundDark;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return AppColors.primaryBlue;
      case ButtonVariant.link:
        return AppColors.primaryBlue;
    }
  }

  /// Get text style based on variant
  TextStyle get _textStyle {
    final baseStyle =
        size == ButtonSize.small ? AppTextStyles.bodySmall : AppTextStyles.body;

    return baseStyle.copyWith(
      color: _textColor,
      fontWeight:
          variant == ButtonVariant.link ? FontWeight.normal : FontWeight.w600,
      decoration:
          variant == ButtonVariant.link ? TextDecoration.underline : null,
    );
  }

  /// Get border side (for outline / ghost variants)
  BorderSide? get _borderSide {
    if (variant == ButtonVariant.outline) {
      return BorderSide(
        color: disabled ? AppColors.lightGray : AppColors.borderGray,
        width: 1,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isEffectivelyDisabled = disabled || onPressed == null;

    final minWidth =
        (_buttonWidth != null && _buttonWidth!.isFinite) ? _buttonWidth! : 0.0;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, minHeight: _buttonHeight),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: _textColor,
          minimumSize: Size(minWidth, _buttonHeight),
          padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: _borderRadius,
            side: _borderSide ?? BorderSide.none,
          ),
          textStyle: _textStyle,
        ),
        onPressed: isEffectivelyDisabled || isLoading ? null : onPressed,
        child:
            isLoading
                ? SizedBox(
                  width: size == ButtonSize.small ? 16 : 20,
                  height: size == ButtonSize.small ? 16 : 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                  ),
                )
                : IconTheme(
                  data: IconThemeData(color: _textColor),
                  child: DefaultTextStyle(
                    style: _textStyle,
                    textAlign: TextAlign.center,
                    child: child,
                  ),
                ),
      ),
    );
  }
}
