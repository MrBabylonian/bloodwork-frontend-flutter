import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import 'responsive_container.dart';

/// Page layout type options to control content constraints
enum PageLayoutType {
  /// Full-width layout with no content constraints
  fullWidth,

  /// Centered content with responsive width constraints
  centered,

  /// Narrow content useful for forms and focused content
  narrow,
}

/// A scaffold component that provides a consistent page structure.
///
/// This component wraps pages with a consistent layout including optional
/// navigation bar, content area, and footer. It handles responsive behavior
/// automatically based on screen size.
class PageScaffold extends StatelessWidget {
  /// Creates a page scaffold with the specified properties.
  const PageScaffold({
    super.key,
    required this.body,
    this.navigationBar,
    this.backgroundColor = AppColors.backgroundWhite,
    this.padding,
    this.layoutType = PageLayoutType.centered,
    this.resizeToAvoidBottomInset = true,
    this.footer,
    this.scrollable = true,
    this.safeAreaBottom = true,
    this.safeAreaTop = true,
  });

  /// Main content of the page
  final Widget body;

  /// Optional navigation bar to display at the top
  final ObstructingPreferredSizeWidget? navigationBar;

  /// Background color of the page
  final Color backgroundColor;

  /// Optional custom padding for the page content
  final EdgeInsetsGeometry? padding;

  /// Layout type that controls how content is constrained
  final PageLayoutType layoutType;

  /// Whether to resize when the keyboard appears
  final bool resizeToAvoidBottomInset;

  /// Optional footer to display at the bottom of the page
  final Widget? footer;

  /// Whether the page content should be scrollable
  final bool scrollable;

  /// Whether to apply safe area at the bottom
  final bool safeAreaBottom;

  /// Whether to apply safe area at the top
  final bool safeAreaTop;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: navigationBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      child: SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        child: Column(
          children: [
            Expanded(child: _buildContent(context)),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }

  /// Builds the main content area based on layout type
  Widget _buildContent(BuildContext context) {
    Widget content;

    // Apply padding to the body content
    final paddedBody = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: body,
    );

    // Make content scrollable if needed
    if (scrollable) {
      content = CupertinoScrollbar(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: paddedBody,
        ),
      );
    } else {
      content = paddedBody;
    }

    // Apply appropriate responsive container based on layout type
    switch (layoutType) {
      case PageLayoutType.fullWidth:
        return content;
      case PageLayoutType.centered:
        return ResponsiveContainer(child: content);
      case PageLayoutType.narrow:
        return ResponsiveContainer(
          mobileWidth: double.infinity,
          tabletWidth: 550,
          desktopWidth: 650,
          child: content,
        );
    }
  }
}
