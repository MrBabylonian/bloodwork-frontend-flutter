import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// State of the sidebar (expanded or collapsed).
enum AppSidebarState { expanded, collapsed }

/// A sidebar navigation item.
class AppSidebarItem {
  /// Creates a sidebar item.
  const AppSidebarItem({
    required this.id,
    required this.label,
    this.icon,
    this.iconCollapsed,
    this.onTap,
    this.children = const [],
    this.disabled = false,
    this.badge,
  });

  /// Unique identifier for the item.
  final String id;

  /// The label to display.
  final String label;

  /// Icon to show when expanded.
  final IconData? icon;

  /// Icon to show when collapsed (defaults to [icon]).
  final IconData? iconCollapsed;

  /// Callback when the item is tapped.
  final VoidCallback? onTap;

  /// Child items for nested navigation.
  final List<AppSidebarItem> children;

  /// Whether this item is disabled.
  final bool disabled;

  /// Optional badge to display.
  final Widget? badge;

  /// Whether this item has children.
  bool get hasChildren => children.isNotEmpty;
}

/// A customizable sidebar navigation component.
///
/// providing a comprehensive sidebar system with expansion/collapse functionality.
class AppSidebar extends StatefulWidget {
  /// Creates a sidebar.
  const AppSidebar({
    super.key,
    required this.items,
    this.state = AppSidebarState.expanded,
    this.onStateChanged,
    this.width = 280.0,
    this.collapsedWidth = 60.0,
    this.backgroundColor,
    this.selectedItemId,
    this.onItemSelected,
    this.header,
    this.footer,
    this.showToggleButton = true,
  });

  /// The navigation items to display.
  final List<AppSidebarItem> items;

  /// The current state of the sidebar.
  final AppSidebarState state;

  /// Called when the sidebar state changes.
  final ValueChanged<AppSidebarState>? onStateChanged;

  /// Width when expanded.
  final double width;

  /// Width when collapsed.
  final double collapsedWidth;

  /// Background color of the sidebar.
  final Color? backgroundColor;

  /// ID of the currently selected item.
  final String? selectedItemId;

  /// Called when an item is selected.
  final ValueChanged<String>? onItemSelected;

  /// Optional header widget.
  final Widget? header;

  /// Optional footer widget.
  final Widget? footer;

  /// Whether to show the toggle button.
  final bool showToggleButton;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late AppSidebarState _currentState;
  final Set<String> _expandedItems = <String>{};

  @override
  void initState() {
    super.initState();
    _currentState = widget.state;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: widget.collapsedWidth,
      end: widget.width,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (_currentState == AppSidebarState.expanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _updateState(widget.state);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleState() {
    final newState =
        _currentState == AppSidebarState.expanded
            ? AppSidebarState.collapsed
            : AppSidebarState.expanded;
    _updateState(newState);
    widget.onStateChanged?.call(newState);
  }

  void _updateState(AppSidebarState newState) {
    setState(() {
      _currentState = newState;
    });

    if (newState == AppSidebarState.expanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _toggleItemExpansion(String itemId) {
    setState(() {
      if (_expandedItems.contains(itemId)) {
        _expandedItems.remove(itemId);
      } else {
        _expandedItems.add(itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        final isExpanded = _currentState == AppSidebarState.expanded;

        return Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.backgroundWhite,
            border: const Border(
              right: BorderSide(color: AppColors.borderGray, width: 1.0),
            ),
          ),
          child: Column(
            children: [
              // Header
              if (widget.header != null) widget.header!,

              // Toggle button
              if (widget.showToggleButton) _buildToggleButton(isExpanded),

              // Navigation items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingSmall,
                  ),
                  children:
                      widget.items
                          .map(
                            (item) => _buildNavigationItem(item, isExpanded, 0),
                          )
                          .toList(),
                ),
              ),

              // Footer
              if (widget.footer != null) widget.footer!,
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(bool isExpanded) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _toggleState,
            child: Icon(
              isExpanded
                  ? CupertinoIcons.sidebar_left
                  : CupertinoIcons.sidebar_right,
              color: AppColors.mediumGray,
              size: 20,
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: AppDimensions.paddingMedium),
            const Expanded(
              child: Text(
                'Collapse',
                style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationItem(AppSidebarItem item, bool isExpanded, int depth) {
    final isSelected = widget.selectedItemId == item.id;
    final isItemExpanded = _expandedItems.contains(item.id);
    final hasChildren = item.hasChildren;

    return Column(
      children: [
        // Main item
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
            vertical: 2,
          ).copyWith(left: AppDimensions.paddingSmall + (depth * 16.0)),
          child: GestureDetector(
            onTap:
                item.disabled
                    ? null
                    : () {
                      if (hasChildren && isExpanded) {
                        _toggleItemExpansion(item.id);
                      } else if (item.onTap != null) {
                        item.onTap!();
                        widget.onItemSelected?.call(item.id);
                      }
                    },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.primaryBlue.withValues(alpha: 0.1)
                        : null,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Row(
                children: [
                  // Icon
                  if (item.icon != null)
                    Icon(
                      isExpanded
                          ? item.icon
                          : (item.iconCollapsed ?? item.icon),
                      color:
                          isSelected
                              ? AppColors.primaryBlue
                              : (item.disabled
                                  ? AppColors.mediumGray
                                  : AppColors.foregroundDark),
                      size: 20,
                    ),

                  if (isExpanded) ...[
                    const SizedBox(width: AppDimensions.paddingMedium),

                    // Label
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? AppColors.primaryBlue
                                  : (item.disabled
                                      ? AppColors.mediumGray
                                      : AppColors.foregroundDark),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Badge
                    if (item.badge != null) ...[
                      const SizedBox(width: AppDimensions.paddingSmall),
                      item.badge!,
                    ],

                    // Expand/collapse indicator
                    if (hasChildren) ...[
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Icon(
                        isItemExpanded
                            ? CupertinoIcons.chevron_down
                            : CupertinoIcons.chevron_right,
                        color: AppColors.mediumGray,
                        size: 16,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),

        // Children (if expanded)
        if (hasChildren && isExpanded && isItemExpanded)
          ...item.children.map(
            (child) => _buildNavigationItem(child, isExpanded, depth + 1),
          ),
      ],
    );
  }
}
