import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// A segmented control component for selecting between a small number of options.
///
/// This component provides an iOS-style segmented control with
/// customizable appearance and behavior.
class SegmentedControl<T extends Object> extends StatelessWidget {
  /// Creates a segmented control with the specified properties.
  const SegmentedControl({
    super.key,
    required this.children,
    required this.value,
    required this.onValueChanged,
    this.padding,
    this.backgroundColor = AppColors.lightGray,
    this.selectedColor = AppColors.primaryBlue,
    this.borderColor = AppColors.borderGray,
  });

  /// The mapping of segment values to their display widgets.
  final Map<T, Widget> children;

  /// The currently selected segment value.
  final T value;

  /// Called when a new segment is selected.
  final ValueChanged<T> onValueChanged;

  /// Optional custom padding around the control.
  final EdgeInsetsGeometry? padding;

  /// Background color of the unselected segments.
  final Color backgroundColor;

  /// Color of the selected segment.
  final Color selectedColor;

  /// Color of the border around the control.
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: CupertinoSegmentedControl<T>(
        children: children,
        onValueChanged: onValueChanged,
        groupValue: value,
        padding: const EdgeInsets.all(AppDimensions.spacingXs),
        borderColor: borderColor,
        selectedColor: selectedColor,
        unselectedColor: backgroundColor,
      ),
    );
  }
}

/// A simple text segment for use with SegmentedControl.
class TextSegment extends StatelessWidget {
  /// Creates a text segment with the specified properties.
  const TextSegment({super.key, required this.label, this.isSelected = false});

  /// The text to display in the segment.
  final String label;

  /// Whether this segment is currently selected.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingXs,
      ),
      child: Text(
        label,
        style: AppTextStyles.buttonSecondary.copyWith(
          color: isSelected ? AppColors.white : AppColors.foregroundDark,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
