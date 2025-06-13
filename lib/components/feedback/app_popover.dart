import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// Position options for the popover.
enum AppPopoverPosition {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// A popover widget that displays content in a floating overlay.
///
/// This component is equivalent to the popover.tsx from the React mock,
/// providing positioned popup content that can be triggered by user interaction.
class AppPopover extends StatefulWidget {
  /// Creates a popover.
  const AppPopover({
    super.key,
    required this.trigger,
    required this.content,
    this.position = AppPopoverPosition.bottom,
    this.offset = const Offset(0, 8),
    this.backgroundColor,
    this.borderRadius,
    this.showArrow = true,
    this.barrierDismissible = true,
    this.onDismissed,
    this.width,
    this.height,
    this.constraints,
  });

  /// The widget that triggers the popover.
  final Widget trigger;

  /// The content to display in the popover.
  final Widget content;

  /// Position of the popover relative to the trigger.
  final AppPopoverPosition position;

  /// Offset from the calculated position.
  final Offset offset;

  /// Background color of the popover.
  final Color? backgroundColor;

  /// Border radius of the popover.
  final BorderRadius? borderRadius;

  /// Whether to show an arrow pointing to the trigger.
  final bool showArrow;

  /// Whether tapping outside dismisses the popover.
  final bool barrierDismissible;

  /// Called when the popover is dismissed.
  final VoidCallback? onDismissed;

  /// Fixed width for the popover.
  final double? width;

  /// Fixed height for the popover.
  final double? height;

  /// Constraints for the popover size.
  final BoxConstraints? constraints;

  /// Shows the popover.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget trigger,
    required Widget content,
    AppPopoverPosition position = AppPopoverPosition.bottom,
    Offset offset = const Offset(0, 8),
    Color? backgroundColor,
    BorderRadius? borderRadius,
    bool showArrow = true,
    bool barrierDismissible = true,
    VoidCallback? onDismissed,
    double? width,
    double? height,
    BoxConstraints? constraints,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.1),
      builder:
          (BuildContext context) => AppPopover(
            trigger: trigger,
            content: content,
            position: position,
            offset: offset,
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
            showArrow: showArrow,
            barrierDismissible: barrierDismissible,
            onDismissed: onDismissed,
            width: width,
            height: height,
            constraints: constraints,
          ),
    );
  }

  @override
  State<AppPopover> createState() => _AppPopoverState();
}

class _AppPopoverState extends State<AppPopover>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismissed?.call();
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Barrier
        if (widget.barrierDismissible)
          Positioned.fill(
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(color: const Color(0x00000000)),
            ),
          ),

        // Popover content
        _AppPopoverPositioned(
          trigger: widget.trigger,
          position: widget.position,
          offset: widget.offset,
          child: AnimatedBuilder(
            animation: _animationController,
            builder:
                (context, child) => Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _AppPopoverContent(
                      backgroundColor: widget.backgroundColor,
                      borderRadius: widget.borderRadius,
                      showArrow: widget.showArrow,
                      position: widget.position,
                      width: widget.width,
                      height: widget.height,
                      constraints: widget.constraints,
                      child: widget.content,
                    ),
                  ),
                ),
          ),
        ),
      ],
    );
  }
}

class _AppPopoverPositioned extends StatelessWidget {
  const _AppPopoverPositioned({
    required this.trigger,
    required this.position,
    required this.offset,
    required this.child,
  });

  final Widget trigger;
  final AppPopoverPosition position;
  final Offset offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // This is a simplified positioning - in a real implementation,
    // you'd calculate the exact position based on the trigger's position
    return Center(child: child);
  }
}

class _AppPopoverContent extends StatelessWidget {
  const _AppPopoverContent({
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.showArrow = true,
    this.position = AppPopoverPosition.bottom,
    this.width,
    this.height,
    this.constraints,
  });

  final Widget child;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool showArrow;
  final AppPopoverPosition position;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints:
          constraints ??
          const BoxConstraints(
            minWidth: 100,
            maxWidth: 400,
            minHeight: 50,
            maxHeight: 600,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.backgroundWhite,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppDimensions.radiusMedium),
        child: child,
      ),
    );
  }
}

/// A simple popover with commonly used content structure.
class AppSimplePopover extends StatelessWidget {
  /// Creates a simple popover.
  const AppSimplePopover({
    super.key,
    required this.trigger,
    this.title,
    this.content,
    this.actions = const [],
    this.position = AppPopoverPosition.bottom,
    this.width = 300,
  });

  /// The widget that triggers the popover.
  final Widget trigger;

  /// Optional title for the popover.
  final String? title;

  /// The main content of the popover.
  final Widget? content;

  /// Action buttons to display at the bottom.
  final List<Widget> actions;

  /// Position of the popover.
  final AppPopoverPosition position;

  /// Width of the popover.
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () => _showPopover(context), child: trigger);
  }

  void _showPopover(BuildContext context) {
    AppPopover.show(
      context: context,
      trigger: trigger,
      position: position,
      width: width,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foregroundDark,
                ),
              ),
            ),
            Container(height: 1, color: AppColors.borderGray),
          ],

          if (content != null)
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: content!,
            ),

          if (actions.isNotEmpty) ...[
            Container(height: 1, color: AppColors.borderGray),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
