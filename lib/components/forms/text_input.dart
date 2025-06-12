import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// A customized text input field following Cupertino design principles.
///
/// This component creates a consistent text input experience throughout
/// the application with built-in label, placeholder, and validation support.
class AppTextInput extends StatelessWidget {
  /// Creates a text input with the specified properties.
  const AppTextInput({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.autocorrect = true,
    this.focusNode,
  });

  /// Controller for the text field.
  final TextEditingController controller;

  /// Optional label displayed above the input field.
  final String? label;

  /// Placeholder text shown when the field is empty.
  final String? placeholder;

  /// The type of keyboard to use for editing the text.
  final TextInputType keyboardType;

  /// The action to take when the user indicates they are done editing.
  final TextInputAction textInputAction;

  /// Whether to hide the text being edited (for passwords).
  final bool obscureText;

  /// The maximum number of lines for the text to span.
  final int maxLines;

  /// The minimum number of lines for the text to span.
  final int? minLines;

  /// The maximum number of characters allowed in the text field.
  final int? maxLength;

  /// Error text to display when the input is invalid.
  final String? errorText;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text field.
  final ValueChanged<String>? onSubmitted;

  /// Whether the text field is enabled.
  final bool enabled;

  /// Whether the text field should be focused initially.
  final bool autofocus;

  /// Whether to enable autocorrection.
  final bool autocorrect;

  /// Focus node for controlling the focus of this input.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
            child: Text(label!, style: AppTextStyles.formLabel),
          ),
        ],
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          enabled: enabled,
          autofocus: autofocus,
          autocorrect: autocorrect,
          focusNode: focusNode,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border:
                errorText != null
                    ? Border.all(color: AppColors.destructiveRed)
                    : null,
          ),
          style: AppTextStyles.formInput,
          placeholderStyle: AppTextStyles.formPlaceholder,
        ),
        if (errorText != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.spacingXs),
            child: Text(
              errorText!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.destructiveRed,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
