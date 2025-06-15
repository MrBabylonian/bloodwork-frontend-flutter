import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// A customized text input field following Cupertino design principles,
/// aligned with the styling from input.tsx mock.
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
    this.prefix,
    this.suffix,
    this.textCapitalization = TextCapitalization.none,
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

  /// Optional widget to display before the text input.
  final Widget? prefix;

  /// Optional widget to display after the text input.
  final Widget? suffix;

  /// Configures how the platform keyboard behaviorally capitalizes digits.
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null && errorText!.isNotEmpty;

    // Determine background color based on enabled state
    Color textFieldFillColor;
    if (!enabled) {
      textFieldFillColor = AppColors.backgroundDisabled;
    } else {
      textFieldFillColor = AppColors.backgroundSecondary;
    }

    BoxDecoration decoration = BoxDecoration(
      color: textFieldFillColor,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      border: Border.all(
        color: hasError ? AppColors.error : AppColors.borderGray,
        width: AppDimensions.borderWidth,
      ),
    );

    // Style for the input text itself
    TextStyle inputTextStyle = AppTextStyles.formInput.copyWith(
      color: enabled ? AppColors.foregroundDark : AppColors.textDisabled,
    );

    // Style for placeholder text
    TextStyle placeholderTextStyle = AppTextStyles.formPlaceholder.copyWith(
      color: AppColors.textDisabled,
    );

    // Style for the label
    TextStyle labelStyle = AppTextStyles.formLabel.copyWith(
      color: AppColors.foregroundDark,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
            child: Text(label!, style: labelStyle),
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
          prefix: prefix,
          suffix: suffix,
          textCapitalization: textCapitalization,
          padding: const EdgeInsets.symmetric(
            horizontal:
                AppDimensions.paddingMedium, // Corresponds to px-3 in mock
            vertical:
                AppDimensions
                    .paddingSmall, // Corresponds to py-2 in mock (adjust if h-10 target is strict)
          ),
          decoration: decoration,
          style: inputTextStyle,
          placeholderStyle: placeholderTextStyle,
          cursorColor: AppColors.primaryBlue, // Standard cursor color
        ),
        if (hasError) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: AppDimensions.spacingXxs,
              left: AppDimensions.paddingSmall,
            ),
            child: Text(
              errorText!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }
}

// --- Example Usage (Illustrative) ---
/*
class MyFormPage extends StatefulWidget {
  const MyFormPage({super.key});

  @override
  State<MyFormPage> createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = 'Name cannot be empty.';
      } else if (value.length < 3) {
        _nameError = 'Name must be at least 3 characters.';
      } else {
        _nameError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Text Input Examples'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                AppTextInput(
                  controller: _nameController,
                  label: 'Full Name',
                  placeholder: 'Enter your full name',
                  textInputAction: TextInputAction.next,
                  errorText: _nameError,
                  onChanged: _validateName,
                  prefix: const Padding(
                    padding: EdgeInsets.only(right: AppDimensions.spacingS),
                    child: Icon(CupertinoIcons.person, color: AppColors.mediumGray, size: AppDimensions.iconSizeMedium),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                AppTextInput(
                  controller: _emailController,
                  label: 'Email Address',
                  placeholder: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  // No direct error prop for this example, assuming form validation handles it
                ),
                const SizedBox(height: AppDimensions.spacingM),
                AppTextInput(
                  controller: _passwordController,
                  label: 'Password',
                  placeholder: 'Enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  suffix: Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.spacingS),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.eye_slash, color: AppColors.mediumGray, size: AppDimensions.iconSizeMedium),
                      onPressed: () {
                        // Toggle password visibility logic here
                        print('Toggle password visibility');
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                AppTextInput(
                  controller: TextEditingController(text: 'Disabled Text'),
                  label: 'Disabled Field',
                  enabled: false,
                ),
                const SizedBox(height: AppDimensions.spacingXl),
                CupertinoButton.filled(
                  child: const Text('Submit'),
                  onPressed: () {
                    _validateName(_nameController.text); // Trigger validation for name field
                    if (_formKey.currentState!.validate()) {
                      // This example doesn't use FormField, so direct validation check is illustrative
                      if (_nameError == null) {
                         print('Form submitted successfully!');
                         print('Name: ${_nameController.text}');
                         print('Email: ${_emailController.text}');
                         print('Password: ${_passwordController.text}');
                      } else {
                        print('Please correct the errors.');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
