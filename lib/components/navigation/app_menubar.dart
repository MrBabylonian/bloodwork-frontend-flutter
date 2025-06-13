import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

// --- Data Models for Menubar Structure ---

/// Represents a single item in a menubar menu or submenu.
class AppMenubarItemModel {
  final String id;
  final String label;
  final IconData? icon; // Optional icon
  VoidCallback? onTap; // Made non-final to be potentially wrapped
  final List<AppMenubarItemModel>? subItems; // For submenus
  final bool isCheckbox;
  bool isChecked; // For checkbox items, mutable
  final bool isRadio;
  final String? radioGroup; // To group radio items
  final bool isSeparator;
  final String? shortcut; // e.g., "Ctrl+O"
  final bool disabled;
  final bool
  inset; // For items that should be indented (e.g. checkbox, radio without icon)

  AppMenubarItemModel({
    required this.id,
    required this.label,
    this.icon,
    this.onTap,
    this.subItems,
    this.isCheckbox = false,
    this.isChecked = false,
    this.isRadio = false,
    this.radioGroup,
    this.isSeparator = false,
    this.shortcut,
    this.disabled = false,
    this.inset = false,
  }) : assert(
         isSeparator ||
             onTap != null ||
             (subItems != null && subItems.isNotEmpty) ||
             isCheckbox ||
             isRadio,
         'Menu item must have an action (onTap), sub-items, be a checkbox/radio, or be a separator.',
       );

  factory AppMenubarItemModel.separator() {
    return AppMenubarItemModel(
      id: 'separator_${DateTime.now().millisecondsSinceEpoch}',
      label: '',
      isSeparator: true,
    );
  }
}

/// Represents a top-level menu in the menubar (e.g., "File", "Edit").
class AppMenubarMenuModel {
  final String id;
  final String label;
  List<AppMenubarItemModel>
  items; // Made non-final for radio group state updates

  AppMenubarMenuModel({
    required this.id,
    required this.label,
    required this.items,
  });
}

// --- Widgets ---

/// The main menubar container.
class AppMenubar extends StatefulWidget {
  final List<AppMenubarMenuModel> menus;
  final Color backgroundColor;
  final Color foregroundColor; // For the text of the triggers
  final Color itemHighlightColor; // For when a menu is open or item hovered
  final Color itemForegroundColor; // For text inside dropdowns
  final Color
  itemHoverBackgroundColor; // For item hover background in dropdowns
  final Color
  itemHoverForegroundColor; // For item hover foreground in dropdowns
  final double height;

  const AppMenubar({
    super.key,
    required this.menus,
    this.backgroundColor = AppColors.lightGray, // Mock: bg-background
    this.foregroundColor = AppColors.foregroundDark,
    this.itemHighlightColor = AppColors.primaryBlue, // Mock: bg-accent
    this.itemForegroundColor =
        AppColors.foregroundDark, // Mock: text-popover-foreground
    this.itemHoverBackgroundColor =
        AppColors
            .primaryBlue, // Mock: bg-accent (using primaryBlue as a sensible default)
    this.itemHoverForegroundColor =
        AppColors.accentForeground, // Mock: text-accent-foreground
    this.height = 40.0, // Mock: h-10
  });

  @override
  State<AppMenubar> createState() => _AppMenubarState();
}

class _AppMenubarState extends State<AppMenubar> {
  // This state can be used to manage radio group selections if needed globally
  // For now, individual menu models will handle their radio groups.

  void _handleRadioSelection(
    AppMenubarMenuModel menuModel,
    AppMenubarItemModel selectedRadioItem,
  ) {
    setState(() {
      for (var item in menuModel.items) {
        if (item.isRadio && item.radioGroup == selectedRadioItem.radioGroup) {
          item.isChecked = (item.id == selectedRadioItem.id);
        }
      }
      // Also check sub-items recursively if radio items can be in submenus
      // For simplicity, assuming radio items are at the current menu level
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: widget.backgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingXs, // p-1
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:
            widget.menus.map((menuModel) {
              return _AppMenubarMenuWidget(
                menuModel: menuModel,
                foregroundColor: widget.foregroundColor,
                itemHighlightColor: widget.itemHighlightColor,
                menubarHeight: widget.height,
                itemForegroundColor: widget.itemForegroundColor,
                itemHoverBackgroundColor: widget.itemHoverBackgroundColor,
                itemHoverForegroundColor: widget.itemHoverForegroundColor,
                onRadioSelected: (selectedItem) {
                  _handleRadioSelection(menuModel, selectedItem);
                },
              );
            }).toList(),
      ),
    );
  }
}

class _AppMenubarMenuWidget extends StatefulWidget {
  final AppMenubarMenuModel menuModel;
  final Color foregroundColor;
  final Color itemHighlightColor;
  final double menubarHeight;
  final Color itemForegroundColor;
  final Color itemHoverBackgroundColor;
  final Color itemHoverForegroundColor;
  final Function(AppMenubarItemModel) onRadioSelected;

  const _AppMenubarMenuWidget({
    required this.menuModel,
    required this.foregroundColor,
    required this.itemHighlightColor,
    required this.menubarHeight,
    required this.itemForegroundColor,
    required this.itemHoverBackgroundColor,
    required this.itemHoverForegroundColor,
    required this.onRadioSelected,
  });

  @override
  _AppMenubarMenuWidgetState createState() => _AppMenubarMenuWidgetState();
}

class _AppMenubarMenuWidgetState extends State<_AppMenubarMenuWidget> {
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _menuKey = GlobalKey(); // Use a GlobalKey for positioning

  void _toggleMenu() {
    if (_isMenuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    // Close other menus if any are open (optional, for traditional menubar behavior)
    // This would require communication between _AppMenubarMenuWidget instances,
    // possibly via a shared state or callbacks through AppMenubar.

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isMenuOpen = true;
    });
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isMenuOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder:
          (context) => Positioned(
            left: offset.dx,
            top: offset.dy + size.height, // Position below the menu trigger
            width: 250, // Mock: w-56 (224px), adjusted for typical menu width
            child: CupertinoPopupSurface(
              // Using CupertinoPopupSurface for background/shadow
              child: _AppMenubarDropdown(
                items: widget.menuModel.items,
                foregroundColor: widget.itemForegroundColor,
                hoverBackgroundColor: widget.itemHoverBackgroundColor,
                hoverForegroundColor: widget.itemHoverForegroundColor,
                onItemSelected: (item) {
                  _closeMenu();
                  if (item.isCheckbox) {
                    setState(() {
                      item.isChecked = !item.isChecked;
                    });
                    item.onTap
                        ?.call(); // Call onTap even for checkbox if defined
                  } else if (item.isRadio) {
                    widget.onRadioSelected(
                      item,
                    ); // Let parent handle radio state
                    item.onTap?.call();
                  } else {
                    item.onTap?.call();
                  }
                },
                onSubmenuRequested: (item, subMenuKey) {
                  // This is where submenu logic would be triggered.
                  // For now, submenus are opened by _AppMenubarDropdownItem itself.
                },
                parentMenuCloseCallback: _closeMenu, // Pass the callback
                menubarHeight: widget.menubarHeight,
                itemHighlightColor: widget.itemHighlightColor,
                menuModel: widget.menuModel, // Pass menuModel
                onRadioSelectedInSubmenu:
                    widget.onRadioSelected, // Pass radio selection down
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mock: Trigger: \"inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors ... h-10 px-4 py-2\"
    // Mock: Data state open: \"bg-accent text-accent-foreground\"
    // Mock: Hover: \"bg-accent/80\" (using itemHighlightColor with opacity for hover)

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _menuKey, // Assign key here
        onTap: _toggleMenu,
        child: FocusableActionDetector(
          onShowFocusHighlight: (hasFocus) {
            // Optional: Add visual feedback for focus if needed, e.g. a border
          },
          child: MouseRegion(
            onEnter:
                (_) => setState(
                  () {},
                ), // Trigger rebuild for hover state if needed
            onExit: (_) => setState(() {}), // Trigger rebuild
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM, // px-3 or px-4
                vertical: AppDimensions.spacingS, // py-2
              ),
              decoration: BoxDecoration(
                color:
                    _isMenuOpen
                        ? widget.itemHighlightColor
                        : CupertinoColors.transparent,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMedium,
                ), // rounded-md
              ),
              child: Text(
                widget.menuModel.label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500, // font-medium
                  color:
                      _isMenuOpen
                          ? widget
                              .itemHoverForegroundColor // text-accent-foreground when open
                          : widget.foregroundColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppMenubarDropdown extends StatefulWidget {
  final List<AppMenubarItemModel> items;
  final Color foregroundColor;
  final Color hoverBackgroundColor;
  final Color hoverForegroundColor;
  final Function(AppMenubarItemModel) onItemSelected;
  final Function(AppMenubarItemModel, GlobalKey) onSubmenuRequested;
  final VoidCallback parentMenuCloseCallback;
  final double menubarHeight;
  final Color itemHighlightColor;
  final AppMenubarMenuModel menuModel; // Added
  final Function(AppMenubarItemModel) onRadioSelectedInSubmenu; // Added

  const _AppMenubarDropdown({
    required this.items,
    required this.foregroundColor,
    required this.hoverBackgroundColor,
    required this.hoverForegroundColor,
    required this.onItemSelected,
    required this.onSubmenuRequested,
    required this.parentMenuCloseCallback,
    required this.menubarHeight,
    required this.itemHighlightColor,
    required this.menuModel, // Added
    required this.onRadioSelectedInSubmenu, // Added
  });

  @override
  State<_AppMenubarDropdown> createState() => _AppMenubarDropdownState();
}

class _AppMenubarDropdownState extends State<_AppMenubarDropdown> {
  OverlayEntry? _activeSubmenuOverlayEntry;

  void _closeActiveSubmenu() {
    _activeSubmenuOverlayEntry?.remove();
    _activeSubmenuOverlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    // Mock: \"z-50 min-w-[8rem] overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md\"
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColors.lightGray, // Mock: bg-popover
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        // border: Border.all(color: AppColors.border), // Mock: border
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            widget.items.map((item) {
              if (item.isSeparator) {
                return Container(
                  height: 1,
                  color: AppColors.border,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: AppDimensions.spacingXxs,
                  ),
                );
              }
              return _AppMenubarDropdownItem(
                item: item,
                foregroundColor: widget.foregroundColor,
                hoverBackgroundColor: widget.hoverBackgroundColor,
                hoverForegroundColor: widget.hoverForegroundColor,
                onTap: () {
                  // Close submenu on item tap
                  _closeActiveSubmenu();
                  widget.onItemSelected(item);
                },
                onSubmenuOpenRequested: (submenuKey) {
                  // Close any open submenu before opening a new one
                  _closeActiveSubmenu();
                  // Delay the opening of the submenu to allow for animation
                  // Future.delayed(const Duration(milliseconds: 100), () { // MODIFIED
                  // if (mounted) {
                  // Check if still mounted

                  // MODIFIED: Resolve context-dependent data *before* the async gap
                  final List<AppMenubarItemModel>? subItems =
                      submenuKey.currentContext
                          ?.findAncestorWidgetOfExactType<
                            _AppMenubarDropdownItem
                          >()!
                          .item
                          .subItems;

                  // Capture context before async gap
                  final overlayState = Overlay.of(context);

                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted && subItems != null) {
                      _activeSubmenuOverlayEntry = OverlayEntry(
                        builder:
                            (context) => Positioned(
                              left: 0,
                              top: 0,
                              width: 250, // Mock: w-56
                              child: CupertinoPopupSurface(
                                child: _AppMenubarDropdown(
                                  items: subItems,
                                  foregroundColor: widget.foregroundColor,
                                  hoverBackgroundColor:
                                      widget.hoverBackgroundColor,
                                  hoverForegroundColor:
                                      widget.hoverForegroundColor,
                                  onItemSelected: (selectedSubItem) {
                                    _closeActiveSubmenu();
                                    widget.onItemSelected(selectedSubItem);
                                  },
                                  onSubmenuRequested: (subItem, subSubMenuKey) {
                                    // Handle nested submenus if necessary
                                  },
                                  parentMenuCloseCallback:
                                      widget.parentMenuCloseCallback,
                                  menubarHeight: widget.menubarHeight,
                                  itemHighlightColor: widget.itemHighlightColor,
                                  menuModel: widget.menuModel,
                                  onRadioSelectedInSubmenu:
                                      widget.onRadioSelectedInSubmenu,
                                ),
                              ),
                            ),
                      );
                      // Use captured overlay state instead of context
                      overlayState.insert(_activeSubmenuOverlayEntry!);
                    }
                  });
                },
                onSubmenuCloseRequested: () {
                  // Close submenu directly
                  _closeActiveSubmenu();
                },
                parentMenuCloseCallback: widget.parentMenuCloseCallback,
                menubarHeight: widget.menubarHeight,
                itemHighlightColor: widget.itemHighlightColor,
                menuModel: widget.menuModel, // Pass down menuModel
                onRadioSelectedInSubmenu:
                    widget.onRadioSelectedInSubmenu, // Pass down
              );
            }).toList(),
      ),
    );
  }
}

class _AppMenubarDropdownItem extends StatefulWidget {
  final AppMenubarItemModel item;
  final Color foregroundColor;
  final Color hoverBackgroundColor;
  final Color hoverForegroundColor;
  final VoidCallback onTap;
  final Function(GlobalKey) onSubmenuOpenRequested;
  final VoidCallback onSubmenuCloseRequested;
  final VoidCallback
  parentMenuCloseCallback; // To close the entire menu structure
  final double menubarHeight;
  final Color itemHighlightColor;
  final AppMenubarMenuModel menuModel; // Added
  final Function(AppMenubarItemModel) onRadioSelectedInSubmenu; // Added

  const _AppMenubarDropdownItem({
    required this.item,
    required this.foregroundColor,
    required this.hoverBackgroundColor,
    required this.hoverForegroundColor,
    required this.onTap,
    required this.onSubmenuOpenRequested,
    required this.onSubmenuCloseRequested,
    required this.parentMenuCloseCallback,
    required this.menubarHeight,
    required this.itemHighlightColor,
    required this.menuModel, // Added
    required this.onRadioSelectedInSubmenu, // Added
  });

  @override
  _AppMenubarDropdownItemState createState() => _AppMenubarDropdownItemState();
}

class _AppMenubarDropdownItemState extends State<_AppMenubarDropdownItem> {
  bool _isHovered = false;
  final GlobalKey _submenuAnchorKey = GlobalKey();

  void _handleTap() {
    if (widget.item.disabled) return;

    if (widget.item.subItems != null && widget.item.subItems!.isNotEmpty) {
      widget.onSubmenuOpenRequested(_submenuAnchorKey);
    } else {
      widget.onTap(); // This will call onItemSelected in the parent
      // which then calls parentMenuCloseCallback
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock: Item: \"relative flex cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors ...\"
    // Mock: Focus/Hover: \"bg-accent text-accent-foreground\" (handled by _isHovered)
    // Mock: Disabled: \"opacity-50 pointer-events-none\"

    Color currentForegroundColor =
        widget.item.disabled
            ? widget.foregroundColor.withValues(alpha: 0.5)
            : (_isHovered
                ? widget.hoverForegroundColor
                : widget.foregroundColor);
    Color? currentBackgroundColor =
        _isHovered && !widget.item.disabled
            ? widget.hoverBackgroundColor
            : null;

    if (widget.item.isCheckbox &&
        widget.item.isChecked &&
        !_isHovered &&
        !widget.item.disabled) {
      // Keep highlight if checked and not hovered (UX decision)
      // currentBackgroundColor = widget.hoverBackgroundColor.withOpacity(0.1);
    }

    Widget content = Row(
      key: _submenuAnchorKey,
      children: [
        SizedBox(
          width:
              widget.item.inset ||
                      widget.item.icon != null ||
                      widget.item.isCheckbox ||
                      widget.item.isRadio
                  ? AppDimensions
                      .spacingM // Equivalent to icon width for alignment
                  : 0,
          child:
              widget.item.icon != null &&
                      !widget.item.isCheckbox &&
                      !widget.item.isRadio
                  ? Icon(
                    widget.item.icon,
                    size: AppDimensions.iconSizeSmall,
                    color: currentForegroundColor,
                  )
                  : (widget.item.isCheckbox
                      ? _CheckboxIndicator(
                        isChecked: widget.item.isChecked,
                        color: currentForegroundColor,
                        isDisabled: widget.item.disabled,
                        isHovered: _isHovered,
                        highlightColor: widget.hoverBackgroundColor,
                      )
                      : (widget.item.isRadio
                          ? _RadioIndicator(
                            isChecked: widget.item.isChecked,
                            color: currentForegroundColor,
                            isDisabled: widget.item.disabled,
                            isHovered: _isHovered,
                            highlightColor: widget.hoverBackgroundColor,
                          )
                          : null)),
        ),
        if (widget.item.icon != null ||
            widget.item.isCheckbox ||
            widget.item.isRadio ||
            widget.item.inset)
          const SizedBox(
            width: AppDimensions.spacingS,
          ), // space after icon/check/radio
        Expanded(
          child: Text(
            widget.item.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: currentForegroundColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.item.shortcut != null) ...[
          const Spacer(),
          Text(
            widget.item.shortcut!,
            style: AppTextStyles.caption.copyWith(
              color: currentForegroundColor.withValues(alpha: 0.7),
            ), // text-muted-foreground
          ),
        ],
        if (widget.item.subItems != null && widget.item.subItems!.isNotEmpty)
          Icon(
            CupertinoIcons.right_chevron,
            size: AppDimensions.iconSizeSmall - 2,
            color: currentForegroundColor,
          ),
      ],
    );

    return MouseRegion(
      onEnter:
          widget.item.disabled
              ? null
              : (event) {
                setState(() => _isHovered = true);
                if (widget.item.subItems != null &&
                    widget.item.subItems!.isNotEmpty) {
                  // Debounce or delay opening submenu on hover
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (_isHovered && mounted) {
                      // Check if still hovered and mounted
                      widget.onSubmenuOpenRequested(_submenuAnchorKey);
                    }
                  });
                } else {
                  widget.onSubmenuCloseRequested(); // Close other submenus
                }
              },
      onExit:
          widget.item.disabled
              ? null
              : (event) {
                setState(() => _isHovered = false);
                // Do not close submenu immediately on exit, allow moving to submenu
              },
      cursor:
          widget.item.disabled
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque, // Ensure the whole area is tappable
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingS, // px-2
            vertical: AppDimensions.spacingXs + 2, // py-1.5 (6px)
          ),
          decoration: BoxDecoration(
            color: currentBackgroundColor,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusSmall,
            ), // rounded-sm
          ),
          child: content,
        ),
      ),
    );
  }
}

class _CheckboxIndicator extends StatelessWidget {
  final bool isChecked;
  final Color color;
  final bool isDisabled;
  final bool isHovered;
  final Color highlightColor;

  const _CheckboxIndicator({
    required this.isChecked,
    required this.color,
    required this.isDisabled,
    required this.isHovered,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    // Mock: Check: \"absolute left-2 flex h-3.5 w-3.5 items-center justify-center\"
    // Mock: Indicator: \"h-2 w-2 fill-current\"
    return Container(
      width: AppDimensions.iconSizeSmall, // h-3.5 w-3.5 (14px)
      height: AppDimensions.iconSizeSmall,
      decoration: BoxDecoration(
        // border: Border.all(color: isDisabled ? color.withOpacity(0.5) : (isHovered ? highlightColor : color), width: 1.5),
        // borderRadius: BorderRadius.circular(AppDimensions.radiusSmall / 2),
        // color: isChecked && isHovered && !isDisabled ? highlightColor.withOpacity(0.2) : Colors.transparent,
      ),
      child:
          isChecked
              ? Icon(
                CupertinoIcons.check_mark,
                size: AppDimensions.iconSizeSmall - 2, // h-2 w-2 (8px)
                color:
                    isDisabled
                        ? color.withValues(alpha: 0.5)
                        : (isHovered
                            ? highlightColor
                            : color), // Fixed: widget.highlightColor to highlightColor
              )
              : null,
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  final bool isChecked;
  final Color color;
  final bool isDisabled;
  final bool isHovered;
  final Color highlightColor;

  const _RadioIndicator({
    required this.isChecked,
    required this.color,
    required this.isDisabled,
    required this.isHovered,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    // Mock: Radio: \"absolute left-2 flex h-3.5 w-3.5 items-center justify-center\"
    // Mock: Indicator: \"h-2 w-2 fill-current\" -> a small circle
    return Container(
      width: AppDimensions.iconSizeSmall,
      height: AppDimensions.iconSizeSmall,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // border: Border.all(color: isDisabled ? color.withOpacity(0.5) : (isHovered ? highlightColor : color), width: 1.5),
        // color: isChecked && isHovered && !isDisabled ? highlightColor.withOpacity(0.2) : Colors.transparent,
      ),
      child:
          isChecked
              ? Center(
                child: Container(
                  width: AppDimensions.iconSizeSmall / 2, // h-2 w-2 (8px)
                  height: AppDimensions.iconSizeSmall / 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isDisabled
                            ? color.withValues(alpha: 0.5)
                            : (isHovered
                                ? highlightColor
                                : color), // Fixed: widget.highlightColor to highlightColor
                  ),
                ),
              )
              : null,
    );
  }
}

// Example Usage (can be placed in a separate file or a demo screen)
class AppMenubarExample extends StatefulWidget {
  const AppMenubarExample({super.key});

  @override
  // _AppMenubarExampleState createState() => _AppMenubarExampleState(); // MODIFIED
  AppMenubarExampleState createState() => AppMenubarExampleState(); // MODIFIED
}

// class _AppMenubarExampleState extends State<AppMenubarExample> { // MODIFIED
class AppMenubarExampleState extends State<AppMenubarExample> {
  // MODIFIED
  bool _showStatusBar = true;
  String _radioSelection = "Panel"; // To track radio button state
  late List<AppMenubarMenuModel> menus; // MODIFIED: Made instance variable

  @override
  void initState() {
    // ADDED: initState
    super.initState();
    menus = _initializeMenus(); // Initialize menus here
  }

  // Helper to update radio group items
  void _updateRadioItems(List<AppMenubarItemModel> items, String selectedId) {
    for (var item in items) {
      if (item.isRadio && item.radioGroup == "appearancePanel") {
        item.isChecked = item.id == selectedId;
      }
      if (item.subItems != null) {
        _updateRadioItems(item.subItems!, selectedId);
      }
    }
  }

  // ADDED: Method to initialize menus
  List<AppMenubarMenuModel> _initializeMenus() {
    return [
      AppMenubarMenuModel(
        id: "file",
        label: "File",
        items: [
          AppMenubarItemModel(
            id: "newTab",
            label: "New Tab",
            shortcut: "⌘T",
            // onTap: () => print("New Tab clicked"), // REMOVED
            onTap: () {},
          ),
          AppMenubarItemModel(
            id: "newWindow",
            label: "New Window",
            shortcut: "⌘N",
            // onTap: () => print("New Window clicked"), // REMOVED
            onTap: () {},
          ),
          AppMenubarItemModel(
            id: "newIncognito",
            label: "New Incognito Window",
            disabled: true,
            onTap: () {},
          ),
          AppMenubarItemModel.separator(),
          AppMenubarItemModel(
            id: "share",
            label: "Share",
            subItems: [
              AppMenubarItemModel(
                id: "emailLink",
                label: "Email Link",
                // onTap: () => print("Email link"), // REMOVED
                onTap: () {},
              ),
              AppMenubarItemModel(
                id: "messages",
                label: "Messages",
                // onTap: () => print("Messages"), // REMOVED
                onTap: () {},
              ),
              AppMenubarItemModel(
                id: "notes",
                label: "Notes",
                // onTap: () => print("Notes"), // REMOVED
                onTap: () {},
              ),
            ],
          ),
          AppMenubarItemModel.separator(),
          AppMenubarItemModel(
            id: "print",
            label: "Print...",
            shortcut: "⌘P",
            // onTap: () => print("Print clicked"), // REMOVED
            onTap: () {},
          ),
        ],
      ),
      AppMenubarMenuModel(
        id: "edit",
        label: "Edit",
        items: [
          AppMenubarItemModel(
            id: "undo",
            label: "Undo",
            shortcut: "⌘Z",
            // onTap: () => print("Undo"), // REMOVED
            onTap: () {},
          ),
          AppMenubarItemModel(
            id: "redo",
            label: "Redo",
            shortcut: "⇧⌘Z",
            // onTap: () => print("Redo"), // REMOVED
            onTap: () {},
          ),
          AppMenubarItemModel.separator(),
          AppMenubarItemModel(
            id: "cut",
            label: "Cut",
            // onTap: () => print("Cut"), // REMOVED
            onTap: () {},
          ),
          AppMenubarItemModel(
            id: "copy",
            label: "Copy",
            // onTap: () => print("Copy"), // REMOVED
            onTap: () {},
          ),
          AppMenubarItemModel(
            id: "paste",
            label: "Paste",
            // onTap: () => print("Paste"), // REMOVED
            onTap: () {},
          ),
        ],
      ),
      AppMenubarMenuModel(
        id: "view",
        label: "View",
        items: [
          AppMenubarItemModel(
            id: "showStatusBar",
            label: "Show Status Bar",
            isCheckbox: true,
            isChecked: _showStatusBar,
            onTap: () {
              setState(() {
                _showStatusBar = !_showStatusBar;
                var viewMenu = menus.firstWhere((m) => m.id == "view");
                var statusBarItem = viewMenu.items.firstWhere(
                  (i) => i.id == "showStatusBar",
                );
                statusBarItem.isChecked = _showStatusBar;
                // print("Show Status Bar: $_showStatusBar"); // REMOVED
              });
            },
          ),
          AppMenubarItemModel.separator(),
          AppMenubarItemModel(
            id: "appearance",
            label: "Appearance",
            subItems: [
              AppMenubarItemModel(
                id: "panelLeft",
                label: "Panel Left",
                isRadio: true,
                radioGroup: "appearancePanel",
                isChecked: _radioSelection == "Panel Left",
                onTap: () {
                  setState(() {
                    _radioSelection = "Panel Left";
                    var viewMenu = menus.firstWhere((m) => m.id == "view");
                    var appearanceMenu = viewMenu.items.firstWhere(
                      (i) => i.id == "appearance",
                    );
                    _updateRadioItems(appearanceMenu.subItems!, "panelLeft");
                    // print("Radio selected: Panel Left"); // REMOVED
                  });
                },
              ),
              AppMenubarItemModel(
                id: "panelRight",
                label: "Panel Right",
                isRadio: true,
                radioGroup: "appearancePanel",
                isChecked: _radioSelection == "Panel Right",
                onTap: () {
                  setState(() {
                    _radioSelection = "Panel Right";
                    var viewMenu = menus.firstWhere((m) => m.id == "view");
                    var appearanceMenu = viewMenu.items.firstWhere(
                      (i) => i.id == "appearance",
                    );
                    _updateRadioItems(appearanceMenu.subItems!, "panelRight");
                    // print("Radio selected: Panel Right"); // REMOVED
                  });
                },
              ),
              AppMenubarItemModel(
                id: "panelBottom",
                label: "Panel Bottom",
                isRadio: true,
                radioGroup: "appearancePanel",
                isChecked: _radioSelection == "Panel Bottom",
                onTap: () {
                  setState(() {
                    _radioSelection = "Panel Bottom";
                    var viewMenu = menus.firstWhere((m) => m.id == "view");
                    var appearanceMenu = viewMenu.items.firstWhere(
                      (i) => i.id == "appearance",
                    );
                    _updateRadioItems(appearanceMenu.subItems!, "panelBottom");
                    // print("Radio selected: Panel Bottom"); // REMOVED
                  });
                },
              ),
              AppMenubarItemModel.separator(),
              AppMenubarItemModel(
                id: "resetPanels",
                label: "Reset Panels",
                // onTap: () => print("Reset Panels"), // REMOVED
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
      AppMenubarMenuModel(
        id: "account",
        label: "Account",
        items: [
          AppMenubarItemModel(
            id: "user1",
            label: "User One",
            icon: CupertinoIcons.person_fill,
            // onTap: () => print("User One"), // REMOVED
            onTap: () {},
          ),
          AppMenubarItemModel(
            id: "user2",
            label: "User Two",
            icon: CupertinoIcons.person_2_fill,
            // onTap: () => print("User Two"), // REMOVED
            onTap: () {},
          ),
          AppMenubarItemModel.separator(),
          AppMenubarItemModel(
            id: "settings",
            label: "Settings",
            shortcut: "⌘,",
            icon: CupertinoIcons.gear_alt_fill,
            // onTap: () => print("Settings"), // REMOVED
            onTap: () {},
          ),
          AppMenubarItemModel(
            id: "newTeam",
            label: "New Team",
            icon: CupertinoIcons.group_solid,
            // onTap: () => print("New Team"), // REMOVED
            onTap: () {},
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // The 'menus' final variable is removed from here.
    // It now uses the instance variable 'this.menus' or 'menus'.
    return AppMenubar(menus: menus); // Use the instance field
  }
}

// To ensure radio button state is correctly managed within the AppMenubar itself,
// the AppMenubarItemModel's `isChecked` needs to be mutable, and the `onTap` for
// radio items should trigger a state update in a common ancestor, likely _AppMenubarState
// or by passing callbacks down that can update the original AppMenubarMenuModel list.

// The current _AppMenubarState._handleRadioSelection is a good start.
// It needs to be called correctly from the _AppMenubarDropdownItem.
// This involves passing the AppMenubarMenuModel instance down to where the tap occurs,
// or passing a more specific callback.

// Let's refine the callback chain for radio buttons.
// 1. _AppMenubarDropdownItem: onTap calls a method passed from _AppMenubarDropdown.
// 2. _AppMenubarDropdown: This method calls `widget.onRadioSelectedInSubmenu` (newly added).
// 3. _AppMenubarMenuWidget: `onRadioSelectedInSubmenu` is `widget.onRadioSelected`.
// 4. _AppMenubarState: `onRadioSelected` is `_handleRadioSelection`.

// The `_handleRadioSelection` in `_AppMenubarState` needs to correctly identify and update
// the `isChecked` status of all radio buttons within the same group across the specific `menuModel`.

// For Checkboxes: The state `isChecked` is toggled directly in `_AppMenubarMenuWidgetState`'s
// `_createOverlayEntry`'s `onItemSelected` callback. This is fine for checkboxes as their
// state is independent.

// For Submenus:
// - Opening: _AppMenubarDropdownItem calls onSubmenuOpenRequested -> _AppMenubarDropdown._openSubmenu
// - Closing: _AppMenubarDropdown._closeActiveSubmenu
// - Item selection within submenu: Propagates up to the top-level onItemSelected.

// The GlobalKey usage for positioning overlays is standard.
// Using CupertinoPopupSurface is a good step towards removing Material.
// Ensure all interactive elements like GestureDetector are used correctly.
// MouseRegion for hover effects is also appropriate.
// FocusableActionDetector can be used for keyboard navigation if that's a future requirement.

// Final check on Material dependencies:
// - Icons: Replaced with CupertinoIcons or custom (e.g. for checkbox/radio).
// - InkWell: Replaced with GestureDetector + MouseRegion.
// - Material (widget): Replaced with Container, CupertinoPopupSurface.
// - Colors: Using AppColors or CupertinoColors.

// The example usage demonstrates how to build the menu structure and handle basic state.
// The radio button state management in the example itself (`_AppMenubarExampleState._updateRadioItems`)
// is a bit manual. The goal is for the AppMenubar component to handle this internally
// based on the `onRadioSelected` callback chain.

// The `AppMenubarItemModel.onTap` for radio items should still be callable for any additional
// actions the user wants to perform beyond just selection.
// The `item.isChecked` in `AppMenubarItemModel` is now crucial and must be updated by the menubar logic.
// The `AppMenubarMenuModel.items` was made non-final to allow these updates.
