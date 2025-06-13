import 'package:flutter/cupertino.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_colors.dart';

/// A form label widget that provides consistent styling and behavior
/// for form field labels throughout the application.
///
/// This component is designed to work seamlessly with form fields
/// and provides proper accessibility support.
class AppLabel extends StatelessWidget {
  /// Creates a label with the specified properties.
  const AppLabel({
    super.key,
    required this.text,
    this.required = false,
    this.style,
    this.color,
    this.fontSize,
  });

  /// The text to display in the label.
  final String text;

  /// Whether this label is for a required field.
  /// When true, displays a red asterisk after the text.
  final bool required;

  /// Optional custom text style.
  /// If null, uses the default label style from the theme.
  final TextStyle? style;

  /// Optional custom color for the label text.
  final Color? color;

  /// Optional custom font size.
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = AppTextStyles.bodySmall.copyWith(
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.foregroundDark,
    );

    final effectiveStyle =
        style?.copyWith(fontSize: fontSize, color: color) ??
        defaultStyle.copyWith(fontSize: fontSize);

    return RichText(
      text: TextSpan(
        text: text,
        style: effectiveStyle,
        children:
            required
                ? [
                  TextSpan(
                    text: ' *',
                    style: effectiveStyle.copyWith(
                      color: AppColors.destructiveRed,
                    ),
                  ),
                ]
                : null,
      ),
    );
  }
}
