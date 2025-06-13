import 'package:flutter/cupertino.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

// Helper functions (file-level)
String _getMonthName(int month) {
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  if (month < 1 || month > 12) {
    return ''; // Should not happen with DateTime.month
  }

  return monthNames[month - 1];
}

int _customGetDaysInMonth(int year, int month) {
  if (month == DateTime.february) {
    final bool isLeapYear =
        (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
    return isLeapYear ? 29 : 28;
  }
  // Note: Dart's DateTime.month is 1-indexed (January is 1).
  // This list is 0-indexed for months.
  const List<int> daysInMonthList = <int>[
    31,
    -1,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31,
  ];
  return daysInMonthList[month - 1];
}

bool _customIsSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class AppCalendar extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppCalendar({
    super.key,
    this.initialDate,
    this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late DateTime _currentDisplayedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _currentDisplayedMonth =
        widget.initialDate ?? _selectedDate ?? DateTime.now();
    // Ensure _currentDisplayedMonth is not before firstDate or after lastDate if they are provided
    if (widget.firstDate != null &&
        _currentDisplayedMonth.isBefore(
          DateTime(widget.firstDate!.year, widget.firstDate!.month, 1),
        )) {
      _currentDisplayedMonth = DateTime(
        widget.firstDate!.year,
        widget.firstDate!.month,
        1,
      );
    }
    if (widget.lastDate != null &&
        _currentDisplayedMonth.isAfter(
          DateTime(widget.lastDate!.year, widget.lastDate!.month, 1),
        )) {
      _currentDisplayedMonth = DateTime(
        widget.lastDate!.year,
        widget.lastDate!.month,
        1,
      );
    }
  }

  @override
  void didUpdateWidget(covariant AppCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      setState(() {
        _selectedDate = widget.selectedDate;
        // Optionally, update currentDisplayedMonth if selectedDate changes significantly
        // For now, we keep the current month view unless explicitly navigated
      });
    }
    if (widget.initialDate != oldWidget.initialDate &&
        widget.initialDate != null) {
      _currentDisplayedMonth = widget.initialDate!;
      // Ensure _currentDisplayedMonth is not before firstDate or after lastDate
      if (widget.firstDate != null &&
          _currentDisplayedMonth.isBefore(
            DateTime(widget.firstDate!.year, widget.firstDate!.month, 1),
          )) {
        _currentDisplayedMonth = DateTime(
          widget.firstDate!.year,
          widget.firstDate!.month,
          1,
        );
      }
      if (widget.lastDate != null &&
          _currentDisplayedMonth.isAfter(
            DateTime(widget.lastDate!.year, widget.lastDate!.month, 1),
          )) {
        _currentDisplayedMonth = DateTime(
          widget.lastDate!.year,
          widget.lastDate!.month,
          1,
        );
      }
    }
  }

  void _changeMonth(int monthIncrement) {
    setState(() {
      DateTime newMonth = DateTime(
        _currentDisplayedMonth.year,
        _currentDisplayedMonth.month + monthIncrement,
        1,
      );

      // Check against firstDate
      if (widget.firstDate != null) {
        final firstMonth = DateTime(
          widget.firstDate!.year,
          widget.firstDate!.month,
          1,
        );
        if (newMonth.isBefore(firstMonth)) {
          newMonth = firstMonth;
        }
      }

      // Check against lastDate
      if (widget.lastDate != null) {
        final lastMonth = DateTime(
          widget.lastDate!.year,
          widget.lastDate!.month,
          1,
        );
        // If newMonth is after the month of lastDate
        if (newMonth.year > lastMonth.year ||
            (newMonth.year == lastMonth.year &&
                newMonth.month > lastMonth.month)) {
          newMonth = lastMonth;
        }
      }
      _currentDisplayedMonth = newMonth;
    });
  }

  void _handleDateTap(DateTime date) {
    // Prevent selecting dates outside the allowed range
    if (widget.firstDate != null && date.isBefore(widget.firstDate!)) return;
    if (widget.lastDate != null && date.isAfter(widget.lastDate!)) return;

    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions
            .radiusLarge, // Changed from spacingM to radiusLarge (12px for p-3)
      ),
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ), // Corrected: borderRadiusMedium -> radiusMedium
        border: Border.all(
          color: AppColors.borderGray,
          width: 1,
        ), // Corrected: grey300 -> borderGray
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppDimensions.spacingS),
          _buildWeekdaysHeader(context),
          const SizedBox(height: AppDimensions.spacingS),
          _buildDaysGrid(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Determine if previous/next buttons should be enabled
    bool canGoBack = true;
    if (widget.firstDate != null) {
      final firstCalendarMonth = DateTime(
        widget.firstDate!.year,
        widget.firstDate!.month,
        1,
      );
      if (!_currentDisplayedMonth.isAfter(firstCalendarMonth)) {
        canGoBack = false;
      }
    }

    bool canGoForward = true;
    if (widget.lastDate != null) {
      final lastCalendarMonth = DateTime(
        widget.lastDate!.year,
        widget.lastDate!.month,
        1,
      );
      if (!DateTime(
        _currentDisplayedMonth.year,
        _currentDisplayedMonth.month + 1,
        1,
      ).isBefore(
        DateTime(lastCalendarMonth.year, lastCalendarMonth.month + 1, 1),
      )) {
        canGoForward = false;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: canGoBack ? () => _changeMonth(-1) : null,
          child: Icon(
            CupertinoIcons.chevron_left,
            color: canGoBack ? AppColors.primaryBlue : AppColors.mediumGray,
            size: AppDimensions.iconSizeSmall, // Added icon size
          ),
        ),
        Text(
          "${_getMonthName(_currentDisplayedMonth.month)} ${_currentDisplayedMonth.year}",
          style: AppTextStyles.formLabel.copyWith(
            color: AppColors.foregroundDark,
          ), // Changed from title3 to formLabel
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: canGoForward ? () => _changeMonth(1) : null,
          child: Icon(
            CupertinoIcons.chevron_right,
            color: canGoForward ? AppColors.primaryBlue : AppColors.mediumGray,
            size: AppDimensions.iconSizeSmall, // Added icon size
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdaysHeader(BuildContext context) {
    // Using a fixed list of weekday abbreviations
    const dayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S']; // Standard Mon-Sun

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        return Center(
          child: Text(
            dayHeaders[index],
            style: AppTextStyles.footnote.copyWith(
              color: AppColors.mediumGray,
            ), // Corrected: caption(context) -> footnote, textSecondary -> mediumGray
          ),
        );
      },
    );
  }

  Widget _buildDaysGrid(BuildContext context) {
    final daysInMonth = _customGetDaysInMonth(
      _currentDisplayedMonth.year,
      _currentDisplayedMonth.month,
    );
    final firstDayOfMonth = DateTime(
      _currentDisplayedMonth.year,
      _currentDisplayedMonth.month,
      1,
    );
    // Weekday is 1 (Monday) to 7 (Sunday). We want 0 (Monday) to 6 (Sunday) for offset.
    int startingDayOffset = firstDayOfMonth.weekday - 1;

    List<DateTime?> dayTiles = List.generate(
      startingDayOffset,
      (index) => null,
    ); // Add nulls for empty leading days

    for (int i = 0; i < daysInMonth; i++) {
      dayTiles.add(
        DateTime(
          _currentDisplayedMonth.year,
          _currentDisplayedMonth.month,
          i + 1,
        ),
      );
    }

    // Add trailing empty cells to make the grid complete (total cells multiple of 7)
    int remainingCells = (7 - (dayTiles.length % 7)) % 7;
    for (int i = 0; i < remainingCells; i++) {
      dayTiles.add(null);
    }

    // Calculate approximate cell size for h-9 w-9 (36px) effect
    // This is more of a guideline as GridView handles actual sizing.
    // We ensure the container inside tries to be square.
    // final double approximateCellSize = AppDimensions.spacingXl; // 32px, spacingXxl is 48px. Let's aim for something around 36px.
    // AppDimensions.buttonHeightSmall (32px) or make a new const if 36px is strict.
    // For now, let GridView distribute space and use padding/alignment.

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: AppDimensions.spacingXs,
        crossAxisSpacing: AppDimensions.spacingXs,
        // childAspectRatio: 1, // To make cells square if desired, might affect overall layout
      ),
      itemCount: dayTiles.length,
      itemBuilder: (context, index) {
        final DateTime? tileDate = dayTiles[index];
        if (tileDate == null) {
          return Container(); // Empty cell
        }

        final bool isSelected =
            _selectedDate != null && _customIsSameDay(tileDate, _selectedDate);
        final bool isToday = _customIsSameDay(tileDate, DateTime.now());

        bool isDisabled = false;
        if (widget.firstDate != null && tileDate.isBefore(widget.firstDate!)) {
          isDisabled = true;
        }
        if (widget.lastDate != null && tileDate.isAfter(widget.lastDate!)) {
          isDisabled = true;
        }

        BoxDecoration decoration;
        TextStyle textStyle = AppTextStyles.body.copyWith(
          color: AppColors.foregroundDark,
        ); // Default text color

        if (isSelected && !isDisabled) {
          decoration = BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          );
          textStyle = AppTextStyles.body.copyWith(color: CupertinoColors.white);
        } else if (isToday && !isDisabled) {
          // Changed from border to background for "today" state
          decoration = BoxDecoration(
            color: AppColors.primaryBlue.withValues(
              alpha: 0.15,
            ), // Subtle background for today
            shape: BoxShape.circle,
          );
          textStyle = AppTextStyles.body.copyWith(
            color: AppColors.primaryBlue,
          ); // Text color for today
        } else if (isDisabled) {
          decoration = const BoxDecoration();
          textStyle = AppTextStyles.body.copyWith(
            color: AppColors.mediumGray.withValues(alpha: 0.5),
          );
        } else {
          decoration = const BoxDecoration();
          // textStyle is already set to default
        }

        return GestureDetector(
          onTap: isDisabled ? null : () => _handleDateTap(tileDate),
          child: Container(
            alignment: Alignment.center,
            decoration: decoration,
            // To encourage a square-like shape for h-9 w-9, ensure the container can expand
            // and the text is centered. GridView's crossAxisCount handles distribution.
            // If a fixed size is strictly needed, width/height properties could be used here,
            // but might conflict with GridView's flexible sizing.
            // For example: height: approximateCellSize, width: approximateCellSize,
            child: Text('${tileDate.day}', style: textStyle),
          ),
        );
      },
    );
  }
}
