import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// Size variants for toggle buttons.
enum AppToggleSize { small, medium, large }

/// Variant styles for toggle buttons.
enum AppToggleVariant { default_, outline }

/// A toggle button widget that can be pressed to toggle between states.
///
/// providing a pressable toggle button with different visual states.
class AppToggle extends StatefulWidget {
  /// Creates a toggle button.
  const AppToggle({
    super.key,
    required this.child,
    this.isPressed = false,
    this.onPressed,
    this.disabled = false,
    this.size = AppToggleSize.medium,
    this.variant = AppToggleVariant.default_,
    this.borderRadius,
  });

  /// The widget to display inside the toggle button.
  final Widget child;

  /// Whether the toggle is currently pressed/active.
  final bool isPressed;

  /// Called when the toggle is pressed.
  final ValueChanged<bool>? onPressed;

  /// Whether the toggle is disabled.
  final bool disabled;

  /// Size variant of the toggle.
  final AppToggleSize size;

  /// Visual variant of the toggle.
  final AppToggleVariant variant;

  /// Custom border radius.
  final BorderRadius? borderRadius;

  @override
  State<AppToggle> createState() => _AppToggleState();
}

class _AppToggleState extends State<AppToggle> {
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _isPressed = widget.isPressed;
  }

  @override
  void didUpdateWidget(AppToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPressed != oldWidget.isPressed) {
      _isPressed = widget.isPressed;
    }
  }

  void _handleTap() {
    if (widget.disabled) return;

    setState(() {
      _isPressed = !_isPressed;
    });

    widget.onPressed?.call(_isPressed);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: _getPadding(),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: _getBorder(),
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: _getTextColor(), fontSize: _getFontSize()),
          child: widget.child,
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case AppToggleSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case AppToggleSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        );
      case AppToggleSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        );
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case AppToggleSize.small:
        return 12;
      case AppToggleSize.medium:
        return 14;
      case AppToggleSize.large:
        return 16;
    }
  }

  Color _getBackgroundColor() {
    if (widget.disabled) {
      return AppColors.lightGray.withValues(alpha: 0.5);
    }

    switch (widget.variant) {
      case AppToggleVariant.default_:
        return _isPressed
            ? AppColors.primaryBlue.withValues(alpha: 0.1)
            : const Color(0x00000000);
      case AppToggleVariant.outline:
        return _isPressed
            ? AppColors.primaryBlue.withValues(alpha: 0.1)
            : AppColors.backgroundWhite;
    }
  }

  Border? _getBorder() {
    switch (widget.variant) {
      case AppToggleVariant.default_:
        return null;
      case AppToggleVariant.outline:
        return Border.all(
          color: _isPressed ? AppColors.primaryBlue : AppColors.borderGray,
        );
    }
  }

  Color _getTextColor() {
    if (widget.disabled) return AppColors.mediumGray;

    return _isPressed ? AppColors.primaryBlue : AppColors.foregroundDark;
  }
}

/// A group of toggle buttons where only one can be selected at a time.
class AppToggleGroup<T> extends StatefulWidget {
  /// Creates a toggle group.
  const AppToggleGroup({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.disabled = false,
    this.size = AppToggleSize.medium,
    this.variant = AppToggleVariant.default_,
    this.direction = Axis.horizontal,
    this.spacing = 4.0,
  });

  /// The available options in the toggle group.
  final List<AppToggleOption<T>> options;

  /// Currently selected value.
  final T? value;

  /// Called when the selection changes.
  final ValueChanged<T?>? onChanged;

  /// Whether the entire group is disabled.
  final bool disabled;

  /// Size variant for all toggles in the group.
  final AppToggleSize size;

  /// Visual variant for all toggles in the group.
  final AppToggleVariant variant;

  /// Direction to layout the toggles.
  final Axis direction;

  /// Spacing between toggle buttons.
  final double spacing;

  @override
  State<AppToggleGroup<T>> createState() => _AppToggleGroupState<T>();
}

class _AppToggleGroupState<T> extends State<AppToggleGroup<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  void didUpdateWidget(AppToggleGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selectedValue = widget.value;
    }
  }

  void _handleTogglePressed(T value, bool isPressed) {
    if (widget.disabled) return;

    setState(() {
      _selectedValue = isPressed ? value : null;
    });

    widget.onChanged?.call(_selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    final children =
        widget.options.map((option) {
          final isSelected = _selectedValue == option.value;

          return AppToggle(
            isPressed: isSelected,
            onPressed: (pressed) => _handleTogglePressed(option.value, pressed),
            disabled: widget.disabled || option.disabled,
            size: widget.size,
            variant: widget.variant,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  Icon(option.icon, size: _getIconSize()),
                  const SizedBox(width: 4),
                ],
                Text(option.label),
              ],
            ),
          );
        }).toList();

    if (widget.direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: _addSpacing(children, widget.spacing),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: _addSpacing(children, widget.spacing),
      );
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case AppToggleSize.small:
        return 14;
      case AppToggleSize.medium:
        return 16;
      case AppToggleSize.large:
        return 18;
    }
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          SizedBox(
            width: widget.direction == Axis.horizontal ? spacing : 0,
            height: widget.direction == Axis.vertical ? spacing : 0,
          ),
        );
      }
    }
    return spacedChildren;
  }
}

/// A toggle option for use in toggle groups.
class AppToggleOption<T> {
  /// Creates a toggle option.
  const AppToggleOption({
    required this.value,
    required this.label,
    this.icon,
    this.disabled = false,
  });

  /// The value of this option.
  final T value;

  /// The display label.
  final String label;

  /// Optional icon to display.
  final IconData? icon;

  /// Whether this option is disabled.
  final bool disabled;
}
