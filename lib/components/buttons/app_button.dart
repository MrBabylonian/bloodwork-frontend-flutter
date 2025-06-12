import 'package:flutter/cupertino.dart';
import '../../theme/app_dimensions.dart';

/// Button size variants
enum AppButtonSize {
  /// Small, compact buttons
  small,

  /// Default, standard-sized buttons
  medium,

  /// Large, prominent buttons
  large,
}

/// Base button class that defines common properties and behaviors for
/// all button types in the application.
///
/// This abstract class ensures consistent styling and behavior across
/// different button variants while allowing for customization.
abstract class AppButton extends StatelessWidget {
  /// Creates a button with the specified properties.
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = AppButtonSize.medium,
    this.width,
    this.isLoading = false,
    this.isDisabled = false,
    this.borderRadius,
  });

  /// Callback that is called when the button is tapped.
  final VoidCallback? onPressed;

  /// Widget to display as the button's content.
  final Widget child;

  /// Size variant of the button.
  final AppButtonSize size;

  /// Optional explicit width for the button.
  /// If null, the button will size to fit its content.
  final double? width;

  /// Whether the button should show a loading indicator.
  final bool isLoading;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// Custom border radius. If not specified, uses default radius.
  final BorderRadius? borderRadius;

  /// Get the appropriate height for the button based on its size.
  double get buttonHeight {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.buttonHeightSmall;
      case AppButtonSize.medium:
        return AppDimensions.buttonHeightMedium;
      case AppButtonSize.large:
        return AppDimensions.buttonHeightLarge;
    }
  }

  /// Get the appropriate horizontal padding for the button based on its size.
  double get horizontalPadding {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.spacingS;
      case AppButtonSize.medium:
        return AppDimensions.spacingM;
      case AppButtonSize.large:
        return AppDimensions.spacingL;
    }
  }

  /// Get the default button border radius.
  BorderRadius get defaultBorderRadius {
    switch (size) {
      case AppButtonSize.small:
        return BorderRadius.circular(AppDimensions.radiusSmall);
      case AppButtonSize.medium:
        return BorderRadius.circular(AppDimensions.radiusMedium);
      case AppButtonSize.large:
        return BorderRadius.circular(AppDimensions.radiusLarge);
    }
  }

  /// Get the effective border radius, using custom or default.
  BorderRadius get effectiveBorderRadius => borderRadius ?? defaultBorderRadius;
}
