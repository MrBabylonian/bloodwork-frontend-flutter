import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart'; // Added for AppColors
import '../../theme/app_dimensions.dart';

/// A determinate progress bar, styled to match the application's theme.
class AppProgressIndicator extends StatelessWidget {
  /// The current progress value (between 0.0 and 1.0).
  final double value;

  /// The color of the progress bar.
  final Color? color;

  /// The background color of the progress bar.
  final Color? backgroundColor;

  /// The height of the progress bar.
  final double height;

  /// The border radius of the progress bar.
  final BorderRadius? borderRadius;

  const AppProgressIndicator({
    super.key,
    required this.value,
    this.color, // Default will be AppColors.primaryBlue
    this.backgroundColor, // Default will be AppColors.backgroundSecondary
    this.height = AppDimensions.spacingM, // Mock: h-4 (16px)
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppDimensions.radiusFull);
    // Use AppColors by default, fallback to CupertinoTheme if not provided and AppColors are also null (though unlikely here)
    final progressColor = color ?? AppColors.primaryBlue;
    final bgColor = backgroundColor ?? AppColors.backgroundSecondary;

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: Container(
        height: height,
        color: bgColor,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(color: progressColor),
        ),
      ),
    );
  }
}
