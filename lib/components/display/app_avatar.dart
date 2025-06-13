import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

/// A circular avatar component for displaying user images or fallback initials/icons.
///
/// The `AppAvatar` widget can display an image from a URL. If the image fails to load
/// or no URL is provided, it can display fallback text (e.g., user initials) or a
/// fallback icon.
///
/// It is styled to be consistent with the application\'s theme, using predefined
/// dimensions and colors.
///
/// Example usage:
/// ```dart
/// AppAvatar(
///   imageUrl: \'https://example.com/user.jpg\',
///   fallbackText: \'JD\',
/// )
///
/// AppAvatar(
///   fallbackIcon: CupertinoIcons.person_fill,
/// )
/// ```
class AppAvatar extends StatelessWidget {
  /// Creates an app avatar.
  ///
  /// - [imageUrl]: Optional URL of the image to display.
  /// - [fallbackText]: Optional text to display if the image is unavailable (e.g., initials).
  /// - [fallbackIcon]: Optional icon to display if image and fallbackText are unavailable.
  /// - [radius]: The radius of the avatar. Defaults to `AppDimensions.avatarRadiusStandard`.
  /// - [backgroundColor]: Background color of the avatar. Defaults to `AppColors.lightGray`.
  /// - [foregroundColor]: Color for fallback text or icon. Defaults to `AppColors.primaryBlue`.
  /// - [textStyle]: Custom text style for the fallback text.
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.fallbackText,
    this.fallbackIcon,
    this.radius = AppDimensions.avatarRadiusStandard,
    this.backgroundColor =
        AppColors.lightGray, // Corresponds to "bg-muted" in the mock
    this.foregroundColor =
        AppColors.foregroundDark, // Default for text/icon on lightGray
    this.textStyle,
  });

  /// URL of the image to display. If null or empty, fallbackText or fallbackIcon will be used.
  final String? imageUrl;

  /// Text to display as a fallback if imageUrl is null or empty (e.g., user initials).
  /// Only the first two characters will be shown, uppercased.
  final String? fallbackText;

  /// Icon to display as a fallback if imageUrl and fallbackText are null or empty.
  /// Defaults to `CupertinoIcons.person_fill` if no other fallback is provided.
  final IconData? fallbackIcon;

  /// Radius of the circular avatar.
  final double radius;

  /// Background color if no image is loaded or for the fallback.
  /// This corresponds to the `bg-muted` class in the mock, which is `AppColors.lightGray`.
  final Color backgroundColor;

  /// Foreground color for fallback text or icon.
  final Color foregroundColor;

  /// TextStyle for the fallbackText. If not provided, a default style is used,
  /// scaled according to the avatar\'s radius.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    Widget content;

    // Determine if an image should be attempted
    final bool hasValidImageUrl = imageUrl != null && imageUrl!.isNotEmpty;

    if (hasValidImageUrl) {
      content = Image.network(
        imageUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          // Show a small activity indicator while loading
          return Center(
            child: CupertinoActivityIndicator(
              radius: radius * 0.4,
            ), // Smaller indicator
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // If image fails to load, show fallback
          return _buildFallbackContent();
        },
      );
    } else {
      // If no image URL, directly show fallback
      content = _buildFallbackContent();
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      clipBehavior:
          Clip.antiAlias, // Ensures the child (image or fallback) is clipped to the circle
      child: content,
    );
  }

  /// Builds the fallback content (text or icon) to be displayed inside the avatar.
  Widget _buildFallbackContent() {
    // Prioritize fallbackText
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      String displayText = fallbackText!.trim();
      if (displayText.length > 2) {
        displayText = displayText.substring(0, 2);
      }
      displayText = displayText.toUpperCase();

      return Center(
        child: Text(
          displayText,
          style:
              textStyle ??
              AppTextStyles.footnote.copyWith(
                // Using footnote as a base style
                color: foregroundColor,
                fontSize: radius * 0.7, // Scaled font size
                fontWeight: FontWeight.w500, // Slightly bolder for initials
              ),
          textAlign: TextAlign.center,
        ),
      );
    }
    // Then fallbackIcon
    else if (fallbackIcon != null) {
      return Center(
        child: Icon(
          fallbackIcon,
          color: foregroundColor,
          size: radius, // Icon size scaled to radius
        ),
      );
    }
    // Default fallback if nothing else is provided
    else {
      return Center(
        child: Icon(
          CupertinoIcons.person_fill, // Default icon
          color: foregroundColor,
          size: radius, // Icon size scaled to radius
        ),
      );
    }
  }
}
