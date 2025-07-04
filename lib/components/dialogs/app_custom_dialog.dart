import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material_icons;
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../buttons/button_variants.dart';

/// A custom dialog component with a consistent design across the app.
///
/// This dialog is designed to be used for success and error messages,
/// with a colored icon at the top, a title, a message, and an action button.
class AppCustomDialog extends StatelessWidget {
  /// Creates a custom dialog.
  const AppCustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.isError,
    this.onPressed,
    this.buttonText = 'OK',
    this.width = 400,
  });

  /// The title of the dialog.
  final String title;

  /// The message to display.
  final String message;

  /// Whether this is an error dialog (red) or success dialog (green).
  final bool isError;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Text for the button.
  final String buttonText;

  /// Width of the dialog.
  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        margin: const EdgeInsets.all(AppDimensions.spacingL),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.foregroundDark.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color:
                          isError
                              ? AppColors.destructiveRed.withValues(alpha: 0.1)
                              : AppColors.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Icon(
                      isError
                          ? material_icons.Icons.error_rounded
                          : material_icons.Icons.check_circle,
                      color:
                          isError
                              ? AppColors.destructiveRed
                              : AppColors.successGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    title,
                    style: AppTextStyles.title2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    message,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 1,
              color: AppColors.borderGray.withValues(alpha: 0.3),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: onPressed ?? () => Navigator.of(context).pop(),
                  child: Text(buttonText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a custom dialog with the app's design.
///
/// This is a helper function to easily show the custom dialog.
Future<T?> showAppCustomDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  bool isError = false,
  VoidCallback? onPressed,
  String buttonText = 'OK',
  double width = 400,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder:
        (BuildContext context) => AppCustomDialog(
          title: title,
          message: message,
          isError: isError,
          onPressed: onPressed,
          buttonText: buttonText,
          width: width,
        ),
  );
}

/// Shows a success dialog with the app's design.
Future<T?> showSuccessDialog<T>({
  required BuildContext context,
  required String message,
  String title = 'Successo',
  VoidCallback? onPressed,
  String buttonText = 'OK',
  double width = 400,
  bool barrierDismissible = true,
}) {
  return showAppCustomDialog<T>(
    context: context,
    title: title,
    message: message,
    isError: false,
    onPressed: onPressed,
    buttonText: buttonText,
    width: width,
    barrierDismissible: barrierDismissible,
  );
}

/// Shows an error dialog with the app's design.
Future<T?> showErrorDialog<T>({
  required BuildContext context,
  required String message,
  String title = 'Errore',
  VoidCallback? onPressed,
  String buttonText = 'OK',
  double width = 400,
  bool barrierDismissible = true,
}) {
  return showAppCustomDialog<T>(
    context: context,
    title: title,
    message: message,
    isError: true,
    onPressed: onPressed,
    buttonText: buttonText,
    width: width,
    barrierDismissible: barrierDismissible,
  );
}

/// Shows a confirmation dialog with the app's design.
///
/// This dialog has two buttons: a cancel button and a confirm button.
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelText = 'Annulla',
  String confirmText = 'Conferma',
  bool isDestructive = false,
  double width = 400,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder:
        (BuildContext context) => Center(
          child: Container(
            width: width,
            margin: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.foregroundDark.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingL),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.title2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Text(
                        message,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 1,
                  color: AppColors.borderGray.withValues(alpha: 0.3),
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingL),
                  child: Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(cancelText),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child:
                            isDestructive
                                ? DestructiveButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: Text(confirmText),
                                )
                                : PrimaryButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: Text(confirmText),
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}
