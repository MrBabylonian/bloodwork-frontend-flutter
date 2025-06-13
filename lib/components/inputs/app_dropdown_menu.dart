import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

// Represents an item in the dropdown menu
class AppDropdownMenuItem<T> {
  final T value;
  final Widget child;
  final VoidCallback?
  onTap; // If direct action, otherwise use onSelected from AppDropdownMenu

  AppDropdownMenuItem({required this.value, required this.child, this.onTap});
}

// A Cupertino-styled dropdown menu button
class AppDropdownMenu<T> extends StatefulWidget {
  final Widget trigger;
  final List<AppDropdownMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final String? actionSheetTitle; // Optional title for the action sheet
  final String? actionSheetMessage; // Optional message for the action sheet
  final String?
  cancelActionText; // Text for the cancel button, defaults to "Cancel"

  const AppDropdownMenu({
    super.key,
    required this.trigger,
    required this.items,
    this.onSelected,
    this.actionSheetTitle,
    this.actionSheetMessage,
    this.cancelActionText,
  });

  @override
  State<AppDropdownMenu<T>> createState() => _AppDropdownMenuState<T>();
}

class _AppDropdownMenuState<T> extends State<AppDropdownMenu<T>> {
  void _showMenu(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final List<CupertinoActionSheetAction> actions =
        widget.items.map((item) {
          return CupertinoActionSheetAction(
            child: item.child,
            onPressed: () {
              Navigator.pop(context); // Dismiss the action sheet
              item.onTap?.call();
              if (widget.onSelected != null) {
                widget.onSelected!(item.value);
              }
            },
          );
        }).toList();

    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title:
                widget.actionSheetTitle != null
                    ? Text(
                      widget.actionSheetTitle!,
                      style: AppTextStyles.caption.copyWith(
                        color: appTheme.currentTheme.textTheme.textStyle.color
                            ?.withValues(alpha: 0.6),
                      ),
                    )
                    : null,
            message:
                widget.actionSheetMessage != null
                    ? Text(
                      widget.actionSheetMessage!,
                      style: AppTextStyles.footnote.copyWith(
                        color: appTheme.currentTheme.textTheme.textStyle.color
                            ?.withValues(alpha: 0.6),
                      ),
                    )
                    : null,
            actions: actions,
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context); // Dismiss the action sheet
              },
              child: Text(
                widget.cancelActionText ?? 'Cancel',
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: widget.trigger,
    );
  }
}

// --- Example Usage (Illustrative) ---
/*
class MyDropdownPage extends StatelessWidget {
  const MyDropdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? selectedValue;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Dropdown Menu'),
      ),
      child: SafeArea(
        child: Center(
          child: AppDropdownMenu<String>(
            trigger: CupertinoButton.filled(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedValue ?? 'Select Option'),
                  const SizedBox(width: AppDimensions.spacingS),
                  const Icon(CupertinoIcons.chevron_down, size: AppDimensions.iconSizeSmall),
                ],
              ),
              onPressed: null, // onPressed is handled by AppDropdownMenu's GestureDetector
            ),
            actionSheetTitle: 'Choose an option',
            actionSheetMessage: 'Please select one of the following items.',
            items: [
              AppDropdownMenuItem(
                value: 'option1',
                child: const Text('Option 1: Details'),
              ),
              AppDropdownMenuItem(
                value: 'option2',
                child: const Text('Option 2: Settings'),
              ),
              AppDropdownMenuItem(
                value: 'option3',
                onTap: () => print('Option 3 specific action'), // Specific action
                child: const Text('Option 3: Action & Select'),
              ),
            ],
            onSelected: (String value) {
              print('Selected: $value');
              // setState(() { selectedValue = value; }); // If in a StatefulWidget
            },
          ),
        ),
      ),
    );
  }
}
*/

// --- Mock Comparison (dropdown-menu.tsx) ---
// The current AppDropdownMenu uses CupertinoActionSheet, providing a basic
// iOS-style selection menu. The dropdown-menu.tsx mock, based on Radix UI,
// offers more advanced features and customization:
//
// Features in mock not fully supported by CupertinoActionSheet:
// - DropdownMenuCheckboxItem: Items with checkboxes.
//   - Partial Solution: AppDropdownMenuItem child could be a Row with a Checkbox and Text.
// - DropdownMenuRadioItem: Items for radio groups.
//   - Partial Solution: Similar to CheckboxItem, using a custom child and managing state.
// - DropdownMenuLabel: Non-interactive labels.
//   - Partial Solution: AppDropdownMenuItem with a Text child and no onTap.
// - DropdownMenuSeparator: Visual dividers.
//   - Partial Solution: AppDropdownMenuItem with a Divider child and no onTap/value.
// - DropdownMenuShortcut: Text aligned to the right (e.g., for keyboard shortcuts).
//   - Partial Solution: Custom child in AppDropdownMenuItem using Row and Spacer.
// - DropdownMenuGroup: For grouping items.
//   - CupertinoActionSheet has a title and message, but not arbitrary group sections.
// - DropdownMenuSub (Sub-menus): Nested menus.
//   - Not supported by CupertinoActionSheet. Requires a custom popover.
// - Custom Styling: The mock defines specific border radius, padding, shadows,
//   and background/foreground colors for the popover and items.
//   CupertinoActionSheet styling is largely system-defined.
//
// To fully implement these features and match the mock's visual styling,
// a custom popover implementation (e.g., using OverlayEntry) would be necessary
// instead of or in addition to CupertinoActionSheet.
//
// For now, AppDropdownMenuItem's child can be customized to achieve some of
// these effects (e.g., including icons, custom layouts for items).
