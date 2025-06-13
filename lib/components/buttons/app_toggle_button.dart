import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

enum AppToggleButtonVariant {
  defaultStyle, // Renamed from 'default' to avoid keyword clash
  outline,
}

enum AppToggleButtonSize {
  defaultSize, // Renamed
  sm,
  lg,
}

class AppToggleButton extends StatefulWidget {
  final bool isOn;
  final ValueChanged<bool> onPressed;
  final Widget child;
  final AppToggleButtonVariant variant;
  final AppToggleButtonSize size;
  final bool disabled;

  const AppToggleButton({
    super.key,
    required this.isOn,
    required this.onPressed,
    required this.child,
    this.variant = AppToggleButtonVariant.defaultStyle,
    this.size = AppToggleButtonSize.defaultSize,
    this.disabled = false,
  });

  @override
  AppToggleButtonState createState() => AppToggleButtonState();
}

class AppToggleButtonState extends State<AppToggleButton> {
  bool _isHovered = false;
  bool _isFocused = false; // Basic focus state

  // Style determination based on variant, size, and state
  Color _getBackgroundColor(BuildContext context) {
    if (widget.disabled) {
      return AppColors.backgroundDisabled.withAlpha((255 * 0.5).round());
    }
    if (widget.isOn) {
      return AppColors.primaryBlue; // accent
    }
    if (_isHovered) {
      return AppColors.mediumGray.withAlpha((255 * 0.1).round());
    }
    if (widget.variant == AppToggleButtonVariant.outline) {
      return CupertinoColors.transparent;
    }
    return CupertinoColors.transparent; // default variant background
  }

  Color _getForegroundColor(BuildContext context) {
    if (widget.disabled) {
      return AppColors.textDisabled;
    }
    if (widget.isOn) {
      return AppColors.accentForeground;
    }
    if (_isHovered && widget.variant == AppToggleButtonVariant.defaultStyle) {
      return AppColors
          .foregroundDark; // muted-foreground (darker on hover for default)
    }
    if (_isHovered && widget.variant == AppToggleButtonVariant.outline) {
      return AppColors.primaryBlue; // accent-foreground for outline hover
    }
    return AppColors.foregroundDark;
  }

  Border? _getBorder(BuildContext context) {
    if (widget.variant == AppToggleButtonVariant.outline) {
      if (_isFocused && !widget.disabled) {
        // Ring effect for focus
        return Border.all(color: AppColors.primaryBlue, width: 2.0);
      }
      return Border.all(color: AppColors.border); // input border
    }
    if (_isFocused && !widget.disabled) {
      // Ring effect for focus on default variant
      return Border.all(
        color: AppColors.primaryBlue.withAlpha((255 * 0.5).round()),
        width: 2.0,
      );
    }
    return null;
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case AppToggleButtonSize.sm:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingS,
          vertical: AppDimensions.spacingXs,
        ); // h-9 px-2.5
      case AppToggleButtonSize.lg:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingM,
        ); // h-11 px-5
      case AppToggleButtonSize.defaultSize:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ); // h-10 px-3
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case AppToggleButtonSize.sm:
        return 36.0; // h-9
      case AppToggleButtonSize.lg:
        return 44.0; // h-11
      case AppToggleButtonSize.defaultSize:
        return 40.0; // h-10
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final foregroundColor = _getForegroundColor(context);
    final border = _getBorder(context);
    final padding = _getPadding();
    final height = _getHeight();

    return FocusableActionDetector(
      onShowFocusHighlight: (v) => setState(() => _isFocused = v),
      onShowHoverHighlight: (v) => setState(() => _isHovered = v),
      child: GestureDetector(
        onTap: widget.disabled ? null : () => widget.onPressed(!widget.isOn),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: border,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMedium,
            ), // rounded-md
          ),
          child: DefaultTextStyle(
            style: AppTextStyles.bodySmall.copyWith(
              // text-sm font-medium
              color: foregroundColor,
              fontWeight: FontWeight.w500,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: foregroundColor,
                size: AppDimensions.iconSizeSmall,
              ),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
