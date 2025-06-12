import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// Alert type for different visual styles.
enum AlertType {
  /// Standard informational alert.
  info,

  /// Success message alert.
  success,

  /// Warning alert.
  warning,

  /// Error or destructive alert.
  error,
}

/// Shows a Cupertino-style alert dialog.
///
/// Returns a Future that resolves to the value passed to Navigator.pop
/// when the dialog is closed.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  AlertType alertType = AlertType.info,
  bool barrierDismissible = true,
}) {
  final Color iconColor;
  final IconData iconData;

  switch (alertType) {
    case AlertType.success:
      iconColor = AppColors.successGreen;
      iconData = CupertinoIcons.checkmark_circle_fill;
      break;
    case AlertType.warning:
      iconColor = AppColors.warningOrange;
      iconData = CupertinoIcons.exclamationmark_triangle_fill;
      break;
    case AlertType.error:
      iconColor = AppColors.destructiveRed;
      iconData = CupertinoIcons.xmark_circle_fill;
      break;
    case AlertType.info:
      iconColor = AppColors.primaryBlue;
      iconData = CupertinoIcons.info_circle_fill;
      break;
  }

  return showCupertinoModalPopup<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Column(
          children: [
            Icon(iconData, color: iconColor, size: AppDimensions.iconSizeLarge),
            const SizedBox(height: AppDimensions.spacingM),
            Text(title),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(
            top: AppDimensions.spacingM,
            bottom: AppDimensions.spacingM,
          ),
          child: Text(
            message,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
        actions: <Widget>[
          if (cancelText != null)
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(false);
                if (onCancel != null) {
                  onCancel();
                }
              },
              child: Text(
                cancelText,
                style: TextStyle(
                  color:
                      alertType == AlertType.error
                          ? AppColors.destructiveRed
                          : AppColors.primaryBlue,
                ),
              ),
            ),
          if (confirmText != null)
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(true);
                if (onConfirm != null) {
                  onConfirm();
                }
              },
              isDefaultAction: true,
              child: Text(
                confirmText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      );
    },
  );
}

/// A banner alert that can be shown inline in the UI.
class AlertBanner extends StatelessWidget {
  /// Creates an alert banner with the specified properties.
  const AlertBanner({
    super.key,
    required this.message,
    this.type = AlertType.info,
    this.onDismiss,
    this.action,
    this.actionLabel,
  });

  /// The message to display in the banner.
  final String message;

  /// The type of alert to display.
  final AlertType type;

  /// Called when the dismiss button is tapped.
  final VoidCallback? onDismiss;

  /// Called when the action button is tapped.
  final VoidCallback? action;

  /// The label for the action button.
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    late Color backgroundColor;
    late Color textColor;
    late IconData iconData;

    switch (type) {
      case AlertType.success:
        backgroundColor = Color.fromRGBO(
          AppColors.successGreen.r.toInt(),
          AppColors.successGreen.g.toInt(),
          AppColors.successGreen.b.toInt(),
          0.15,
        );
        textColor = AppColors.successGreen;
        iconData = CupertinoIcons.checkmark_circle_fill;
        break;
      case AlertType.warning:
        backgroundColor = Color.fromRGBO(
          AppColors.warningOrange.r.toInt(),
          AppColors.warningOrange.g.toInt(),
          AppColors.warningOrange.b.toInt(),
          0.15,
        );
        textColor = AppColors.warningOrange;
        iconData = CupertinoIcons.exclamationmark_triangle_fill;
        break;
      case AlertType.error:
        backgroundColor = Color.fromRGBO(
          AppColors.destructiveRed.r.toInt(),
          AppColors.destructiveRed.g.toInt(),
          AppColors.destructiveRed.b.toInt(),
          0.15,
        );
        textColor = AppColors.destructiveRed;
        iconData = CupertinoIcons.xmark_circle_fill;
        break;
      case AlertType.info:
        backgroundColor = Color.fromRGBO(
          AppColors.primaryBlue.r.toInt(),
          AppColors.primaryBlue.g.toInt(),
          AppColors.primaryBlue.b.toInt(),
          0.15,
        );
        textColor = AppColors.primaryBlue;
        iconData = CupertinoIcons.info_circle_fill;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.contentPadding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: textColor, size: AppDimensions.iconSizeMedium),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTextStyles.body.copyWith(color: textColor),
                ),
                if (action != null && actionLabel != null) ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: action,
                    child: Text(
                      actionLabel!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null) ...[
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onDismiss,
              child: Icon(
                CupertinoIcons.xmark,
                color: textColor,
                size: AppDimensions.iconSizeSmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
