import 'package:flutter/cupertino.dart';
import 'dart:async';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// A Cupertino-styled tooltip that appears on long press.
class AppTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final TextStyle? textStyle;
  final Duration showDuration;
  final TooltipPosition position;
  final Offset? offset;

  const AppTooltip({
    super.key,
    required this.child,
    required this.message,
    this.padding,
    this.margin,
    this.decoration,
    this.textStyle,
    this.showDuration = const Duration(milliseconds: 1500),
    this.position = TooltipPosition.top,
    this.offset,
  });

  @override
  State<AppTooltip> createState() => _AppTooltipState();
}

enum TooltipPosition { top, bottom, left, right }

class _AppTooltipState extends State<AppTooltip> {
  OverlayEntry? _overlayEntry;
  Timer? _timer;

  void _showTooltip() {
    _removeTooltip(); // Remove any existing tooltip

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    _timer = Timer(widget.showDuration, () {
      _removeTooltip();
    });
  }

  void _removeTooltip() {
    _timer?.cancel();
    _timer = null;
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        final tooltipPadding =
            widget.padding ??
            const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingS,
              vertical: AppDimensions.spacingXs,
            );
        final tooltipMargin =
            widget.margin ?? const EdgeInsets.all(AppDimensions.spacingXs);
        final tooltipDecoration =
            widget.decoration ??
            BoxDecoration(
              color: AppColors.foregroundDark.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            );
        final tooltipTextStyle =
            widget.textStyle ??
            AppTextStyles.footnote.copyWith(color: AppColors.white);

        // Calculate tooltip position
        // This is a simplified calculation and might need adjustments for complex scenarios or screen edges.
        double top =
            offset.dy - size.height - AppDimensions.spacingS; // Default to top
        double left =
            offset.dx + size.width / 2; // Centered horizontally by default

        // Placeholder for actual tooltip size calculation
        // For accurate positioning, we'd need to measure the tooltip's size first.
        // This can be done by laying out the tooltip off-screen or using a GlobalKey.
        // For simplicity, we'll use estimated adjustments here.

        // This is a very basic positioning logic.
        // A more robust solution would calculate the tooltip's actual size first.
        final tooltipContent = Container(
          padding: tooltipPadding,
          margin: tooltipMargin,
          decoration: tooltipDecoration,
          child: Text(
            widget.message,
            style: tooltipTextStyle,
            textAlign: TextAlign.center,
          ),
        );

        // A more sophisticated positioning logic would be needed here,
        // considering the actual size of the tooltip widget.
        // For now, this is a starting point.
        // Let's refine positioning based on widget.position
        // This part needs the actual size of the tooltip to be accurate.
        // For now, we'll make rough adjustments.

        // The following positioning logic is highly simplified and assumes the tooltip is not too large.
        // It does not account for screen edges.
        double tooltipEstimatedHeight = 40; // Rough estimate
        double tooltipEstimatedWidth = 100; // Rough estimate

        switch (widget.position) {
          case TooltipPosition.top:
            top =
                offset.dy -
                tooltipEstimatedHeight -
                (widget.offset?.dy ?? AppDimensions.spacingXs);
            left =
                offset.dx +
                (size.width / 2) -
                (tooltipEstimatedWidth / 2) +
                (widget.offset?.dx ?? 0);
            break;
          case TooltipPosition.bottom:
            top =
                offset.dy +
                size.height +
                (widget.offset?.dy ?? AppDimensions.spacingXs);
            left =
                offset.dx +
                (size.width / 2) -
                (tooltipEstimatedWidth / 2) +
                (widget.offset?.dx ?? 0);
            break;
          case TooltipPosition.left:
            top =
                offset.dy +
                (size.height / 2) -
                (tooltipEstimatedHeight / 2) +
                (widget.offset?.dy ?? 0);
            left =
                offset.dx -
                tooltipEstimatedWidth -
                (widget.offset?.dx ?? AppDimensions.spacingXs);
            break;
          case TooltipPosition.right:
            top =
                offset.dy +
                (size.height / 2) -
                (tooltipEstimatedHeight / 2) +
                (widget.offset?.dy ?? 0);
            left =
                offset.dx +
                size.width +
                (widget.offset?.dx ?? AppDimensions.spacingS);
            break;
        }

        // Ensure it doesn't go off screen (very basic)
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        if (left < AppDimensions.spacingS) left = AppDimensions.spacingS;
        if (left + tooltipEstimatedWidth >
            screenWidth - AppDimensions.spacingS) {
          left = screenWidth - tooltipEstimatedWidth - AppDimensions.spacingS;
        }
        if (top < AppDimensions.spacingS) top = AppDimensions.spacingS;
        if (top + tooltipEstimatedHeight >
            screenHeight - AppDimensions.spacingS) {
          top = screenHeight - tooltipEstimatedHeight - AppDimensions.spacingS;
        }

        return Positioned(
          top: top,
          left: left,
          child: IgnorePointer(
            // Tooltip should not be interactive itself
            child: Opacity(
              // Optional: fade in animation
              opacity: 1.0, // Can be animated
              child: tooltipContent,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showTooltip,
      onTapUp:
          (_) => _removeTooltip(), // Also remove on tap up after long press
      onTapCancel: () => _removeTooltip(), // And on cancel
      child: widget.child,
    );
  }
}

// Example Usage (for testing):
/*
class TooltipTestPage extends StatelessWidget {
  const TooltipTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Tooltip Example'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppTooltip(
              message: 'This is a tooltip for the button!',
              child: CupertinoButton.filled(
                child: const Text('Long Press Me (Top)'),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 20),
            AppTooltip(
              message: 'Another tooltip, this one is longer to test wrapping and stuff.',
              position: TooltipPosition.bottom,
              child: CupertinoButton(
                child: const Text('Long Press Me (Bottom)'),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 20),
             AppTooltip(
              message: 'Left!',
              position: TooltipPosition.left,
              child: CupertinoButton(
                child: const Text('Long Press (Left)'),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 20),
            AppTooltip(
              message: 'Right side tooltip example.',
              position: TooltipPosition.right,
              child: CupertinoButton(
                child: const Text('Long Press (Right)'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
