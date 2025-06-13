import 'package:flutter/cupertino.dart';
import '../display/badge.dart';

/// Enum for different status types, influencing icon and color.
enum StatusType { success, warning, error, info, pending, neutral }

/// A badge specifically designed to convey status with an icon and label.
///
/// This component uses the `AppBadge` internally and provides predefined
/// icons and color schemes for different status types.
class StatusBadge extends StatelessWidget {
  /// Creates a status badge with the specified properties.
  const StatusBadge({super.key, required this.label, required this.statusType});

  /// The text label to display.
  final String label;

  /// The type of status to represent.
  final StatusType statusType;

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    AppBadgeVariant badgeVariant;

    switch (statusType) {
      case StatusType.success:
        iconData = CupertinoIcons.checkmark_circle_fill;
        badgeVariant = AppBadgeVariant.success;
        break;
      case StatusType.warning:
        iconData = CupertinoIcons.exclamationmark_triangle_fill;
        badgeVariant = AppBadgeVariant.warning;
        break;
      case StatusType.error:
        iconData = CupertinoIcons.xmark_circle_fill;
        badgeVariant = AppBadgeVariant.destructive;
        break;
      case StatusType.info:
        iconData = CupertinoIcons.info_circle_fill;
        badgeVariant = AppBadgeVariant.info;
        break;
      case StatusType.pending:
        iconData = CupertinoIcons.time_solid;
        badgeVariant = AppBadgeVariant.secondary;
        break;
      case StatusType.neutral:
        iconData = CupertinoIcons.circle_fill;
        badgeVariant = AppBadgeVariant.secondary;
        break;
    }

    return AppBadge(label: label, variant: badgeVariant, icon: iconData);
  }
}
