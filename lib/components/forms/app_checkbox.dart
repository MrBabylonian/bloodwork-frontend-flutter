import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

/// A styled checkbox component.
class AppCheckbox extends StatelessWidget {
  /// Creates an app checkbox.
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.activeColor = AppColors.primaryBlue,
    this.checkColor = AppColors.white,
    this.tristate = false,
  });

  /// Whether this checkbox is currently checked. Can be null if tristate is true.
  final bool? value;

  /// Called when the value of the checkbox should change.
  final ValueChanged<bool?>? onChanged;

  /// Optional label to display next to the checkbox.
  final String? label;

  /// The color to use when this checkbox is checked.
  final Color activeColor;

  /// The color to use for the check icon when this checkbox is checked.
  final Color checkColor;

  /// If true, the checkbox's value can be true, false, or null.
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    Widget checkbox = CupertinoCheckbox(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      checkColor: checkColor,
      tristate: tristate,
    );

    if (label != null) {
      checkbox = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          checkbox,
          const SizedBox(width: AppDimensions.spacingS),
          GestureDetector(
            onTap: () {
              if (onChanged != null) {
                if (tristate) {
                  onChanged!(
                    value == null ? false : (value == false ? true : null),
                  );
                } else {
                  onChanged!(!(value ?? false));
                }
              }
            },
            child: Text(label!, style: AppTextStyles.body),
          ),
        ],
      );
    }

    return checkbox;
  }
}
