import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'app_button.dart';

/// Ghost button component, typically used for less prominent actions.
/// It has no border and a transparent background, with text color indicating interactivity.
class GhostButton extends AppButton {
  /// Creates a ghost button.
  const GhostButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size = AppButtonSize.medium,
    super.width,
    super.isLoading = false,
    super.isDisabled = false,
    super.borderRadius,
    this.foregroundColor,
    this.pressedColor,
  });

  /// The color for the text and icon. Defaults to `AppColors.primaryBlue`.
  final Color? foregroundColor;

  /// The background color when the button is pressed. Defaults to a light gray.
  final Color? pressedColor;

  @override
  Widget build(BuildContext context) {
    final Color effectiveForegroundColor =
        foregroundColor ?? AppColors.primaryBlue;

    return CupertinoButton(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical:
            (buttonHeight - (AppTextStyles.buttonSecondary.fontSize ?? 16)) / 2,
      ),
      borderRadius: effectiveBorderRadius,
      color: CupertinoColors.transparent, // Explicitly transparent
      disabledColor:
          CupertinoColors
              .transparent, // Explicitly transparent for disabled state
      minSize: buttonHeight,
      onPressed: isDisabled || isLoading ? null : onPressed,
      child: Builder(
        builder: (context) {
          final Color currentForegroundColor =
              isDisabled ? AppColors.mediumGray : effectiveForegroundColor;
          Widget buttonChild = child;

          // Apply the foreground color to the text style if the child is Text
          if (child is Text) {
            Text textChild = child as Text;
            buttonChild = Text(
              textChild.data!,
              style: (textChild.style ?? AppTextStyles.buttonSecondary)
                  .copyWith(color: currentForegroundColor),
              textAlign: textChild.textAlign,
              overflow: textChild.overflow,
              maxLines: textChild.maxLines,
            );
          } else if (child is Icon) {
            Icon iconChild = child as Icon;
            buttonChild = Icon(
              iconChild.icon,
              color: currentForegroundColor,
              size: iconChild.size, // Use provided icon size
            );
          }

          return isLoading
              ? CupertinoActivityIndicator(color: currentForegroundColor)
              : buttonChild;
        },
      ),
    );
  }
}
