// ignore_for_file: use_super_parameters

import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

/// A custom navigation bar component that provides consistent styling
/// and behavior across the application.
///
/// This component wraps the CupertinoNavigationBar with our application's
/// styling and provides additional functionality like responsiveness.
class CupertinoAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a navigation bar with the specified properties.
  const CupertinoAppBar({
    Key? key,
    this.title,
    this.largeTitle = false,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.trailing,
    this.backgroundColor = AppColors.backgroundWhite,
    this.border,
    this.brightness,
    this.padding,
    this.previousPageTitle,
  }) : super(key: key);

  /// The title to display in the navigation bar.
  final Widget? title;

  /// Whether to use a large title style.
  final bool largeTitle;

  /// Leading widget to display at the start of the navigation bar.
  final Widget? leading;

  /// Whether to automatically add a back button when there are pages on the stack.
  final bool automaticallyImplyLeading;

  /// Trailing widget(s) to display at the end of the navigation bar.
  final Widget? trailing;

  /// Background color of the navigation bar.
  final Color backgroundColor;

  /// Custom border for the navigation bar.
  final Border? border;

  /// The brightness of the navigation bar, used to determine status bar styling.
  final Brightness? brightness;

  /// Custom padding for the navigation bar content.
  final EdgeInsetsDirectional? padding;

  /// Title of the previous page, used for the back button label.
  final String? previousPageTitle;

  @override
  Size get preferredSize => const Size.fromHeight(44.0);

  @override
  Widget build(BuildContext context) {
    Widget? titleWidget;

    if (title != null) {
      titleWidget = DefaultTextStyle(
        style: largeTitle ? AppTextStyles.title1 : AppTextStyles.title3,
        child: title!,
      );
    }

    // Create a standard Cupertino navigation bar
    return CupertinoNavigationBar(
      middle: titleWidget,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      trailing: trailing,
      backgroundColor: backgroundColor,
      border:
          border ??
          Border(
            bottom: BorderSide(
              color: AppColors.borderGray,
              width: AppDimensions.borderWidth,
            ),
          ),
      padding: padding,
      previousPageTitle: previousPageTitle,
      brightness: brightness,
    );
  }
}

/// A button component specifically designed for navigation bar actions.
class NavigationBarButton extends StatelessWidget {
  /// Creates a navigation bar button with an icon.
  const NavigationBarButton.icon({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.primaryBlue,
    this.size = AppDimensions.iconSizeMedium,
  }) : label = null,
       super(key: key);

  /// Creates a navigation bar button with text.
  const NavigationBarButton.text({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primaryBlue,
    this.size = AppDimensions.iconSizeMedium,
  }) : icon = null,
       super(key: key);

  /// Creates a navigation bar back button.
  factory NavigationBarButton.back({
    Key? key,
    required VoidCallback onPressed,
    String? label,
    Color color = AppColors.primaryBlue,
  }) {
    return NavigationBarButton.icon(
      key: key,
      icon: CupertinoIcons.back,
      onPressed: onPressed,
      color: color,
    );
  }

  /// The icon to display in the button.
  final IconData? icon;

  /// The text to display in the button.
  final String? label;

  /// Callback that is called when the button is tapped.
  final VoidCallback onPressed;

  /// Color of the button.
  final Color color;

  /// Size of the icon if an icon is used.
  final double size;

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Icon(icon, color: color, size: size),
      );
    } else if (label != null) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Text(
          label!,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    // This shouldn't happen but provide a fallback
    return const SizedBox.shrink();
  }
}
