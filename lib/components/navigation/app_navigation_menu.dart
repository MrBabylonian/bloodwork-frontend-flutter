import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// A navigation menu item that can contain sub-items.
class AppNavigationMenuItem {
  /// Creates a navigation menu item.
  const AppNavigationMenuItem({
    required this.id,
    required this.label,
    this.icon,
    this.onTap,
    this.children = const [],
    this.disabled = false,
  });

  /// Unique identifier for the menu item.
  final String id;

  /// The label to display for the menu item.
  final String label;

  /// Optional icon to display.
  final IconData? icon;

  /// Callback when the item is tapped.
  final VoidCallback? onTap;

  /// Sub-menu items.
  final List<AppNavigationMenuItem> children;

  /// Whether this item is disabled.
  final bool disabled;

  /// Whether this item has children.
  bool get hasChildren => children.isNotEmpty;
}

/// A horizontal navigation menu component.
///
/// This component is equivalent to the navigation-menu.tsx from the React mock,
/// providing a clean horizontal navigation interface.
class AppNavigationMenu extends StatefulWidget {
  /// Creates a navigation menu.
  const AppNavigationMenu({
    super.key,
    required this.items,
    this.backgroundColor,
    this.height = 56.0,
    this.activeItemId,
    this.onItemSelected,
    this.showActiveIndicator = true,
  });

  /// The navigation menu items to display.
  final List<AppNavigationMenuItem> items;

  /// Background color of the navigation menu.
  final Color? backgroundColor;

  /// Height of the navigation menu.
  final double height;

  /// ID of the currently active item.
  final String? activeItemId;

  /// Called when an item is selected.
  final ValueChanged<String>? onItemSelected;

  /// Whether to show an active indicator.
  final bool showActiveIndicator;

  @override
  State<AppNavigationMenu> createState() => _AppNavigationMenuState();
}

class _AppNavigationMenuState extends State<AppNavigationMenu> {
  String? _hoveredItemId;
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.backgroundWhite,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderGray, width: 1.0),
        ),
      ),
      child: Row(
        children:
            widget.items.map((item) => _buildNavigationItem(item)).toList(),
      ),
    );
  }

  Widget _buildNavigationItem(AppNavigationMenuItem item) {
    final isActive = widget.activeItemId == item.id;
    final isHovered = _hoveredItemId == item.id;
    final key = _itemKeys.putIfAbsent(item.id, () => GlobalKey());

    return MouseRegion(
      onEnter: (_) => _setHoveredItem(item.id),
      onExit: (_) => _setHoveredItem(null),
      child: GestureDetector(
        key: key,
        onTap:
            item.disabled
                ? null
                : () {
                  if (item.hasChildren) {
                    _showSubmenu(item, key);
                  } else {
                    item.onTap?.call();
                    widget.onItemSelected?.call(item.id);
                  }
                },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          decoration: BoxDecoration(
            color:
                isHovered && !item.disabled
                    ? AppColors.lightGray.withValues(alpha: 0.5)
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: 20,
                      color: _getItemColor(item, isActive),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                  ],
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                      color: _getItemColor(item, isActive),
                    ),
                  ),
                  if (item.hasChildren) ...[
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Icon(
                      CupertinoIcons.chevron_down,
                      size: 16,
                      color: _getItemColor(item, isActive),
                    ),
                  ],
                ],
              ),

              // Active indicator
              if (widget.showActiveIndicator && isActive)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getItemColor(AppNavigationMenuItem item, bool isActive) {
    if (item.disabled) return AppColors.mediumGray;
    if (isActive) return AppColors.primaryBlue;
    return AppColors.foregroundDark;
  }

  void _setHoveredItem(String? itemId) {
    if (_hoveredItemId != itemId) {
      setState(() {
        _hoveredItemId = itemId;
      });
    }
  }

  void _showSubmenu(AppNavigationMenuItem item, GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);

    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.1),
      builder:
          (context) => _AppNavigationSubmenu(
            items: item.children,
            position: Offset(position.dx, position.dy + widget.height),
            onItemSelected: (itemId) {
              Navigator.of(context).pop();
              widget.onItemSelected?.call(itemId);
            },
          ),
    );
  }
}

class _AppNavigationSubmenu extends StatelessWidget {
  const _AppNavigationSubmenu({
    required this.items,
    required this.position,
    required this.onItemSelected,
  });

  final List<AppNavigationMenuItem> items;
  final Offset position;
  final ValueChanged<String> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Barrier to close submenu
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: const Color(0x00000000)),
          ),
        ),

        // Submenu
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.borderGray),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: items.map((item) => _buildSubmenuItem(item)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmenuItem(AppNavigationMenuItem item) {
    return GestureDetector(
      onTap:
          item.disabled
              ? null
              : () {
                item.onTap?.call();
                onItemSelected(item.id);
              },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 18,
                color:
                    item.disabled
                        ? AppColors.mediumGray
                        : AppColors.foregroundDark,
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
            ],
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      item.disabled
                          ? AppColors.mediumGray
                          : AppColors.foregroundDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
