import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

// Define a simple command item structure for now
class CommandPaletteItem {
  final String id;
  final String title;
  final IconData? icon;
  final VoidCallback onSelected;
  final String? group; // Optional group name

  CommandPaletteItem({
    required this.id,
    required this.title,
    this.icon,
    required this.onSelected,
    this.group,
  });
}

class AppCommandPalette extends StatefulWidget {
  final List<CommandPaletteItem> items;
  final bool initiallyVisible;
  final ValueChanged<String>?
  onSearchChanged; // Callback for search text changes
  final String? searchPlaceholder;

  const AppCommandPalette({
    super.key,
    required this.items,
    this.initiallyVisible = false,
    this.onSearchChanged,
    this.searchPlaceholder = 'Type a command or search...',
  });

  @override
  State<AppCommandPalette> createState() => _AppCommandPaletteState();
}

class _AppCommandPaletteState extends State<AppCommandPalette> {
  late bool _isVisible;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isVisible = widget.initiallyVisible;
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
      if (widget.onSearchChanged != null) {
        widget.onSearchChanged!(_searchText);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
      if (_isVisible) {
        // Request focus when palette becomes visible
        // Needs a slight delay to ensure the widget is in the tree
        Future.delayed(const Duration(milliseconds: 50), () {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  List<CommandPaletteItem> get _filteredItems {
    if (_searchText.isEmpty) {
      return widget.items;
    }
    return widget.items
        .where(
          (item) =>
              item.title.toLowerCase().contains(_searchText.toLowerCase()),
        )
        .toList();
  }

  Map<String?, List<CommandPaletteItem>> get _groupedItems {
    final Map<String?, List<CommandPaletteItem>> grouped = {};
    for (var item in _filteredItems) {
      grouped.putIfAbsent(item.group, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    // This is a placeholder for how the palette might be triggered.
    // In a real app, this could be a button in an AppBar or a global keyboard listener.
    // For now, we'll include a button to toggle it for demonstration.
    return Stack(
      children: [
        // Example trigger button (can be removed or replaced)
        Positioned(
          top: 10,
          right: 10,
          child: CupertinoButton(
            onPressed: _toggleVisibility,
            child: const Icon(CupertinoIcons.search_circle_fill, size: 30),
          ),
        ),
        if (_isVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleVisibility, // Dismiss on tap outside
              child: Container(
                color: AppColors.shadowColor.withValues(alpha: 0.5),
                child: Center(
                  child: GestureDetector(
                    onTap:
                        () {}, // Prevent dismissal when tapping inside the dialog
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLarge,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [_buildCommandInput(), _buildCommandList()],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCommandInput() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: CupertinoTextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        placeholder: widget.searchPlaceholder,
        prefix: const Padding(
          padding: EdgeInsets.only(left: AppDimensions.spacingS),
          child: Icon(
            CupertinoIcons.search,
            color: AppColors.mediumGray,
            size: AppDimensions.iconSizeMedium,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingS,
          vertical: AppDimensions.spacingM, // Increased vertical padding
        ),
        style: AppTextStyles.body,
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        clearButtonMode: OverlayVisibilityMode.editing,
      ),
    );
  }

  Widget _buildCommandList() {
    final grouped = _groupedItems;
    final List<Widget> listChildren = [];

    if (_filteredItems.isEmpty && _searchText.isNotEmpty) {
      listChildren.add(
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Center(
            child: Text(
              'No results found for "$_searchText"',
              style: AppTextStyles.body.copyWith(color: AppColors.mediumGray),
            ),
          ),
        ),
      );
    } else if (widget.items.isEmpty) {
      listChildren.add(
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Center(
            child: Text(
              'No commands available.',
              style: AppTextStyles.body.copyWith(color: AppColors.mediumGray),
            ),
          ),
        ),
      );
    } else {
      // Iterate through groups (null group for items without a group comes first if desired)
      // Or sort groups by name, or have a predefined order.
      // For now, simple iteration.
      grouped.forEach((groupName, itemsInGroup) {
        if (groupName != null) {
          listChildren.add(
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              child: Text(
                groupName,
                style: AppTextStyles.footnote.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
            ),
          );
        }
        for (var item in itemsInGroup) {
          listChildren.add(
            CupertinoButton(
              onPressed: () {
                item.onSelected();
                _toggleVisibility(); // Close palette after selection
              },
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      color: AppColors.primaryBlue,
                      size: AppDimensions.iconSizeMedium,
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                  ],
                  Expanded(
                    child: Text(
                      item.title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.foregroundDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          // Add a separator if not the last item in the group or overall
          if (item != itemsInGroup.last || groupName != grouped.keys.last) {
            listChildren.add(
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                ),
                color: AppColors.borderGray.withValues(alpha: 0.5),
              ),
            );
          }
        }
      });
    }

    return Flexible(
      // Use Flexible for the list part if it's inside a Column
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height *
              0.5, // Max 50% of screen height
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listChildren,
          ),
        ),
      ),
    );
  }
}

// Example Usage (can be placed in a screen/page widget):
/*
class MyHomePage extends StatelessWidget {
  final List<CommandPaletteItem> _commandItems = [
    CommandPaletteItem(id: '1', title: 'Open Settings', icon: CupertinoIcons.settings, onSelected: () => print('Settings selected')),
    CommandPaletteItem(id: '2', title: 'New File', icon: CupertinoIcons.doc_plaintext, onSelected: () => print('New File selected'), group: 'File'),
    CommandPaletteItem(id: '3', title: 'Save File', icon: CupertinoIcons.floppy_disk, onSelected: () => print('Save File selected'), group: 'File'),
    CommandPaletteItem(id: '4', title: 'Print Document', icon: CupertinoIcons.printer, onSelected: () => print('Print selected'), group: 'File'),
    CommandPaletteItem(id: '5', title: 'User Profile', icon: CupertinoIcons.person, onSelected: () => print('Profile selected'), group: 'User'),
    CommandPaletteItem(id: '6', title: 'Logout', icon: CupertinoIcons.square_arrow_right, onSelected: () => print('Logout selected'), group: 'User'),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Command Palette Demo'),
      ),
      child: Stack( // Stack is needed if AppCommandPalette is to overlay content
        children: [
          Center(child: Text('Main Content')),
          // AppCommandPalette is a StatefulWidget, so it manages its own visibility trigger internally for this demo
          AppCommandPalette(items: _commandItems),
        ],
      ),
    );
  }
}
*/
