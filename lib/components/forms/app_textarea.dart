import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// A multiline text input field following Cupertino design principles,
/// similar to the textarea.tsx component from the React mock.
///
/// This component provides a consistent textarea experience throughout
/// the application with built-in label, placeholder, and validation support.
class AppTextarea extends StatelessWidget {
  /// Creates a textarea with the specified properties.
  const AppTextarea({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType = TextInputType.multiline,
    this.textInputAction = TextInputAction.newline,
    this.focusNode,
    this.autofocus = false,
    this.showCounter = false,
  });

  /// Controller for the textarea input.
  final TextEditingController controller;

  /// Optional label text displayed above the textarea.
  final String? label;

  /// Placeholder text displayed when the textarea is empty.
  final String? placeholder;

  /// Minimum number of lines for the textarea.
  final int minLines;

  /// Maximum number of lines for the textarea.
  final int maxLines;

  /// Maximum number of characters allowed.
  final int? maxLength;

  /// Error message to display below the textarea.
  final String? errorText;

  /// Callback fired when the textarea value changes.
  final ValueChanged<String>? onChanged;

  /// Callback fired when the user submits the textarea.
  final ValueChanged<String>? onSubmitted;

  /// Whether the textarea is enabled for input.
  final bool enabled;

  /// Whether the textarea is read-only.
  final bool readOnly;

  /// The type of keyboard to show.
  final TextInputType keyboardType;

  /// The action to display on the keyboard.
  final TextInputAction textInputAction;

  /// Focus node for controlling focus.
  final FocusNode? focusNode;

  /// Whether to automatically focus the textarea.
  final bool autofocus;

  /// Whether to show character counter.
  final bool showCounter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.foregroundDark,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
        ],

        // Textarea Container
        Container(
          decoration: BoxDecoration(
            color:
                enabled
                    ? AppColors.lightGray
                    : AppColors.lightGray.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color:
                  errorText != null
                      ? AppColors.destructiveRed
                      : AppColors.borderGray,
              width: 1.0,
            ),
          ),
          child: CupertinoTextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            readOnly: readOnly,
            autofocus: autofocus,
            minLines: minLines,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            placeholder: placeholder,
            placeholderStyle: AppTextStyles.body.copyWith(
              color: AppColors.mediumGray,
            ),
            style: AppTextStyles.body.copyWith(
              color: enabled ? AppColors.foregroundDark : AppColors.mediumGray,
            ),
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: const BoxDecoration(),
            textAlignVertical: TextAlignVertical.top,
          ),
        ),

        // Error text and counter
        if (errorText != null || (showCounter && maxLength != null)) ...[
          const SizedBox(height: AppDimensions.paddingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Error text
              if (errorText != null)
                Expanded(
                  child: Text(
                    errorText!,
                    style: AppTextStyles.footnote.copyWith(
                      color: AppColors.destructiveRed,
                    ),
                  ),
                ),

              // Character counter
              if (showCounter && maxLength != null)
                Text(
                  '${controller.text.length}/${maxLength!}',
                  style: AppTextStyles.footnote.copyWith(
                    color:
                        controller.text.length > maxLength!
                            ? AppColors.destructiveRed
                            : AppColors.mediumGray,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
