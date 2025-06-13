import 'package:flutter/cupertino.dart';

/// A widget that attempts to size the child to a specific aspect ratio.
///
/// This component is equivalent to the aspect-ratio.tsx from the React mock,
/// providing a way to maintain consistent aspect ratios for content.
class AppAspectRatio extends StatelessWidget {
  /// Creates an aspect ratio widget.
  const AppAspectRatio({
    super.key,
    required this.aspectRatio,
    required this.child,
  });

  /// The aspect ratio to attempt to use.
  ///
  /// For example, a 16:9 aspect ratio would have a value of 16.0/9.0.
  final double aspectRatio;

  /// The widget to apply the aspect ratio to.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: aspectRatio, child: child);
  }
}
