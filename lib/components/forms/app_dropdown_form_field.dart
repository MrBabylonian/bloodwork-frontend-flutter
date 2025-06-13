// ignore_for_file: overridden_fields

import 'package:flutter/cupertino.dart';
import '../inputs/app_dropdown_menu.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class AppDropdownFormField<T> extends FormField<T> {
  final String? labelText;
  final String? hintText;
  final List<AppDropdownMenuItem<T>> items;
  @override
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  @override
  final FormFieldValidator<T>? validator;
  @override
  final AutovalidateMode autovalidateMode;
  final String? actionSheetTitle;
  final String? actionSheetMessage;
  final String? cancelActionText;
  final Widget? prefixIcon;
  final Widget? suffixIcon; // Defaults to a dropdown arrow
  @override // Added @override
  final bool enabled;

  AppDropdownFormField({
    super.key,
    required this.items,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.actionSheetTitle,
    this.actionSheetMessage,
    this.cancelActionText,
    this.prefixIcon,
    this.suffixIcon,
    super.onSaved,
    this.enabled =
        true, // Ensure super.enabled is called if this is intended to override
    super.restorationId,
  }) : super(
         initialValue: initialValue,
         validator: validator,
         autovalidateMode: autovalidateMode,
         enabled: enabled, // Pass enabled to super constructor
         builder: (FormFieldState<T> field) {
           // final _AppDropdownFormFieldState<T> state = field as _AppDropdownFormFieldState<T>; // state variable not used

           final effectiveSuffixIcon =
               suffixIcon ??
               const Icon(
                 CupertinoIcons.chevron_down,
                 size: AppDimensions.iconSizeSmall,
                 color: AppColors.textSecondary, // Corrected
               );

           // Find the display child for the currently selected value
           Widget displayChild;
           if (field.value == null) {
             displayChild = Text(
               hintText ?? 'Select an option',
               style: AppTextStyles.body.copyWith(
                 color: AppColors.textDisabled,
               ), // Corrected
             );
           } else {
             final selectedItem = items.firstWhere(
               (item) => item.value == field.value,
               orElse:
                   () => AppDropdownMenuItem(
                     value:
                         field.value
                             as T, // Should not happen if items are correct
                     child: Text(
                       field.value.toString(),
                       style: AppTextStyles.body,
                     ),
                   ),
             );
             displayChild = selectedItem.child;
           }

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               if (labelText != null)
                 Padding(
                   padding: const EdgeInsets.only(
                     bottom: AppDimensions.spacingXs,
                   ),
                   child: Text(
                     labelText,
                     style: AppTextStyles.formLabel, // Corrected
                   ),
                 ),
               AppDropdownMenu<T>(
                 trigger: CupertinoButton(
                   padding: const EdgeInsets.symmetric(
                     horizontal: AppDimensions.paddingMedium, // Corrected
                     vertical: AppDimensions.paddingSmall, // Corrected
                   ),
                   color: AppColors.backgroundSecondary, // Corrected
                   disabledColor: AppColors.backgroundDisabled, // Corrected
                   onPressed:
                       enabled ? () {} : null, // Tap handled by AppDropdownMenu
                   borderRadius: BorderRadius.circular(
                     AppDimensions.borderRadiusMedium,
                   ), // Corrected
                   child: Row(
                     children: [
                       if (prefixIcon != null)
                         Padding(
                           padding: const EdgeInsets.only(
                             right: AppDimensions.spacingS,
                           ),
                           child: prefixIcon,
                         ),
                       Expanded(child: displayChild),
                       // No need to check effectiveSuffixIcon for null, it's guaranteed to be non-null
                       Padding(
                         padding: const EdgeInsets.only(
                           left: AppDimensions.spacingS,
                         ),
                         child: effectiveSuffixIcon,
                       ),
                     ],
                   ),
                 ),
                 items: items,
                 onSelected:
                     enabled
                         ? (T value) {
                           field.didChange(value);
                           if (onChanged != null) {
                             onChanged(value);
                           }
                         }
                         : null,
                 actionSheetTitle: actionSheetTitle,
                 actionSheetMessage: actionSheetMessage,
                 cancelActionText: cancelActionText,
               ),
               if (field.hasError)
                 Padding(
                   padding: const EdgeInsets.only(
                     top: AppDimensions.spacingXxs,
                     left: AppDimensions.paddingSmall,
                   ), // Corrected
                   child: Text(
                     field.errorText!,
                     style: AppTextStyles.caption.copyWith(
                       color: AppColors.error,
                     ), // Corrected
                   ),
                 ),
             ],
           );
         },
       );

  @override
  FormFieldState<T> createState() => _AppDropdownFormFieldState<T>();
}

class _AppDropdownFormFieldState<T> extends FormFieldState<T> {
  @override
  AppDropdownFormField<T> get widget => super.widget as AppDropdownFormField<T>;

  @override
  void didChange(T? value) {
    super.didChange(value);
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
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
  String? _selectedOption;
  String? _selectedOptionWithIcon;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Dropdown Form Field'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge), // Corrected
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                AppDropdownFormField<String>(
                  labelText: 'Select an Option',
                  hintText: 'Choose from the list',
                  items: [
                    AppDropdownMenuItem(value: 'opt1', child: const Text('Option 1')),
                    AppDropdownMenuItem(value: 'opt2', child: const Text('Option 2: More Details')),
                    AppDropdownMenuItem(value: 'opt3', child: const Text('Option 3: Special')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value;
                    });
                    print('Selected option: $value');
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an option.';
                    }
                    return null;
                  },
                  actionSheetTitle: 'Available Options',
                ),
                const SizedBox(height: AppDimensions.spacingL),
                AppDropdownFormField<String>(
                  labelText: 'Category',
                  hintText: 'Select category',
                  prefixIcon: const Icon(CupertinoIcons.tag, size: AppDimensions.iconSizeMedium, color: AppColors.primaryBlue), // Changed icon color for better visibility
                  items: [
                    AppDropdownMenuItem(value: 'tech', child: const Text('Technology')),
                    AppDropdownMenuItem(value: 'health', child: const Text('Health & Wellness')),
                    AppDropdownMenuItem(value: 'finance', child: const Text('Finance')),
                  ],
                  initialValue: 'health',
                  onChanged: (value) {
                    setState(() {
                      _selectedOptionWithIcon = value;
                    });
                  },
                  validator: (value) => value == null ? 'Category is required' : null,
                ),
                const SizedBox(height: AppDimensions.spacingXl),
                CupertinoButton.filled(
                  child: const Text('Submit'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Process data
                      print('Form submitted successfully!');
                      print('Selected Option: $_selectedOption');
                      print('Selected Category: $_selectedOptionWithIcon');
                      // Show a success toast or navigate
                    } else {
                      print('Form validation failed.');
                    }
                  },
                ),
                const SizedBox(height: AppDimensions.spacingM),
                if (_selectedOption != null) Text('Current selection: $_selectedOption'),
                if (_selectedOptionWithIcon != null) Text('Current category: $_selectedOptionWithIcon'),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
