import 'package:flutter/cupertino.dart'; // Ensured Cupertino is used
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// A skeleton loading widget to indicate content is loading.
class AppSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  });

  /// Creates a rectangular skeleton.
  const AppSkeleton.rect({
    super.key,
    this.width = double.infinity,
    this.height =
        AppDimensions.spacingM, // Default height, e.g., for a line of text
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  }) : shape = BoxShape.rectangle;

  /// Creates a circular skeleton.
  const AppSkeleton.circle({
    super.key,
    required double radius,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  }) : width = radius * 2,
       height = radius * 2,
       shape = BoxShape.circle,
       borderRadius = null; // borderRadius is ignored for circle

  @override
  Widget build(BuildContext context) {
    final effectiveBaseColor =
        baseColor ?? AppColors.lightGray.withValues(alpha: 0.5);
    final effectiveHighlightColor =
        highlightColor ?? AppColors.mediumGray.withValues(alpha: 0.3);
    final effectiveBorderRadius =
        (shape == BoxShape.rectangle)
            ? (borderRadius ?? BorderRadius.circular(AppDimensions.radiusSmall))
            : null;

    return Shimmer.fromColors(
      baseColor: effectiveBaseColor,
      highlightColor: effectiveHighlightColor,
      period: period,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: CupertinoColors.white, // Changed from Colors.white
          shape: shape,
          borderRadius: effectiveBorderRadius,
        ),
      ),
    );
  }
}
