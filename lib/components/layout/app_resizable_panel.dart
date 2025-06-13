import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

// TODO: Implement Resizable Panel Group, Panel, and Handle.
// This will be a custom implementation inspired by react-resizable-panels.

// --- Data Models (if necessary) ---
// May not be strictly needed if state is managed within widgets.

// --- Widgets ---

/// Main container for a group of resizable panels.
/// Manages the layout (horizontal or vertical) and distribution of space.
class AppResizablePanelGroup extends StatefulWidget {
  final Axis direction;
  final List<AppResizablePanel> children;
  final bool showHandles; // Whether to show resize handles between panels
  // TODO: Add initial sizes, min/max sizes per panel, onLayoutChanged callback etc.

  const AppResizablePanelGroup({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.showHandles = true,
  }) : assert(
         children.length >= 2,
         "ResizablePanelGroup must have at least two children.",
       );

  @override
  AppResizablePanelGroupState createState() => AppResizablePanelGroupState();
}

class AppResizablePanelGroupState extends State<AppResizablePanelGroup> {
  // List to store the flex factors or explicit sizes of the panels.
  // For simplicity, let's start with flex factors.
  late List<double> _panelFlexFactors;

  @override
  void initState() {
    super.initState();
    // Initialize flex factors, e.g., distribute equally or based on initial sizes.
    // For now, equal distribution.
    _panelFlexFactors = List.generate(widget.children.length, (index) => 1.0);
  }

  void _onDragUpdate(int handleIndex, DragUpdateDetails details) {
    setState(() {
      // This is a simplified drag logic.
      // It needs to be more robust, considering direction, min/max sizes, etc.
      final delta =
          widget.direction == Axis.horizontal
              ? details.delta.dx
              : details.delta.dy;

      // Naive flex adjustment:
      // Adjust flex of panel before and after the handle.
      // Needs to be bounded and ensure sum of flexes remains consistent or handled appropriately.
      // This logic is highly simplified and needs significant refinement.

      if (delta > 0) {
        // Dragging right or down
        if (_panelFlexFactors[handleIndex] > 0.1) {
          // Arbitrary min flex
          _panelFlexFactors[handleIndex] += 0.01 * delta.abs();
          if (handleIndex + 1 < _panelFlexFactors.length) {
            _panelFlexFactors[handleIndex + 1] -= 0.01 * delta.abs();
            if (_panelFlexFactors[handleIndex + 1] < 0.1) {
              _panelFlexFactors[handleIndex + 1] = 0.1;
            }
          }
        }
      } else {
        // Dragging left or up
        if (handleIndex + 1 < _panelFlexFactors.length &&
            _panelFlexFactors[handleIndex + 1] > 0.1) {
          _panelFlexFactors[handleIndex] -= 0.01 * delta.abs();
          if (_panelFlexFactors[handleIndex] < 0.1) {
            _panelFlexFactors[handleIndex] = 0.1;
          }

          _panelFlexFactors[handleIndex + 1] += 0.01 * delta.abs();
        }
      }
      // Normalize flex factors (optional, depending on strategy)
      // double sum = _panelFlexFactors.reduce((a, b) => a + b);
      // _panelFlexFactors = _panelFlexFactors.map((f) => f / sum * widget.children.length).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetsWithHandles = [];
    for (int i = 0; i < widget.children.length; i++) {
      widgetsWithHandles.add(
        Flexible(
          flex: (_panelFlexFactors[i] * 100).toInt(), // Flex must be int
          child: widget.children[i],
        ),
      );
      if (widget.showHandles && i < widget.children.length - 1) {
        widgetsWithHandles.add(
          AppResizableHandle(
            direction: widget.direction,
            onDragUpdate: (details) => _onDragUpdate(i, details),
            // withHandleIcon: true, // Example: make this configurable
          ),
        );
      }
    }

    if (widget.direction == Axis.horizontal) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgetsWithHandles,
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgetsWithHandles,
      );
    }
  }
}

/// Represents a single panel within a [AppResizablePanelGroup].
/// This widget itself might just be a container for its child content.
class AppResizablePanel extends StatelessWidget {
  final Widget child;
  final int? initialFlex; // Example for initial sizing
  final int? minFlex;
  // Or use constraints:
  // final double? initialSize;
  // final double? minSize;
  // final double? maxSize;

  const AppResizablePanel({
    super.key,
    required this.child,
    this.initialFlex,
    this.minFlex,
  });

  @override
  Widget build(BuildContext context) {
    // The actual sizing is controlled by the parent AppResizablePanelGroup
    // This widget primarily holds the content and panel-specific configurations.
    return Container(
      // color: Colors.grey[300], // For debugging panel boundaries
      child: child,
    );
  }
}

/// The draggable handle used to resize panels.
class AppResizableHandle extends StatelessWidget {
  final Axis direction;
  final bool withHandleIcon;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const AppResizableHandle({
    super.key,
    required this.direction,
    required this.onDragUpdate,
    this.onDragStart,
    this.onDragEnd,
    this.withHandleIcon = false, // Default to no icon as per mock's base handle
  });

  @override
  Widget build(BuildContext context) {
    // Mock: "relative flex w-px items-center justify-center bg-border ..."
    // Vertical: "h-px data-[panel-group-direction=vertical]:w-full ..."
    // Handle icon div: "z-10 flex h-4 w-3 items-center justify-center rounded-sm border bg-border"
    // GripVertical: "h-2.5 w-2.5" (10px)

    final double handleThickness =
        withHandleIcon
            ? AppDimensions.spacingS
            : 1.0; // w-px or thicker for icon
    final Color handleColor = AppColors.border;

    Widget handleCore;
    if (withHandleIcon) {
      handleCore = Container(
        width:
            direction == Axis.horizontal
                ? AppDimensions.spacingL
                : null, // w-3 (approx 12px, use 24px for touch)
        height:
            direction == Axis.vertical
                ? AppDimensions.spacingL
                : null, // h-4 (approx 16px, use 24px for touch)
        decoration: BoxDecoration(
          color: AppColors.border.withValues(
            alpha: 0.8,
          ), // bg-border (slightly transparent for effect)
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Icon(
          direction == Axis.horizontal
              ? CupertinoIcons.ellipsis
              : CupertinoIcons
                  .ellipsis, // Placeholder, GripVertical is specific
          // CupertinoIcons.line_horizontal_3_decrease for vertical grip?
          // Or use a custom painter for GripVertical if exact match needed.
          // For now, using a standard icon.
          size: AppDimensions.iconSizeSmall, // h-2.5 w-2.5 (10px, use 16px)
          color: AppColors.foregroundDark.withValues(alpha: 0.7),
        ),
      );
    } else {
      handleCore = SizedBox(
        width: direction == Axis.horizontal ? handleThickness : null,
        height: direction == Axis.vertical ? handleThickness : null,
        // child: Container(color: handleColor), // The line itself
      );
    }

    return GestureDetector(
      onHorizontalDragUpdate:
          direction == Axis.horizontal ? onDragUpdate : null,
      onVerticalDragUpdate: direction == Axis.vertical ? onDragUpdate : null,
      onHorizontalDragStart:
          direction == Axis.horizontal ? (_) => onDragStart?.call() : null,
      onVerticalDragStart:
          direction == Axis.vertical ? (_) => onDragStart?.call() : null,
      onHorizontalDragEnd:
          direction == Axis.horizontal ? (_) => onDragEnd?.call() : null,
      onVerticalDragEnd:
          direction == Axis.vertical ? (_) => onDragEnd?.call() : null,
      child: MouseRegion(
        cursor:
            direction == Axis.horizontal
                ? SystemMouseCursors.resizeLeftRight
                : SystemMouseCursors.resizeUpDown,
        child: Container(
          width:
              direction == Axis.horizontal
                  ? (withHandleIcon
                      ? AppDimensions.spacingL
                      : AppDimensions.spacingXs)
                  : null,
          height:
              direction == Axis.vertical
                  ? (withHandleIcon
                      ? AppDimensions.spacingL
                      : AppDimensions.spacingXs)
                  : null,
          color:
              withHandleIcon
                  ? CupertinoColors.transparent
                  : handleColor, // Line color or transparent if icon shown
          alignment: Alignment.center,
          child: handleCore,
        ),
      ),
    );
  }
}

// TODO:
// - Implement robust flex/size calculation in _AppResizablePanelGroupState.
// - Add support for min/max sizes for panels.
// - Implement `initialSize` properties for panels.
// - Refine handle appearance and interaction (focus rings, exact icon).
// - Consider using a package like `multi_split_view` for production-ready features if this becomes too complex.
// - Add keyboard support for resizing.
// - Ensure proper state restoration (e.g., on hot reload or if sizes are persisted).
