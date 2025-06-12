import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'app_button.dart';

/// Destructive button component for dangerous or destructive actions.
///
/// Used for actions that delete data, cancel processes, or perform
/// other potentially destructive operations. The red color provides
/// a clear visual indication of caution to the user.
class DestructiveButton extends AppButton {
  /// Creates a destructive button with the specified properties.
  const DestructiveButton({
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
        color: isDisabled ? AppColors.lightGray : AppColors.destructiveRed,
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
