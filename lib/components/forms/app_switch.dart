import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? trackColor; // For the off state
  final Color? thumbColor; // Usually defaults based on platform

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.trackColor,
    this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    // Using CupertinoSwitch for an iOS-style switch, which is common in Flutter.
    // Material Switch can also be used if a Material look is preferred.
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: activeColor ?? AppColors.primaryBlue,
      inactiveTrackColor: trackColor ?? AppColors.lightGray,
      thumbColor:
          thumbColor, // CupertinoSwitch handles default thumb color well
    );
  }
}
