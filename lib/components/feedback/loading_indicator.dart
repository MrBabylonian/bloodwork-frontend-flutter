import 'package:flutter/cupertino.dart';

/// A standardized loading indicator for the application.
///
/// This component wraps the `CupertinoActivityIndicator` to provide a consistent
/// loading spinner. It can be customized with size and color if needed in the future.
class LoadingIndicator extends StatelessWidget {
  /// Creates a loading indicator.
  const LoadingIndicator({
    super.key,
    this.radius = 14.0, // Default CupertinoActivityIndicator radius
  });

  /// The radius of the spinner.
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Center(child: CupertinoActivityIndicator(radius: radius));
  }
}
