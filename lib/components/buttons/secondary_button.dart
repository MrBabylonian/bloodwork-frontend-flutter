import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'app_button.dart';

/// Secondary button component with a lighter visual weight.
///
/// Used for secondary actions that don't require the visual prominence
/// of a primary button. Provides clear affordance while maintaining
/// hierarchy with primary actions.
class SecondaryButton extends AppButton {
  /// Creates a secondary button with the specified properties.
  const SecondaryButton({
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
        color:
            isDisabled
                ? AppColors.lightGray.withValues(alpha: 0.5)
                : AppColors.lightGray,
        borderRadius: effectiveBorderRadius,
      ),
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        borderRadius: effectiveBorderRadius,
        onPressed: isDisabled || isLoading ? null : onPressed,
        child:
            isLoading
                ? const CupertinoActivityIndicator(
                  color: AppColors.foregroundDark,
                )
                : DefaultTextStyle(
                  style: AppTextStyles.buttonSecondary,
                  child: child,
                ),
      ),
    );
  }
}
