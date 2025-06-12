import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'app_button.dart';

/// Primary button component using the application's primary color.
///
/// Used for main actions and the most important interactions on screens.
/// Follows Apple's Human Interface Guidelines for button styling.
class PrimaryButton extends AppButton {
  /// Creates a primary button with the specified properties.
  const PrimaryButton({
    super.key,
    required super.onPressed,
    required super.child,
    super.size = AppButtonSize.medium,
    super.width,
    super.isLoading = false,
    super.isDisabled = false,
    super.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: isDisabled ? AppColors.lightGray : AppColors.primaryBlue,
        borderRadius: effectiveBorderRadius,
      ),
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        borderRadius: effectiveBorderRadius,
        onPressed: isDisabled || isLoading ? null : onPressed,
        child:
            isLoading
                ? const CupertinoActivityIndicator(color: AppColors.white)
                : DefaultTextStyle(
                  style: AppTextStyles.buttonPrimary,
                  child: child,
                ),
      ),
    );
  }
}
