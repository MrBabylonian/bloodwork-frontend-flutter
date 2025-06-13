import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// The side from which the sheet should slide in.
enum AppSheetSide { left, right, top, bottom }

/// A sheet widget that slides in from a specified side of the screen.
///
/// This component is equivalent to the sheet.tsx from the React mock,
/// providing modal-like overlays that slide in from screen edges.
class AppSheet extends StatelessWidget {
  /// Creates a sheet widget.
  const AppSheet({
    super.key,
    required this.child,
    this.side = AppSheetSide.right,
    this.width,
    this.height,
    this.backgroundColor,
    this.barrierDismissible = true,
    this.barrierColor,
  });

  /// The content to display in the sheet.
  final Widget child;

  /// The side from which the sheet slides in.
  final AppSheetSide side;

  /// The width of the sheet (for left/right sheets).
  final double? width;

  /// The height of the sheet (for top/bottom sheets).
  final double? height;

  /// The background color of the sheet.
  final Color? backgroundColor;

  /// Whether tapping outside the sheet dismisses it.
  final bool barrierDismissible;

  /// The color of the barrier behind the sheet.
  final Color? barrierColor;

  /// Shows the sheet using the specified context.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    AppSheetSide side = AppSheetSide.right,
    double? width,
    double? height,
    Color? backgroundColor,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor:
          barrierColor ?? CupertinoColors.black.withValues(alpha: 0.3),
      builder:
          (BuildContext context) => AppSheet(
            side: side,
            width: width,
            height: height,
            backgroundColor: backgroundColor,
            barrierDismissible: barrierDismissible,
            barrierColor: barrierColor,
            child: child,
          ),
    );
  }

  double _getWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    switch (side) {
      case AppSheetSide.left:
      case AppSheetSide.right:
        return width ?? (screenWidth * 0.8).clamp(300.0, 400.0);
      case AppSheetSide.top:
      case AppSheetSide.bottom:
        return screenWidth;
    }
  }

  double _getHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    switch (side) {
      case AppSheetSide.top:
      case AppSheetSide.bottom:
        return height ?? (screenHeight * 0.7).clamp(200.0, 600.0);
      case AppSheetSide.left:
      case AppSheetSide.right:
        return screenHeight;
    }
  }

  Alignment _getAlignment() {
    switch (side) {
      case AppSheetSide.left:
        return Alignment.centerLeft;
      case AppSheetSide.right:
        return Alignment.centerRight;
      case AppSheetSide.top:
        return Alignment.topCenter;
      case AppSheetSide.bottom:
        return Alignment.bottomCenter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(),
      child: Container(
        width: _getWidth(context),
        height: _getHeight(context),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.backgroundWhite,
          borderRadius: _getBorderRadius(),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: _getShadowOffset(),
            ),
          ],
        ),
        child: ClipRRect(borderRadius: _getBorderRadius(), child: child),
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    const radius = Radius.circular(AppDimensions.radiusLarge);

    switch (side) {
      case AppSheetSide.left:
        return const BorderRadius.only(topRight: radius, bottomRight: radius);
      case AppSheetSide.right:
        return const BorderRadius.only(topLeft: radius, bottomLeft: radius);
      case AppSheetSide.top:
        return const BorderRadius.only(bottomLeft: radius, bottomRight: radius);
      case AppSheetSide.bottom:
        return const BorderRadius.only(topLeft: radius, topRight: radius);
    }
  }

  Offset _getShadowOffset() {
    switch (side) {
      case AppSheetSide.left:
        return const Offset(2, 0);
      case AppSheetSide.right:
        return const Offset(-2, 0);
      case AppSheetSide.top:
        return const Offset(0, 2);
      case AppSheetSide.bottom:
        return const Offset(0, -2);
    }
  }
}

/// A sheet header with title and optional close button.
class AppSheetHeader extends StatelessWidget {
  /// Creates a sheet header.
  const AppSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showCloseButton = true,
    this.onClose,
    this.actions = const [],
  });

  /// The title to display.
  final String title;

  /// Optional subtitle to display.
  final String? subtitle;

  /// Whether to show the close button.
  final bool showCloseButton;

  /// Callback when the close button is tapped.
  final VoidCallback? onClose;

  /// Additional action widgets to display.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderGray, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foregroundDark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...actions,
          if (showCloseButton) ...[
            const SizedBox(width: AppDimensions.paddingMedium),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              child: const Icon(
                CupertinoIcons.xmark,
                color: AppColors.mediumGray,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
