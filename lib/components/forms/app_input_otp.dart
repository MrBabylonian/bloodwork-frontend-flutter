import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

// TODO: Implement AppInputOtpSeparator if needed based on design

class AppInputOtp extends StatefulWidget {
  const AppInputOtp({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.separatorIndices, // e.g. [2] for a separator after the 3rd digit
    this.separator,
    this.fieldWidth =
        48.0, // Approx h-10 w-10 from mock (w-10 is 2.5rem = 40px, h-10 is 40px. Adding padding/border)
    this.fieldHeight = 48.0,
    this.gap = AppDimensions.spacingS, // gap-2 from mock
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final List<int>? separatorIndices;
  final Widget? separator;
  final double fieldWidth;
  final double fieldHeight;
  final double gap;

  @override
  State<AppInputOtp> createState() => _AppInputOtpState();
}

class _AppInputOtpState extends State<AppInputOtp> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  late List<String> _inputValues;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _inputValues = List.filled(widget.length, '');

    for (int i = 0; i < widget.length; i++) {
      _controllers[i].addListener(() {
        final text = _controllers[i].text;
        if (text.isNotEmpty && _inputValues[i] != text) {
          _inputValues[i] = text;
          if (i < widget.length - 1) {
            FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
          } else {
            _focusNodes[i].unfocus(); // Last field
            _submit();
          }
        } else if (text.isEmpty && _inputValues[i].isNotEmpty) {
          // Handle backspace/delete from an already filled field
          _inputValues[i] = '';
        }
        _triggerOnChanged();
      });
    }
  }

  void _submit() {
    final otp = _inputValues.join();
    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  void _triggerOnChanged() {
    final otp = _inputValues.join();
    widget.onChanged?.call(otp);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          // If current field is empty and backspace is pressed,
          // clear previous field and move focus to it.
          _controllers[index - 1].clear();
          _inputValues[index - 1] = '';
          FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          _triggerOnChanged();
        } else if (_controllers[index].text.isNotEmpty) {
          // If current field is not empty, allow normal backspace behavior by controller listener
          // _controllers[index].clear(); // This will be handled by listener
          // _inputValues[index] = '';
        }
      }
    }
  }

  List<Widget> _buildFields() {
    final List<Widget> fields = [];
    for (int i = 0; i < widget.length; i++) {
      fields.add(
        AppInputOtpSlot(
          controller: _controllers[i],
          focusNode: _focusNodes[i],
          width: widget.fieldWidth,
          height: widget.fieldHeight,
          onKeyPressed: (KeyEvent event) => _onKeyPressed(i, event),
        ),
      );
      if (widget.separator != null &&
          widget.separatorIndices != null &&
          widget.separatorIndices!.contains(i) &&
          i < widget.length - 1) {
        fields.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.gap / 2),
            child: widget.separator,
          ),
        );
      } else if (i < widget.length - 1) {
        fields.add(SizedBox(width: widget.gap));
      }
    }
    return fields;
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: _buildFields());
  }
}

class AppInputOtpSlot extends StatefulWidget {
  const AppInputOtpSlot({
    super.key,
    required this.controller,
    required this.focusNode,
    this.width = 48.0,
    this.height = 48.0,
    this.onKeyPressed,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final double width;
  final double height;
  final ValueChanged<KeyEvent>? onKeyPressed;

  @override
  State<AppInputOtpSlot> createState() => _AppInputOtpSlotState();
}

class _AppInputOtpSlotState extends State<AppInputOtpSlot> {
  bool _isFocused = false;
  // bool _hasFakeCaret = false; // TODO: Implement fake caret if needed

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    // TODO: Add listener for controller to manage fake caret visibility
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Based on mock: "relative flex h-10 w-10 items-center justify-center border-y border-r border-input text-sm transition-all first:rounded-l-md first:border-l last:rounded-r-md"
    // isActive && "z-10 ring-2 ring-ring ring-offset-background"

    final defaultBorderColor = AppColors.borderGray; // border-input
    final focusedBorderColor =
        AppColors.primaryBlue; // ring-ring (using primary for focus ring)
    // final backgroundColor = AppColors.backgroundSecondary; // bg-background (or AppColors.backgroundWhite)
    final textColor =
        AppColors.foregroundDark; // text-sm (implies default text color)

    // Mimic ring-offset-background by having a slightly larger outer border or container
    // For simplicity, we'll use a double border effect when focused.

    BoxDecoration decoration = BoxDecoration(
      color: AppColors.backgroundWhite, // Or theme.scaffoldBackgroundColor
      border: Border.all(
        color: _isFocused ? focusedBorderColor : defaultBorderColor,
        width: _isFocused ? 1.5 : 1.0, // Thicker border for focus to mimic ring
      ),
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusSmall,
      ), // rounded-md (approx)
    );

    // The mock uses different border radii for first/last child.
    // This is harder to achieve dynamically in a Row unless AppInputOtp passes this info.
    // For now, uniform border radius.

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: decoration,
      child: KeyboardListener(
        // Listen for backspace
        focusNode: FocusNode(), // Dummy focus node for KeyboardListener
        onKeyEvent: widget.onKeyPressed,
        child: CupertinoTextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: textColor,
          ), // text-sm is 14px, bodySmall is 15px. Close enough.
          decoration: const BoxDecoration(), // Remove default Cupertino borders
          maxLength: 1,
          showCursor: true, // Show native cursor, mock has fake caret
          cursorColor: AppColors.primaryBlue,
          // To make it truly borderless inside and rely on container:
          padding: EdgeInsets.zero,
          onTap: () {
            // Select all text on tap to easily overwrite
            if (widget.controller.text.isNotEmpty) {
              widget.controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: widget.controller.text.length,
              );
            }
          },
        ),
      ),
    );
  }
}

// Optional: Define AppInputOtpSeparator if a specific widget is needed beyond a simple Text/Icon
// class AppInputOtpSeparator extends StatelessWidget {
//   const AppInputOtpSeparator({super.key, this.child});
//   final Widget? child;

//   @override
//   Widget build(BuildContext context) {
//     return child ?? const Icon(
//       CupertinoIcons.circle_fill,
//       size: AppDimensions.iconSizeSmall,
//       color: AppColors.mediumGray,
//     );
//   }
// }
