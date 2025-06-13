import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

/// A typedef for building the individual items displayed in the CupertinoPicker.
/// It takes the context and the specific item data.
typedef AppDropdownPickerItemBuilder<T> =
    Widget Function(BuildContext context, T item);

/// A typedef for building the widget that displays the currently selected item (or hint) in the collapsed dropdown field.
/// It takes the context, the currently selected item (nullable), and the hint text (nullable).
typedef AppDropdownDisplayBuilder<T> =
    Widget Function(BuildContext context, T? value, String? hintText);

/// An interface for items that have a label to be displayed in the dropdown.
/// If your item T implements this, its 'label' will be used for default display if no custom displayBuilder is provided.
abstract class LabeledValue {
  String get label;
}

/// A FormField that provides a Cupertino-style dropdown selection.
///
/// When tapped, it presents a modal bottom sheet with a `CupertinoPicker`
/// allowing the user to select a value from a list of items.
class AppCupertinoDropdownFormField<T> extends FormField<T> {
  final List<T> items;
  final AppDropdownPickerItemBuilder<T> pickerItemBuilder;
  final AppDropdownDisplayBuilder<T>? displayBuilder;
  final String? hintText;
  final String? labelText;
  final ValueChanged<T?>? onChanged;
  final double pickerSheetHeight;
  final Widget? prefix;
  final EdgeInsetsGeometry padding;
  final BoxDecoration?
  fieldDecoration; // Renamed from 'decoration' to avoid conflict with FormField.decoration
  final TextStyle? textStyle;
  final bool readOnly;

  AppCupertinoDropdownFormField({
    super.key,
    required this.items,
    required this.pickerItemBuilder,
    this.displayBuilder,
    this.hintText,
    this.labelText,
    this.onChanged,
    super.initialValue, // Use super-initializer parameter
    super.onSaved,
    super.validator,
    super.enabled = true,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
    this.pickerSheetHeight = 280.0,
    this.prefix,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacingS,
      vertical: AppDimensions.spacingS,
    ),
    this.fieldDecoration,
    this.textStyle,
    this.readOnly = false,
  }) : assert(items.isNotEmpty, 'items cannot be empty'),
       super(
         builder: (FormFieldState<T> field) {
           final _AppCupertinoDropdownFormFieldState<T> state =
               field as _AppCupertinoDropdownFormFieldState<T>;

           final effectiveTextStyle =
               textStyle ??
               AppTextStyles.body.copyWith(color: AppColors.foregroundDark);
           final defaultFieldDecoration = BoxDecoration(
             color:
                 enabled && !readOnly
                     ? CupertinoColors.tertiarySystemFill
                     : CupertinoColors.systemGrey5,
             borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
             border: Border.all(
               color:
                   field.hasError
                       ? CupertinoColors.destructiveRed
                       : CupertinoColors.systemGrey4,
               width: 0.5,
             ),
           );
           final effectiveFieldDecoration =
               fieldDecoration ?? defaultFieldDecoration;

           Widget displayContent;
           if (displayBuilder != null) {
             displayContent = displayBuilder(
               field.context, // Changed from displayBuilder! to displayBuilder
               field.value,
               hintText,
             );
           } else {
             final String? currentItemText =
                 field.value != null
                     ? (field.value is LabeledValue
                         ? (field.value as LabeledValue).label
                         : field.value.toString())
                     : hintText;
             displayContent = Text(
               currentItemText ?? '',
               style:
                   field.value == null && hintText != null
                       ? effectiveTextStyle.copyWith(
                         color: AppColors.mediumGray,
                       )
                       : effectiveTextStyle,
               maxLines: 1,
               overflow: TextOverflow.ellipsis,
             );
           }

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               if (labelText != null && labelText.isNotEmpty)
                 Padding(
                   padding: const EdgeInsets.only(
                     bottom: AppDimensions.spacingXs,
                   ),
                   child: Text(
                     labelText,
                     style: AppTextStyles.footnote.copyWith(
                       color: AppColors.mediumGray,
                     ),
                   ),
                 ),
               GestureDetector(
                 onTap:
                     !enabled || readOnly
                         ? null
                         : () {
                           // Use state.context instead of field.context or a local context
                           state.showPicker();
                         },
                 child: Container(
                   decoration: effectiveFieldDecoration,
                   padding: padding,
                   child: Row(
                     children: <Widget>[
                       if (prefix != null) ...[
                         prefix,
                         const SizedBox(width: AppDimensions.spacingS),
                       ],
                       Expanded(child: displayContent),
                       if (!readOnly) ...[
                         const SizedBox(width: AppDimensions.spacingXs),
                         Icon(
                           CupertinoIcons.chevron_down,
                           size: AppDimensions.iconSizeSmall,
                           color: AppColors.mediumGray,
                         ),
                       ],
                     ],
                   ),
                 ),
               ),
               if (field.hasError)
                 Padding(
                   padding: const EdgeInsets.only(
                     top: AppDimensions.spacingXs,
                     left: AppDimensions.spacingXs,
                   ),
                   child: Text(
                     field.errorText ??
                         '', // Use null-aware operator ?? instead of !
                     style: AppTextStyles.caption.copyWith(
                       // Assuming caption exists or will be added
                       color: CupertinoColors.destructiveRed,
                     ),
                   ),
                 ),
             ],
           );
         },
       );

  @override
  FormFieldState<T> createState() => _AppCupertinoDropdownFormFieldState<T>();
}

class _AppCupertinoDropdownFormFieldState<T> extends FormFieldState<T> {
  @override
  AppCupertinoDropdownFormField<T> get widget =>
      super.widget as AppCupertinoDropdownFormField<T>;

  void showPicker() {
    final initialIndex = value == null ? 0 : widget.items.indexOf(value as T);
    FixedExtentScrollController scrollController = FixedExtentScrollController(
      initialItem: initialIndex < 0 ? 0 : initialIndex,
    );

    T? tempSelectedItem =
        value ?? (widget.items.isNotEmpty ? widget.items.first : null);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: widget.pickerSheetHeight,
          padding: const EdgeInsets.only(top: 6.0),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                height: 44, // Standard iOS header height
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.systemGrey5,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingM,
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.body.copyWith(
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingM,
                      ),
                      child: Text(
                        'Done',
                        style: AppTextStyles.bodyBold.copyWith(
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () {
                        if (tempSelectedItem != null) {
                          didChange(tempSelectedItem);
                          if (widget.onChanged != null) {
                            widget.onChanged!(tempSelectedItem);
                          }
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: scrollController,
                  magnification: 1.1,
                  squeeze: 1.3,
                  useMagnifier: true,
                  itemExtent: 36.0, // Height of each item, adjust as needed
                  onSelectedItemChanged: (int selectedIndex) {
                    if (selectedIndex >= 0 &&
                        selectedIndex < widget.items.length) {
                      tempSelectedItem = widget.items[selectedIndex];
                    }
                  },
                  children: List<Widget>.generate(widget.items.length, (
                    int index,
                  ) {
                    return Center(
                      child: widget.pickerItemBuilder(
                        context,
                        widget.items[index],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
