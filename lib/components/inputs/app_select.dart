import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// A select option that can be displayed in the dropdown.
class AppSelectOption<T> {
  /// Creates a select option.
  const AppSelectOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.disabled = false,
    this.searchText,
  });

  /// The value of the option.
  final T value;

  /// The display label for the option.
  final String label;

  /// Optional subtitle text.
  final String? subtitle;

  /// Optional icon to display.
  final IconData? icon;

  /// Whether this option is disabled.
  final bool disabled;

  /// Custom search text (if different from label).
  final String? searchText;

  /// Text used for searching.
  String get effectiveSearchText => searchText ?? label;
}

/// An enhanced select component with search functionality.
///
/// providing an advanced dropdown with search, filtering, and custom rendering.
class AppSelect<T> extends StatefulWidget {
  /// Creates an enhanced select component.
  const AppSelect({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.placeholder = 'Select an option...',
    this.searchPlaceholder = 'Search options...',
    this.emptyText = 'No options found',
    this.searchable = true,
    this.disabled = false,
    this.width,
    this.maxHeight = 300,
    this.optionBuilder,
    this.selectedOptionBuilder,
  });

  /// List of available options.
  final List<AppSelectOption<T>> options;

  /// Currently selected value.
  final T? value;

  /// Called when the selection changes.
  final ValueChanged<T?>? onChanged;

  /// Placeholder text when no option is selected.
  final String placeholder;

  /// Placeholder text for the search field.
  final String searchPlaceholder;

  /// Text to show when no options match the search.
  final String emptyText;

  /// Whether the select supports searching.
  final bool searchable;

  /// Whether the select is disabled.
  final bool disabled;

  /// Fixed width for the select.
  final double? width;

  /// Maximum height for the dropdown.
  final double maxHeight;

  /// Custom builder for options in the dropdown.
  final Widget Function(AppSelectOption<T> option, bool isSelected)?
  optionBuilder;

  /// Custom builder for the selected option display.
  final Widget Function(AppSelectOption<T> option)? selectedOptionBuilder;

  @override
  State<AppSelect<T>> createState() => _AppSelectState<T>();
}

class _AppSelectState<T> extends State<AppSelect<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<AppSelectOption<T>> _filteredOptions = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(AppSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options != oldWidget.options) {
      _filterOptions(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterOptions(_searchController.text);
  }

  void _filterOptions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = widget.options;
      } else {
        _filteredOptions =
            widget.options
                .where(
                  (option) => option.effectiveSearchText.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  void _toggleDropdown() {
    if (widget.disabled) return;

    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });

    if (_isDropdownOpen) {
      _searchController.clear();
      _filterOptions('');
      if (widget.searchable) {
        _searchFocusNode.requestFocus();
      }
    }
  }

  void _selectOption(AppSelectOption<T> option) {
    widget.onChanged?.call(option.value);
    setState(() {
      _isDropdownOpen = false;
    });
  }

  AppSelectOption<T>? get _selectedOption {
    return widget.options.cast<AppSelectOption<T>?>().firstWhere(
      (option) => option?.value == widget.value,
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select trigger
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              decoration: BoxDecoration(
                color:
                    widget.disabled
                        ? AppColors.lightGray.withValues(alpha: 0.5)
                        : AppColors.lightGray,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color:
                      _isDropdownOpen
                          ? AppColors.primaryBlue
                          : AppColors.borderGray,
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildSelectedDisplay()),
                  Icon(
                    _isDropdownOpen
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    size: 16,
                    color:
                        widget.disabled
                            ? AppColors.mediumGray
                            : AppColors.foregroundDark,
                  ),
                ],
              ),
            ),
          ),

          // Dropdown
          if (_isDropdownOpen) ...[
            const SizedBox(height: 4),
            Container(
              constraints: BoxConstraints(maxHeight: widget.maxHeight),
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
                children: [
                  // Search field
                  if (widget.searchable) ...[
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                      child: CupertinoTextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        placeholder: widget.searchPlaceholder,
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            CupertinoIcons.search,
                            size: 16,
                            color: AppColors.mediumGray,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSmall,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Container(height: 1, color: AppColors.borderGray),
                  ],

                  // Options list
                  Flexible(
                    child:
                        _filteredOptions.isEmpty
                            ? Padding(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingMedium,
                              ),
                              child: Text(
                                widget.emptyText,
                                style: const TextStyle(
                                  color: AppColors.mediumGray,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredOptions.length,
                              itemBuilder: (context, index) {
                                final option = _filteredOptions[index];
                                final isSelected = option.value == widget.value;

                                return _buildOption(option, isSelected);
                              },
                            ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedDisplay() {
    final selectedOption = _selectedOption;

    if (selectedOption != null) {
      if (widget.selectedOptionBuilder != null) {
        return widget.selectedOptionBuilder!(selectedOption);
      }

      return Row(
        children: [
          if (selectedOption.icon != null) ...[
            Icon(
              selectedOption.icon,
              size: 16,
              color: AppColors.foregroundDark,
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
          ],
          Expanded(
            child: Text(
              selectedOption.label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.foregroundDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.placeholder,
      style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
    );
  }

  Widget _buildOption(AppSelectOption<T> option, bool isSelected) {
    if (widget.optionBuilder != null) {
      return GestureDetector(
        onTap: option.disabled ? null : () => _selectOption(option),
        child: widget.optionBuilder!(option, isSelected),
      );
    }

    return GestureDetector(
      onTap: option.disabled ? null : () => _selectOption(option),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : null,
        ),
        child: Row(
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 16,
                color:
                    option.disabled
                        ? AppColors.mediumGray
                        : (isSelected
                            ? AppColors.primaryBlue
                            : AppColors.foregroundDark),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          option.disabled
                              ? AppColors.mediumGray
                              : (isSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.foregroundDark),
                    ),
                  ),
                  if (option.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark,
                size: 16,
                color: AppColors.primaryBlue,
              ),
          ],
        ),
      ),
    );
  }
}
