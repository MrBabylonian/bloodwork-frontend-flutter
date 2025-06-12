import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// An expandable accordion component that shows/hides content.
///
/// This component allows users to toggle the visibility of content,
/// which is useful for displaying additional details without cluttering the UI.
class Accordion extends StatefulWidget {
  /// Creates an accordion with the specified properties.
  const Accordion({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.titleStyle,
    this.leadingIcon,
    this.trailingIcon,
    this.onToggle,
    this.backgroundColor = AppColors.backgroundWhite,
    this.borderRadius,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  /// The title displayed in the header.
  final Widget title;

  /// The content to show/hide.
  final Widget child;

  /// Whether the accordion is initially expanded.
  final bool initiallyExpanded;

  /// Optional custom style for the title.
  final TextStyle? titleStyle;

  /// Optional icon to display before the title.
  final IconData? leadingIcon;

  /// Optional custom icon to display for the toggle.
  final IconData? trailingIcon;

  /// Called when the accordion is expanded or collapsed.
  final ValueChanged<bool>? onToggle;

  /// Background color of the accordion.
  final Color backgroundColor;

  /// Optional custom border radius.
  final BorderRadius? borderRadius;

  /// Optional custom padding for the header and content.
  final EdgeInsetsGeometry? padding;

  /// Duration of the expand/collapse animation.
  final Duration animationDuration;

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _iconRotation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }

      if (widget.onToggle != null) {
        widget.onToggle!(_isExpanded);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius:
            widget.borderRadius ??
            BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.borderGray,
          width: AppDimensions.borderWidth,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section with toggle
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _toggleExpanded,
            child: Padding(
              padding:
                  widget.padding ??
                  const EdgeInsets.all(AppDimensions.contentPadding),
              child: Row(
                children: [
                  if (widget.leadingIcon != null) ...[
                    Icon(
                      widget.leadingIcon,
                      color: AppColors.primaryBlue,
                      size: AppDimensions.iconSizeMedium,
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                  ],

                  Expanded(
                    child: DefaultTextStyle(
                      style: widget.titleStyle ?? AppTextStyles.title3,
                      child: widget.title,
                    ),
                  ),

                  RotationTransition(
                    turns: _iconRotation,
                    child: Icon(
                      widget.trailingIcon ?? CupertinoIcons.chevron_down,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedSize(
            duration: widget.animationDuration,
            curve: Curves.easeInOut,
            child:
                _isExpanded
                    ? Padding(
                      padding: EdgeInsets.only(
                        left:
                            widget.padding?.horizontal ??
                            AppDimensions.contentPadding,
                        right:
                            widget.padding?.horizontal ??
                            AppDimensions.contentPadding,
                        bottom:
                            widget.padding?.vertical ??
                            AppDimensions.contentPadding,
                      ),
                      child: widget.child,
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
