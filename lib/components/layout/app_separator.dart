import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';

/// A separator widget that creates visual divisions between content.
///
/// This component is equivalent to the separator.tsx from the React mock,
/// providing consistent visual separation throughout the application.
class AppSeparator extends StatelessWidget {
  /// Creates a separator widget.
  const AppSeparator({
    super.key,
    this.orientation = Axis.horizontal,
    this.thickness = 1.0,
    this.color,
    this.margin,
    this.decorative = true,
  });

  /// The orientation of the separator (horizontal or vertical).
  final Axis orientation;

  /// The thickness of the separator line.
  final double thickness;

  /// The color of the separator. Defaults to border gray.
  final Color? color;

  /// Optional margin around the separator.
  final EdgeInsetsGeometry? margin;

  /// Whether this separator is purely decorative.
  /// When true, it's ignored by screen readers.
  final bool decorative;

  @override
  Widget build(BuildContext context) {
    final Widget separator = Container(
      width: orientation == Axis.horizontal ? double.infinity : thickness,
      height: orientation == Axis.vertical ? double.infinity : thickness,
      color: color ?? AppColors.borderGray,
    );

    final Widget separatorWithMargin =
        margin != null
            ? Padding(padding: margin!, child: separator)
            : separator;

    if (decorative) {
      return ExcludeSemantics(child: separatorWithMargin);
    }

    return Semantics(label: 'Separator', child: separatorWithMargin);
  }
}

/// A horizontal separator with common styling.
class AppHorizontalSeparator extends StatelessWidget {
  /// Creates a horizontal separator.
  const AppHorizontalSeparator({
    super.key,
    this.thickness = 1.0,
    this.color,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
  });

  /// The thickness of the separator line.
  final double thickness;

  /// The color of the separator.
  final Color? color;

  /// Margin around the separator.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return AppSeparator(
      orientation: Axis.horizontal,
      thickness: thickness,
      color: color,
      margin: margin,
    );
  }
}

/// A vertical separator with common styling.
class AppVerticalSeparator extends StatelessWidget {
  /// Creates a vertical separator.
  const AppVerticalSeparator({
    super.key,
    this.thickness = 1.0,
    this.color,
    this.margin = const EdgeInsets.symmetric(horizontal: 8.0),
  });

  /// The thickness of the separator line.
  final double thickness;

  /// The color of the separator.
  final Color? color;

  /// Margin around the separator.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return AppSeparator(
      orientation: Axis.vertical,
      thickness: thickness,
      color: color,
      margin: margin,
    );
  }
}
