// ignore_for_file: use_super_parameters

import 'package:flutter/cupertino.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_colors.dart';

/// AppCard is a container that groups related content and actions.
/// It corresponds to the `Card` component in the mock.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;

  const AppCard({
    Key? key,
    required this.child,
    this.margin,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.backgroundWhite, // bg-card (white)
        borderRadius:
            borderRadius ??
            BorderRadius.circular(AppDimensions.radiusLarge), // rounded-lg
        border:
            border ??
            Border.all(
              color: AppColors.borderGray,
              width: AppDimensions.borderWidth,
            ), // border
        boxShadow:
            boxShadow ??
            [
              // shadow-sm
              BoxShadow(
                color: AppColors.shadowColor, // Standard shadow color
                blurRadius:
                    AppDimensions
                        .spacingS, // Adjusted blur to be subtle like shadow-sm
                offset: const Offset(0, AppDimensions.spacingXs / 2),
              ),
            ],
      ),
      child: child,
    );
  }
}

/// AppCardHeader provides a padded section for the top of an AppCard.
/// Corresponds to `CardHeader` from the mock.
class AppCardHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCardHeader({Key? key, required this.child, this.padding})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock: "p-6" -> AppDimensions.spacingL (24.0)
    return Padding(
      padding: padding ?? const EdgeInsets.all(AppDimensions.spacingL),
      child: child,
    );
  }
}

/// AppCardTitle provides a styled text for titles within an AppCardHeader.
/// Corresponds to `CardTitle` from the mock (text-2xl font-semibold).
class AppCardTitle extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextStyle? style;

  const AppCardTitle(this.text, {Key? key, this.textAlign, this.style})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style:
          style ??
          AppTextStyles.title2.copyWith(color: AppColors.foregroundDark),
    );
  }
}

/// AppCardDescription provides styled text for descriptions within an AppCardHeader.
/// Corresponds to `CardDescription` from the mock (text-sm text-muted-foreground).
class AppCardDescription extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextStyle? style;

  const AppCardDescription(this.text, {Key? key, this.textAlign, this.style})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style:
          style ??
          AppTextStyles.bodySmall.copyWith(color: AppColors.mediumGray),
    );
  }
}

/// AppCardContent provides a padded section for the main content of an AppCard.
/// Corresponds to `CardContent` from the mock.
class AppCardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCardContent({Key? key, required this.child, this.padding})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock: "p-6 pt-0" -> padding AppDimensions.spacingL (24px) L, R, B; 0 T
    return Padding(
      padding:
          padding ??
          const EdgeInsets.fromLTRB(
            AppDimensions.spacingL,
            0,
            AppDimensions.spacingL,
            AppDimensions.spacingL,
          ),
      child: child,
    );
  }
}

/// AppCardFooter provides a padded section for the bottom of an AppCard.
/// Corresponds to `CardFooter` from the mock.
class AppCardFooter extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCardFooter({Key? key, required this.child, this.padding})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock: "flex items-center p-6 pt-0"
    // Padding: AppDimensions.spacingL (24px) L, R, B; 0 T
    return Padding(
      padding:
          padding ??
          const EdgeInsets.fromLTRB(
            AppDimensions.spacingL,
            0,
            AppDimensions.spacingL,
            AppDimensions.spacingL,
          ),
      child: child,
    );
  }
}
