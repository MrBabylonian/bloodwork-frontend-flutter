import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import 'app_button.dart';

/// Outline button component with a transparent background and a visible border.
///
/// Used for actions that need to be available but not as prominent as primary
/// or secondary buttons.
class OutlineButton extends AppButton {
  /// Creates an outline button with the specified properties.
  const OutlineButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size = AppButtonSize.medium,
    super.width,
    super.isLoading = false,
    super.isDisabled = false,
    super.borderRadius,
    this.outlineColor,
    this.pressedColor,
  });

  /// Optional color for the outline border and text/icon.
  /// Defaults to `AppColors.primaryBlue`.
  final Color? outlineColor;

  /// Optional background color when the button is pressed.
  /// Defaults to a semi-transparent version of `outlineColor`.
  final Color? pressedColor;

  @override
  Widget build(BuildContext context) {
    final Color effectiveOutlineColor = outlineColor ?? AppColors.primaryBlue;

    return Container(
      width: width,
      height: buttonHeight,
      decoration: BoxDecoration(
        color:
            CupertinoColors
                .transparent, // Outline buttons have no fill by default
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: isDisabled ? AppColors.mediumGray : effectiveOutlineColor,
          width: AppDimensions.borderWidth,
        ),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        borderRadius: effectiveBorderRadius,
        color:
            CupertinoColors
                .transparent, // Ensure CupertinoButton itself doesn't add a color
        disabledColor: CupertinoColors.transparent,
        pressedOpacity:
            1.0, // We handle pressed state with background color change if desired
        onPressed: isDisabled || isLoading ? null : onPressed,
        child: Builder(
          builder: (context) {
            // Determine the foreground color based on disabled state
            final Color foreground =
                isDisabled ? AppColors.mediumGray : effectiveOutlineColor;
            Widget buttonChild = child;

            // Apply the foreground color to the text style if the child is Text
            if (child is Text) {
              Text textChild = child as Text;
              buttonChild = Text(
                textChild.data!,
                style: (textChild.style ?? AppTextStyles.buttonSecondary)
                    .copyWith(color: foreground),
                textAlign: textChild.textAlign,
                overflow: textChild.overflow,
                maxLines: textChild.maxLines,
              );
            } else if (child is Icon) {
              Icon iconChild = child as Icon;
              buttonChild = Icon(
                iconChild.icon,
                color: foreground,
                size: iconChild.size,
              );
            }
            // For more complex children, color might need to be handled inside the child widget itself.

            return isLoading
                ? CupertinoActivityIndicator(color: foreground)
                : buttonChild;
          },
        ),
      ),
    );
  }
}
