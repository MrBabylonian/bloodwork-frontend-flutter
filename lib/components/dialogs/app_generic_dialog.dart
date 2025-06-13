import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// A generic dialog component that can be customized with any content.
///
/// This is useful for creating modals with complex layouts or forms,
/// going beyond the standard `showAppDialog` for simple alerts.
class AppGenericDialog extends StatelessWidget {
  /// Creates a generic dialog.
  const AppGenericDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.contentPadding = const EdgeInsets.all(
      AppDimensions.spacingL,
    ), // p-6 (24px)
    this.titlePadding = const EdgeInsets.fromLTRB(
      AppDimensions.spacingL, // p-6 left
      AppDimensions.spacingL, // p-6 top
      AppDimensions.spacingL, // p-6 right
      AppDimensions.spacingM, // space-y-1.5 (16px) after title
    ),
    this.actionsPadding = const EdgeInsets.all(
      AppDimensions.spacingM,
    ), // Default padding for actions area
    this.borderRadius = AppDimensions.radiusLarge, // sm:rounded-lg
    this.backgroundColor = AppColors.backgroundWhite, // bg-background
    this.barrierDismissible = true,
    this.showCloseButton = false, // New property for close button
    this.dialogWidth,
  });

  /// Optional title for the dialog.
  final Widget? title;

  /// The main content of the dialog.
  final Widget content;

  /// A list of actions (typically buttons) to display at the bottom.
  final List<Widget>? actions;

  /// Padding around the content area.
  final EdgeInsetsGeometry contentPadding;

  /// Padding for the title section.
  final EdgeInsetsGeometry titlePadding;

  /// Padding for the actions section.
  final EdgeInsetsGeometry actionsPadding;

  /// Border radius of the dialog.
  final double borderRadius;

  /// Background color of the dialog.
  final Color backgroundColor;

  /// Whether the dialog can be dismissed by tapping outside of it.
  final bool barrierDismissible;

  /// Whether to show an 'X' close button in the top-right corner.
  final bool showCloseButton;

  /// Optional width for the dialog.
  final double? dialogWidth;

  @override
  Widget build(BuildContext context) {
    Widget dialogContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: titlePadding,
            child: DefaultTextStyle(
              style: AppTextStyles.title2.copyWith(
                color: AppColors.foregroundDark,
                // fontWeight: FontWeight.w600, // text-lg font-semibold (title2 is already bold)
              ),
              textAlign:
                  TextAlign
                      .center, // Mock: text-center sm:text-left. Defaulting to center for title.
              child: title!,
            ),
          ),
        Flexible(
          child: SingleChildScrollView(padding: contentPadding, child: content),
        ),
        if (actions != null && actions!.isNotEmpty)
          Padding(
            padding: actionsPadding,
            // Mock: flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2
            // Defaulting to Row with MainAxisAlignment.end. Reverse column not implemented here.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children:
                  actions!
                      .map(
                        (e) => Padding(
                          // Add spacing for sm:space-x-2
                          padding: const EdgeInsets.only(
                            left: AppDimensions.spacingXs,
                          ),
                          child: e,
                        ),
                      )
                      .toList(),
            ),
          ),
      ],
    );

    if (showCloseButton) {
      dialogContent = Stack(
        children: [
          dialogContent,
          Positioned(
            right: AppDimensions.spacingS, // Equivalent to right-4 (16px)
            top: AppDimensions.spacingS, // Equivalent to top-4 (16px)
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(
                CupertinoIcons.xmark,
                size:
                    AppDimensions
                        .iconSizeMedium, // h-4 w-4 (16px), iconSizeSmall is 16px, Medium is 24px. Using Medium for better tap.
                color: AppColors.mediumGray, // text-muted-foreground or similar
              ),
            ),
          ),
        ],
      );
    }

    return CupertinoPopupSurface(
      isSurfacePainted: true,
      child: Container(
        width: dialogWidth, // Apply dialog width
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          // Mock: border. Adding a subtle border.
          border: Border.all(color: AppColors.borderGray, width: 0.5),
          // Mock: shadow-lg. CupertinoPopupSurface provides some elevation.
          // Additional boxShadow could be added here if needed.
        ),
        child: dialogContent,
      ),
    );
  }
}

/// Shows a generic dialog with custom content.
Future<T?> showAppGenericDialog<T>({
  required BuildContext context,
  Widget? title,
  required Widget content,
  List<Widget>? actions,
  bool barrierDismissible = true,
  bool showCloseButton = false, // Pass this through
  double? dialogWidth, // Pass this through
}) {
  return showCupertinoModalPopup<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingXl,
          vertical: AppDimensions.spacingXxl,
        ),
        child: AppGenericDialog(
          title: title,
          content: content,
          actions: actions,
          barrierDismissible: barrierDismissible,
          showCloseButton: showCloseButton, // Pass to AppGenericDialog
          dialogWidth: dialogWidth,
        ),
      );
    },
  );
}
