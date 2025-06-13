import 'package:flutter/cupertino.dart';
import './app_toggle_button.dart'; // Assuming AppToggleButton is in the same directory
import '../../theme/app_dimensions.dart';

class AppToggleGroup extends StatefulWidget {
  final List<Widget> children;
  final AppToggleButtonVariant variant;
  final AppToggleButtonSize size;
  final bool allowMultipleSelection;
  final List<bool> initialSelection; // For multiple selection
  final int? initialSelectedIndex; // For single selection
  final Function(List<bool> selectedStates)?
  onMultiSelectionChanged; // Returns a list of bools
  final Function(int? selectedIndex)?
  onSingleSelectionChanged; // Returns the index of the selected item, or null if none

  const AppToggleGroup({
    super.key,
    required this.children,
    this.variant = AppToggleButtonVariant.defaultStyle,
    this.size = AppToggleButtonSize.defaultSize,
    this.allowMultipleSelection = false,
    this.initialSelection = const [],
    this.initialSelectedIndex,
    this.onMultiSelectionChanged,
    this.onSingleSelectionChanged,
  }) : assert(
         (allowMultipleSelection &&
                 initialSelection.length == children.length) ||
             (!allowMultipleSelection),
         "InitialSelection length must match children length for multiple selection.",
       );

  @override
  AppToggleGroupState createState() => AppToggleGroupState();
}

class AppToggleGroupState extends State<AppToggleGroup> {
  late List<bool> _selectedStates;
  int? _currentSelectedIndex;

  @override
  void initState() {
    super.initState();
    if (widget.allowMultipleSelection) {
      _selectedStates = List<bool>.from(widget.initialSelection);
      if (_selectedStates.isEmpty && widget.children.isNotEmpty) {
        _selectedStates = List<bool>.filled(widget.children.length, false);
      }
    } else {
      _currentSelectedIndex = widget.initialSelectedIndex;
      _selectedStates = List<bool>.generate(
        widget.children.length,
        (i) => i == _currentSelectedIndex,
      );
    }
  }

  void _handleToggle(int index) {
    setState(() {
      if (widget.allowMultipleSelection) {
        _selectedStates[index] = !_selectedStates[index];
        widget.onMultiSelectionChanged?.call(List<bool>.from(_selectedStates));
      } else {
        if (_currentSelectedIndex == index) {
          // Optional: allow deselecting the current item in a single-select group
          // _currentSelectedIndex = null;
        } else {
          _currentSelectedIndex = index;
        }
        for (int i = 0; i < _selectedStates.length; i++) {
          _selectedStates[i] = (i == _currentSelectedIndex);
        }
        widget.onSingleSelectionChanged?.call(_currentSelectedIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mock: "flex items-center justify-center gap-1"
    return Wrap(
      spacing: AppDimensions.spacingXxs, // gap-1 (approx 4px)
      runSpacing: AppDimensions.spacingXxs,
      alignment: WrapAlignment.center,
      children: List<Widget>.generate(widget.children.length, (index) {
        final childContent = widget.children[index];
        // It's assumed children are appropriate for a ToggleButton (e.g., Icon, Text)
        // We wrap them in our AppToggleButton styling logic.
        return AppToggleButton(
          isOn: _selectedStates[index],
          onPressed: (bool isOn) => _handleToggle(index),
          variant: widget.variant,
          size: widget.size,
          child: childContent,
        );
      }),
    );
  }
}
