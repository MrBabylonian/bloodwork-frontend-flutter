import 'package:flutter/cupertino.dart';
import '../../theme/app_dimensions.dart';

/// A container that adapts its layout based on screen size.
///
/// This component helps create responsive layouts that work well across
/// different devices and screen sizes, from mobile to desktop.
class ResponsiveContainer extends StatelessWidget {
  /// Creates a responsive container with the specified properties.
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth = double.infinity,
    this.tabletWidth = 700,
    this.desktopWidth = 1100,
    this.maxWidth,
    this.alignment = Alignment.center,
    this.padding,
  });

  /// The child widget to display
  final Widget child;

  /// Width to use on mobile devices
  final double mobileWidth;

  /// Maximum width to use on tablet devices
  final double tabletWidth;

  /// Maximum width to use on desktop devices
  final double desktopWidth;

  /// Overall maximum width constraint
  final double? maxWidth;

  /// How to align the child within the container
  final Alignment alignment;

  /// Optional padding around the container
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine current device type based on width
        final screenWidth = constraints.maxWidth;

        // Calculate appropriate width based on screen size
        double containerWidth;
        EdgeInsetsGeometry effectivePadding;

        if (screenWidth >= AppDimensions.breakpointL) {
          // Desktop layout
          containerWidth = maxWidth ?? desktopWidth;
          effectivePadding =
              padding ??
              const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXl);
        } else if (screenWidth >= AppDimensions.breakpointM) {
          // Tablet layout
          containerWidth = maxWidth ?? tabletWidth;
          effectivePadding =
              padding ??
              const EdgeInsets.symmetric(horizontal: AppDimensions.spacingL);
        } else {
          // Mobile layout
          containerWidth = maxWidth ?? mobileWidth;
          effectivePadding =
              padding ??
              const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM);
        }

        return Align(
          alignment: alignment,
          child: Container(
            padding: effectivePadding,
            constraints: BoxConstraints(maxWidth: containerWidth),
            child: child,
          ),
        );
      },
    );
  }
}
