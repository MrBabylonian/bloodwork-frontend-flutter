import 'package:flutter/cupertino.dart';

/// A customizable scroll area with consistent styling.
///
/// This component is equivalent to the scroll-area.tsx from the React mock,
/// providing a consistent scrollable area with optional custom scrollbars.
class AppScrollArea extends StatelessWidget {
  /// Creates a scroll area.
  const AppScrollArea({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.showScrollbar = true,
    this.scrollbarThickness = 6.0,
    this.scrollbarRadius = 3.0,
    this.scrollbarColor,
    this.padding,
    this.physics,
    this.clipBehavior = Clip.hardEdge,
  });

  /// The widget to display inside the scroll area.
  final Widget child;

  /// The direction in which the scroll area scrolls.
  final Axis scrollDirection;

  /// The scroll controller for the scroll area.
  final ScrollController? controller;

  /// Whether to show the scrollbar.
  final bool showScrollbar;

  /// The thickness of the scrollbar.
  final double scrollbarThickness;

  /// The radius of the scrollbar.
  final double scrollbarRadius;

  /// The color of the scrollbar. Defaults to medium gray.
  final Color? scrollbarColor;

  /// Padding around the scrollable content.
  final EdgeInsetsGeometry? padding;

  /// The scroll physics to use.
  final ScrollPhysics? physics;

  /// The clip behavior for the scroll area.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    Widget scrollableChild = SingleChildScrollView(
      scrollDirection: scrollDirection,
      controller: controller,
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      clipBehavior: clipBehavior,
      child: child,
    );

    if (showScrollbar) {
      scrollableChild = CupertinoScrollbar(
        controller: controller,
        thickness: scrollbarThickness,
        radius: Radius.circular(scrollbarRadius),
        thumbVisibility: false, // Show on scroll only
        child: scrollableChild,
      );
    }

    return scrollableChild;
  }
}

/// A scroll area that always shows scrollbars.
class AppScrollAreaWithVisibleScrollbar extends StatelessWidget {
  /// Creates a scroll area with always visible scrollbar.
  const AppScrollAreaWithVisibleScrollbar({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.scrollbarThickness = 6.0,
    this.scrollbarRadius = 3.0,
    this.scrollbarColor,
    this.padding,
    this.physics,
    this.clipBehavior = Clip.hardEdge,
  });

  /// The widget to display inside the scroll area.
  final Widget child;

  /// The direction in which the scroll area scrolls.
  final Axis scrollDirection;

  /// The scroll controller for the scroll area.
  final ScrollController? controller;

  /// The thickness of the scrollbar.
  final double scrollbarThickness;

  /// The radius of the scrollbar.
  final double scrollbarRadius;

  /// The color of the scrollbar.
  final Color? scrollbarColor;

  /// Padding around the scrollable content.
  final EdgeInsetsGeometry? padding;

  /// The scroll physics to use.
  final ScrollPhysics? physics;

  /// The clip behavior for the scroll area.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      controller: controller,
      thickness: scrollbarThickness,
      radius: Radius.circular(scrollbarRadius),
      thumbVisibility: true, // Always show
      child: SingleChildScrollView(
        scrollDirection: scrollDirection,
        controller: controller,
        padding: padding,
        physics: physics ?? const BouncingScrollPhysics(),
        clipBehavior: clipBehavior,
        child: child,
      ),
    );
  }
}

/// A bidirectional scroll area that can scroll both horizontally and vertically.
class AppBidirectionalScrollArea extends StatelessWidget {
  /// Creates a bidirectional scroll area.
  const AppBidirectionalScrollArea({
    super.key,
    required this.child,
    this.horizontalController,
    this.verticalController,
    this.showScrollbars = true,
    this.scrollbarThickness = 6.0,
    this.scrollbarRadius = 3.0,
    this.scrollbarColor,
    this.padding,
    this.horizontalPhysics,
    this.verticalPhysics,
    this.clipBehavior = Clip.hardEdge,
  });

  /// The widget to display inside the scroll area.
  final Widget child;

  /// The horizontal scroll controller.
  final ScrollController? horizontalController;

  /// The vertical scroll controller.
  final ScrollController? verticalController;

  /// Whether to show the scrollbars.
  final bool showScrollbars;

  /// The thickness of the scrollbars.
  final double scrollbarThickness;

  /// The radius of the scrollbars.
  final double scrollbarRadius;

  /// The color of the scrollbars.
  final Color? scrollbarColor;

  /// Padding around the scrollable content.
  final EdgeInsetsGeometry? padding;

  /// The horizontal scroll physics to use.
  final ScrollPhysics? horizontalPhysics;

  /// The vertical scroll physics to use.
  final ScrollPhysics? verticalPhysics;

  /// The clip behavior for the scroll area.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    Widget scrollableChild = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: horizontalController,
      physics: horizontalPhysics ?? const BouncingScrollPhysics(),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: verticalController,
        padding: padding,
        physics: verticalPhysics ?? const BouncingScrollPhysics(),
        clipBehavior: clipBehavior,
        child: child,
      ),
    );

    if (showScrollbars) {
      // Add horizontal scrollbar
      scrollableChild = CupertinoScrollbar(
        controller: horizontalController,
        thickness: scrollbarThickness,
        radius: Radius.circular(scrollbarRadius),
        thumbVisibility: false,
        child: scrollableChild,
      );
    }

    return scrollableChild;
  }
}
