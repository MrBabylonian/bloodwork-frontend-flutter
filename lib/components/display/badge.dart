import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

/// Enum for different badge visual styles, mirroring shadcn/ui variants.
enum AppBadgeVariant {
  primary, // default in shadcn
  secondary,
  destructive,
  outline,
  // Custom variants from existing AppBadge
  success,
  warning,
  info,
}

/// A badge component for displaying short pieces of information or status.
///
/// Badges can be styled with different variants to convey meaning through color.
/// This component aims to replicate the visual style and variants of the
/// shadcn/ui Badge component.
///
/// Example usage:
/// ```dart
/// AppBadge(label: "Active", variant: AppBadgeVariant.primary)
/// AppBadge(label: "Offline", variant: AppBadgeVariant.outline)
/// AppBadge(label: "Error", variant: AppBadgeVariant.destructive, icon: CupertinoIcons.xmark_circle_fill)
/// ```
class AppBadge extends StatelessWidget {
  /// Creates a badge with the specified properties.
  ///
  /// - [label]: The text to display within the badge.
  /// - [variant]: The visual style of the badge. Defaults to `AppBadgeVariant.primary`.
  /// - [icon]: Optional icon to display before the label.
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.primary,
    this.icon,
  });

  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final _BadgeStyle style = _getVariantStyle(variant);

    // text-xs (12px) font-semibold from shadcn
    // AppTextStyles.caption is 12px normal. We'll override fontWeight.
    final TextStyle textStyle = AppTextStyles.caption.copyWith(
      color: style.textColor,
      fontWeight: FontWeight.w600, // font-semibold
    );

    // px-2.5 (10px), py-0.5 (2px) from shadcn
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: AppDimensions.spacingS + AppDimensions.spacingXxs, // 10px
      vertical: AppDimensions.spacingXxs, // 2px
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        // rounded-full from shadcn
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: style.borderColor,
          // border (1px) from shadcn, only visible for outline or if borderColor is different from backgroundColor
          width:
              (variant == AppBadgeVariant.outline ||
                      style.borderColor != style.backgroundColor)
                  ? AppDimensions
                      .borderWidth // Use the defined borderWidth
                  : 0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: AppDimensions.spacingXs),
              child: Icon(
                icon,
                color: style.textColor,
                size: textStyle.fontSize, // Match icon size to text size
              ),
            ),
          Text(label, style: textStyle),
        ],
      ),
    );
  }

  _BadgeStyle _getVariantStyle(AppBadgeVariant variant) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (variant) {
      case AppBadgeVariant.primary:
        // "border-transparent bg-primary text-primary-foreground hover:bg-primary/80"
        backgroundColor = AppColors.primaryBlue;
        textColor = AppColors.accentForeground; // primary-foreground
        borderColor =
            AppColors
                .primaryBlue; // border-transparent implies border color matches bg
        break;
      case AppBadgeVariant.secondary:
        // "border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80"
        backgroundColor = AppColors.backgroundSecondary; // secondary
        textColor = AppColors.textSecondary; // secondary-foreground
        borderColor = AppColors.backgroundSecondary;
        break;
      case AppBadgeVariant.destructive:
        // "border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80"
        backgroundColor = AppColors.destructiveRed; // destructive
        textColor = AppColors.accentForeground; // destructive-foreground
        borderColor = AppColors.destructiveRed;
        break;
      // Custom variants from original AppBadge
      case AppBadgeVariant.success:
        backgroundColor = AppColors.successGreen.withValues(alpha: 0.15);
        textColor = AppColors.successGreen;
        borderColor = AppColors.successGreen.withValues(alpha: 0.15);
        break;
      case AppBadgeVariant.warning:
        backgroundColor = AppColors.warningOrange.withValues(alpha: 0.15);
        textColor = AppColors.warningOrange;
        borderColor = AppColors.warningOrange.withValues(alpha: 0.15);
        break;
      case AppBadgeVariant.info:
        backgroundColor = AppColors.primaryBlue.withValues(alpha: 0.15);
        textColor = AppColors.primaryBlue;
        borderColor = AppColors.primaryBlue.withValues(alpha: 0.15);
        break;
      default:
        backgroundColor = AppColors.foregroundDark;
        textColor = AppColors.backgroundWhite;
        borderColor = AppColors.transparent;
    }

    // Apply outline variant styles
    if (variant == AppBadgeVariant.outline) {
      textColor =
          backgroundColor; // Outline text color is the variant's base color
      backgroundColor = AppColors.transparent;
      // borderColor is already set by the switch, or defaults to transparent if not a specific outline case
    }

    return _BadgeStyle(
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
    );
  }
}

/// Helper class to hold style properties for a badge variant.
class _BadgeStyle {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  _BadgeStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}
