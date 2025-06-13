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
