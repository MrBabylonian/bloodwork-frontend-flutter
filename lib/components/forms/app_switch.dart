import 'package:flutter/material.dart';
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
    // Material Switch ensures consistency with the app-wide Material design.
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? AppColors.primaryBlue,
      activeTrackColor: (activeColor ?? AppColors.primaryBlue).withOpacity(
        0.54,
      ),
      inactiveTrackColor: trackColor ?? AppColors.lightGray,
      inactiveThumbColor: thumbColor,
    );
  }
}
