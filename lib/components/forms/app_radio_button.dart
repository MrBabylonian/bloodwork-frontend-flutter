import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

/// A single radio button item, Cupertino style.
class AppRadioListItem<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final String? title;
  final Widget? subtitle;
  final Color? activeColor;
  final Color?
  unselectedColor; // Keep for consistency, though Cupertino might not use it directly
  final bool dense;

  const AppRadioListItem({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.activeColor,
    this.unselectedColor,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;
    final effectiveActiveColor = activeColor ?? AppColors.primaryBlue;
    // final effectiveUnselectedColor = unselectedColor ?? AppColors.mediumGray; // Not directly used by CupertinoListTile leading/trailing

    // Using a GestureDetector to make the whole row tappable
    return GestureDetector(
      onTap: () => onChanged(value),
      behavior: HitTestBehavior.opaque, // Ensures the whole area is tappable
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? AppDimensions.spacingXs : AppDimensions.spacingS,
          vertical:
              dense
                  ? AppDimensions.spacingXs / 2
                  : AppDimensions.spacingS /
                      1.5, // Adjusted for better visual balance
        ),
        child: Row(
          children: <Widget>[
            // Custom leading widget to mimic radio button
            Padding(
              padding: const EdgeInsets.only(right: AppDimensions.spacingS),
              child: Icon(
                isSelected
                    ? CupertinoIcons.checkmark_alt_circle_fill
                    : CupertinoIcons.circle,
                color: isSelected ? effectiveActiveColor : AppColors.mediumGray,
                size: AppDimensions.iconSizeMedium, // Standard icon size
              ),
            ),
            if (title != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title!,
                      style: AppTextStyles.body.copyWith(
                        color:
                            isSelected
                                ? AppColors
                                    .foregroundDark // Or effectiveActiveColor if title should also change color
                                : AppColors.foregroundDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppDimensions.spacingXs / 2),
                      DefaultTextStyle(
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mediumGray, // Subtitle color
                        ),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A group of radio buttons, allowing a single selection from multiple options.
/// Uses Cupertino styling.
class AppRadioGroup<T> extends StatelessWidget {
  final T selectedValue;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  // itemBuilder now provides the item and the groupValue for convenience
  final Widget Function(
    BuildContext context,
    T item,
    T groupValue,
    ValueChanged<T?> onChanged,
  )
  itemBuilder;
  final Axis direction;
  final WrapAlignment wrapAlignment;
  final double spacing;
  final double runSpacing;

  const AppRadioGroup({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
    this.direction = Axis.vertical,
    this.wrapAlignment = WrapAlignment.start,
    this.spacing = AppDimensions.spacingS,
    this.runSpacing = AppDimensions.spacingS,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            items.map((item) {
              // Pass context, item, selectedValue (as groupValue), and onChanged callback
              return itemBuilder(context, item, selectedValue, onChanged);
            }).toList(),
      );
    } else {
      return Wrap(
        direction: direction,
        alignment: wrapAlignment,
        spacing: spacing,
        runSpacing: runSpacing,
        children:
            items.map((item) {
              // Pass context, item, selectedValue (as groupValue), and onChanged callback
              return itemBuilder(context, item, selectedValue, onChanged);
            }).toList(),
      );
    }
  }
}
