import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// A tab item containing metadata about a tab.
class AppTab {
  /// Creates a tab.
  const AppTab({
    required this.id,
    required this.label,
    this.icon,
    this.disabled = false,
  });

  /// Unique identifier for the tab.
  final String id;

  /// The text label to display on the tab.
  final String label;

  /// Optional icon to display alongside the label.
  final IconData? icon;

  /// Whether this tab is disabled.
  final bool disabled;
}

/// A tabs widget providing tabbed navigation interface.
///
/// providing a clean tabbed interface for organizing content.
class AppTabs extends StatefulWidget {
  /// Creates a tabs widget.
  const AppTabs({
    super.key,
    required this.tabs,
    required this.children,
    this.initialTabId,
    this.onTabChanged,
    this.tabAlignment = Alignment.centerLeft,
    this.showDivider = true,
  });

  /// The list of tabs to display.
  final List<AppTab> tabs;

  /// The content widgets corresponding to each tab.
  /// Must have the same length as [tabs].
  final List<Widget> children;

  /// The initial tab to show. If null, shows the first tab.
  final String? initialTabId;

  /// Called when the active tab changes.
  final ValueChanged<String>? onTabChanged;

  /// How to align the tabs in the tab bar.
  final Alignment tabAlignment;

  /// Whether to show a divider below the tab bar.
  final bool showDivider;

  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> {
  late String _activeTabId;

  @override
  void initState() {
    super.initState();
    _activeTabId =
        widget.initialTabId ??
        (widget.tabs.isNotEmpty ? widget.tabs.first.id : '');
  }

  @override
  void didUpdateWidget(AppTabs oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the initial tab changed and current active tab is no longer valid
    if (widget.initialTabId != oldWidget.initialTabId &&
        widget.initialTabId != null) {
      _setActiveTab(widget.initialTabId!);
    }

    // Ensure active tab is still valid
    if (!widget.tabs.any((tab) => tab.id == _activeTabId)) {
      if (widget.tabs.isNotEmpty) {
        _setActiveTab(widget.tabs.first.id);
      }
    }
  }

  void _setActiveTab(String tabId) {
    if (_activeTabId != tabId) {
      setState(() {
        _activeTabId = tabId;
      });
      widget.onTabChanged?.call(tabId);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.tabs.length == widget.children.length,
      'Number of tabs must match number of children',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Bar
        _AppTabBar(
          tabs: widget.tabs,
          activeTabId: _activeTabId,
          onTabChanged: _setActiveTab,
          alignment: widget.tabAlignment,
          showDivider: widget.showDivider,
        ),

        // Tab Content
        Expanded(child: _getActiveContent()),
      ],
    );
  }

  Widget _getActiveContent() {
    final activeIndex = widget.tabs.indexWhere((tab) => tab.id == _activeTabId);

    if (activeIndex >= 0 && activeIndex < widget.children.length) {
      return widget.children[activeIndex];
    }

    return const SizedBox.shrink();
  }
}

class _AppTabBar extends StatelessWidget {
  const _AppTabBar({
    required this.tabs,
    required this.activeTabId,
    required this.onTabChanged,
    required this.alignment,
    required this.showDivider,
  });

  final List<AppTab> tabs;
  final String activeTabId;
  final ValueChanged<String> onTabChanged;
  final Alignment alignment;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
          ),
          child: Row(
            mainAxisAlignment: _getMainAxisAlignment(),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      tabs
                          .map(
                            (tab) => _AppTabButton(
                              tab: tab,
                              isActive: tab.id == activeTabId,
                              onTap:
                                  tab.disabled
                                      ? null
                                      : () => onTabChanged(tab.id),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),

        if (showDivider) ...[
          const SizedBox(height: AppDimensions.paddingMedium),
          Container(height: 1, color: AppColors.borderGray),
        ],
      ],
    );
  }

  MainAxisAlignment _getMainAxisAlignment() {
    if (alignment == Alignment.center || alignment == Alignment.topCenter) {
      return MainAxisAlignment.center;
    } else if (alignment == Alignment.centerRight ||
        alignment == Alignment.topRight) {
      return MainAxisAlignment.end;
    }
    return MainAxisAlignment.start;
  }
}

class _AppTabButton extends StatelessWidget {
  const _AppTabButton({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final AppTab tab;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.backgroundWhite : const Color(0x00000000),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.icon != null) ...[
              Icon(tab.icon, size: 16, color: _getTextColor()),
              const SizedBox(width: AppDimensions.paddingSmall),
            ],
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: _getTextColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTextColor() {
    if (tab.disabled) return AppColors.mediumGray;
    return isActive ? AppColors.foregroundDark : AppColors.mediumGray;
  }
}
