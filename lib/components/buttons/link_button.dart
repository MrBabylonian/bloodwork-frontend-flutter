import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import 'app_button.dart';

/// Link button component, styled to look like a hyperlink.
class LinkButton extends AppButton {
  /// Creates a link button.
  const LinkButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size = AppButtonSize.medium, // Size might affect padding/tap target
    super.width,
    super.isLoading = false, // Link buttons usually don't have a loading state
    super.isDisabled = false,
    this.foregroundColor,
  });

  /// The color for the text. Defaults to `AppColors.primaryBlue`.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final Color effectiveForegroundColor =
        foregroundColor ?? AppColors.primaryBlue;

    // Link buttons typically don't have a prominent background or border
    // Their height is determined by the text itself mostly.
    // We use CupertinoButton for its onPressed handling and disabled state.
    return CupertinoButton(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding / 2,
        vertical: AppDimensions.spacingXs, // Corrected: Use AppDimensions
      ), // Minimal padding
      onPressed: isDisabled || isLoading ? null : onPressed,
      minSize: 0, // Allow the button to be as small as its child
      child: Builder(
        builder: (context) {
          final Color currentForegroundColor =
              isDisabled ? AppColors.mediumGray : effectiveForegroundColor;
          Widget buttonChild = child;

          if (child is Text) {
            Text textChild = child as Text;
            // Assuming AppTextStyles.link is not defined, using a base style and adding underline.
            // If AppTextStyles.link exists, it should be used directly.
            TextStyle linkStyle =
                (textChild.style ?? AppTextStyles.buttonSecondary).copyWith(
                  color: currentForegroundColor,
                  decoration: TextDecoration.underline,
                  decorationColor: currentForegroundColor,
                  decorationThickness: 2.0, // Make underline more visible
                );
            buttonChild = Text(
              textChild.data!,
              style: linkStyle,
              textAlign: textChild.textAlign,
              overflow: textChild.overflow,
              maxLines: textChild.maxLines,
            );
          } else if (child is Icon) {
            // Icons in link buttons are less common but possible
            Icon iconChild = child as Icon;
            // Use a default size if iconChild.size is null, e.g., from a text style if appropriate
            final iconSize =
                iconChild.size ??
                (AppTextStyles.buttonSecondary.fontSize ?? 16.0);
            buttonChild = Icon(
              iconChild.icon,
              color: currentForegroundColor,
              size: iconSize,
            );
          }

          // Link buttons typically don't show a loading indicator in the same way
          // If isLoading is true, we might just disable it or show a very subtle indicator elsewhere.
          return isLoading
              ? CupertinoActivityIndicator(
                // Adjust radius based on a text style if AppTextStyles.link is not available
                radius: (AppTextStyles.buttonSecondary.fontSize ?? 16.0) / 2.5,
                color: currentForegroundColor,
              )
              : buttonChild;
        },
      ),
    );
  }
}
