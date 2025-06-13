import 'package:flutter/cupertino.dart';

/// A collapsible widget that can expand and collapse its content.
///
/// This component is equivalent to the collapsible.tsx from the React mock,
/// providing smooth expand/collapse animations for content sections.
class AppCollapsible extends StatefulWidget {
  /// Creates a collapsible widget.
  const AppCollapsible({
    super.key,
    required this.child,
    this.isExpanded = false,
    this.onExpansionChanged,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  /// The widget to show/hide when expanded/collapsed.
  final Widget child;

  /// Whether the collapsible is initially expanded.
  final bool isExpanded;

  /// Called when the expansion state changes.
  final ValueChanged<bool>? onExpansionChanged;

  /// The duration of the expand/collapse animation.
  final Duration duration;

  /// The curve to use for the expand/collapse animation.
  final Curve curve;

  @override
  State<AppCollapsible> createState() => _AppCollapsibleState();
}

class _AppCollapsibleState extends State<AppCollapsible>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;

    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AppCollapsible oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isExpanded != oldWidget.isExpanded) {
      _toggleExpansion(widget.isExpanded);
    }

    if (widget.duration != oldWidget.duration) {
      _animationController.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion(bool expand) {
    setState(() {
      _isExpanded = expand;
    });

    if (expand) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    widget.onExpansionChanged?.call(expand);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: _animation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// A collapsible widget with a trigger that controls the expansion state.
class AppCollapsibleWithTrigger extends StatefulWidget {
  /// Creates a collapsible widget with trigger.
  const AppCollapsibleWithTrigger({
    super.key,
    required this.trigger,
    required this.content,
    this.initiallyExpanded = false,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  /// The widget that acts as the trigger (usually a button or header).
  final Widget trigger;

  /// The content to show/hide when expanded/collapsed.
  final Widget content;

  /// Whether the collapsible is initially expanded.
  final bool initiallyExpanded;

  /// The duration of the expand/collapse animation.
  final Duration duration;

  /// The curve to use for the expand/collapse animation.
  final Curve curve;

  @override
  State<AppCollapsibleWithTrigger> createState() =>
      _AppCollapsibleWithTriggerState();
}

class _AppCollapsibleWithTriggerState extends State<AppCollapsibleWithTrigger> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(onTap: _toggle, child: widget.trigger),
        AppCollapsible(
          isExpanded: _isExpanded,
          duration: widget.duration,
          curve: widget.curve,
          child: widget.content,
        ),
      ],
    );
  }
}
