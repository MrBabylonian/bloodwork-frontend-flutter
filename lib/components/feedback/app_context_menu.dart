import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// Defines an item in the AppContextMenu.
class AppContextMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onSelected;
  final bool isSeparator;
  final String? shortcutText; // For future use, like in desktop apps
  final bool enabled;

  AppContextMenuItem({
    required this.label,
    this.icon,
    this.onSelected,
    this.shortcutText,
    this.enabled = true,
  }) : isSeparator = false;

  AppContextMenuItem.separator()
    : label = '',
      icon = null,
      onSelected = null,
      shortcutText = null,
      enabled = false,
      isSeparator = true;
}

/// A widget that provides a context menu for its child.
/// The menu is typically triggered by a long press.
class AppContextMenuArea extends StatelessWidget {
  final Widget child;
  final List<AppContextMenuItem> menuItems;
  final Offset offset; // Offset for the menu position relative to the tap.

  const AppContextMenuArea({
    super.key,
    required this.child,
    required this.menuItems,
    this.offset = Offset.zero,
  });

  void _showContextMenu(BuildContext context, TapDownDetails details) {
    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            actions:
                menuItems
                    .where(
                      (item) =>
                          !item.isSeparator &&
                          item.enabled &&
                          item.onSelected != null,
                    )
                    .map((item) {
                      return CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                          item.onSelected!();
                        },
                        child: Row(
                          children: [
                            if (item.icon != null) ...[
                              Icon(
                                item.icon,
                                size: AppDimensions.iconSizeSmall,
                                color:
                                    item.enabled
                                        ? AppColors.foregroundDark
                                        : AppColors.mediumGray,
                              ),
                              const SizedBox(width: AppDimensions.spacingS),
                            ],
                            Expanded(
                              child: Text(
                                item.label,
                                style:
                                    item.enabled
                                        ? AppTextStyles.body.copyWith(
                                          color: AppColors.foregroundDark,
                                        )
                                        : AppTextStyles.body.copyWith(
                                          color: AppColors.mediumGray,
                                        ),
                              ),
                            ),
                            if (item.shortcutText != null) ...[
                              const SizedBox(width: AppDimensions.spacingL),
                              Text(
                                item.shortcutText!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.mediumGray,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    })
                    .toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.body.copyWith(
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
      onTapDown: (details) {
        // Potentially use this for right-click on web/desktop in the future
      },
      onLongPressStart: (details) {
        _showContextMenu(
          context,
          TapDownDetails(globalPosition: details.globalPosition),
        );
      },
      child: child,
    );
  }
}

// Example Usage:
/*
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Context Menu Demo'),
      ),
      child: Center(
        child: AppContextMenuArea(
          menuItems: [
            AppContextMenuItem(label: 'Copy', icon: CupertinoIcons.doc_on_clipboard, onSelected: () => print('Copied')),
            AppContextMenuItem(label: 'Cut', icon: CupertinoIcons.scissors, onSelected: () => print('Cut')),
            AppContextMenuItem.separator(),
            AppContextMenuItem(label: 'Paste', icon: CupertinoIcons.doc_on_doc, onSelected: () => print('Pasted'), enabled: false),
            AppContextMenuItem(label: 'Select All', onSelected: () => print('Selected All'), shortcutText: '⌘A'),
          ],
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: const Text('Long press me!'),
          ),
        ),
      ),
    );
  }
}
*/
