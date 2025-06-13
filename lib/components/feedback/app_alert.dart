import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

enum AppAlertType { info, success, warning, error }

class AppAlert extends StatelessWidget {
  final String? title;
  final String message;
  final AppAlertType type;
  final VoidCallback? onDismiss;
  final Widget? action;

  const AppAlert({
    super.key,
    this.title,
    required this.message,
    this.type = AppAlertType.info,
    this.onDismiss,
    this.action,
  });

  Color _getBackgroundColor(BuildContext context) {
    final bool isDarkMode =
        CupertinoTheme.of(context).brightness == Brightness.dark;
    switch (type) {
      case AppAlertType.success:
        return isDarkMode
            ? AppColors.successGreen.withValues(alpha: 0.3)
            : AppColors.successGreen.withValues(alpha: 0.15);
      case AppAlertType.warning:
        return isDarkMode
            ? AppColors.warningOrange.withValues(alpha: 0.3)
            : AppColors.warningOrange.withValues(alpha: 0.15);
      case AppAlertType.error:
        return isDarkMode
            ? AppColors.destructiveRed.withValues(alpha: 0.3)
            : AppColors.destructiveRed.withValues(alpha: 0.15);
      case AppAlertType.info:
        return CupertinoColors
            .secondarySystemFill; // Standard fill color for info
    }
  }

  Color _getForegroundColor(BuildContext context) {
    final bool isDarkMode =
        CupertinoTheme.of(context).brightness == Brightness.dark;
    switch (type) {
      case AppAlertType.success:
        return isDarkMode ? AppColors.successGreen : AppColors.successGreen;
      case AppAlertType.warning:
        return isDarkMode ? AppColors.warningOrange : AppColors.warningOrange;
      case AppAlertType.error:
        return isDarkMode ? AppColors.destructiveRed : AppColors.destructiveRed;
      case AppAlertType.info:
        return AppColors.foregroundDark;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case AppAlertType.success:
        return CupertinoIcons.checkmark_circle_fill;
      case AppAlertType.warning:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case AppAlertType.error:
        return CupertinoIcons.xmark_circle_fill;
      case AppAlertType.info:
        return CupertinoIcons.info_circle_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _getBackgroundColor(context);
    final Color foregroundColor = _getForegroundColor(context);
    final IconData iconData = _getIcon();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color:
              type == AppAlertType.info
                  ? CupertinoColors
                      .systemGrey3 // Subtle border for info
                  : foregroundColor.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: AppDimensions.spacingS,
              top: AppDimensions.spacingXs / 2,
            ), // Changed spacingXxs
            child: Icon(
              iconData,
              color: foregroundColor,
              size: AppDimensions.iconSizeMedium,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null && title!.isNotEmpty)
                  Text(
                    title!,
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.foregroundDark,
                    ),
                  ),
                if (title != null && title!.isNotEmpty && message.isNotEmpty)
                  const SizedBox(
                    height: AppDimensions.spacingXs / 2,
                  ), // Changed spacingXxs
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.foregroundDark.withValues(alpha: 0.8),
                  ),
                ),
                if (action != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.spacingS),
                    child: action,
                  ),
              ],
            ),
          ),
          if (onDismiss != null)
            CupertinoButton(
              padding: const EdgeInsets.all(
                AppDimensions.spacingXs / 2,
              ), // Smaller padding for dismiss
              minSize: 0,
              onPressed: onDismiss,
              child: Icon(
                CupertinoIcons.xmark,
                color: AppColors.mediumGray,
                size: AppDimensions.iconSizeSmall,
              ),
            ),
        ],
      ),
    );
  }
}

// Example Usage:
/*
Column(
  children: [
    AppAlert(
      title: 'Update Available',
      message: 'A new version of the application is available. Please update for the latest features and bug fixes.',
      type: AppAlertType.info,
      onDismiss: () { print('Info dismissed'); },
      action: CupertinoButton.filled(
        child: Text('Update Now'),
        onPressed: () { print('Update Now pressed'); },
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingM, vertical: AppDimensions.spacingXs),
      ),
    ),
    SizedBox(height: AppDimensions.spacingM),
    AppAlert(
      title: 'Success!',
      message: 'Your profile has been updated successfully.',
      type: AppAlertType.success,
      onDismiss: () { print('Success dismissed'); },
    ),
    SizedBox(height: AppDimensions.spacingM),
    AppAlert(
      title: 'Warning: Low Storage',
      message: 'Your device is running low on storage. Consider freeing up some space.',
      type: AppAlertType.warning,
      onDismiss: () { print('Warning dismissed'); },
    ),
    SizedBox(height: AppDimensions.spacingM),
    AppAlert(
      message: 'Failed to connect to the server. Please check your internet connection and try again.',
      type: AppAlertType.error,
      onDismiss: () { print('Error dismissed'); },
       action: CupertinoButton(
        child: Text('Retry'),
        onPressed: () { print('Retry pressed'); },
      ),
    ),
     SizedBox(height: AppDimensions.spacingM),
    AppAlert(
      message: 'This is a simple informational message without a title or dismiss button.',
      type: AppAlertType.info,
    ),
  ],
)
*/
