import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../feedback/app_popover.dart';

/// Generic date picker form field following the app design language.
/// Opens a Material calendar on web/desktop while keeping Cupertino styling in-field.
class AppDatePickerField extends StatefulWidget {
  final String label;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateChanged,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<AppDatePickerField> createState() => _AppDatePickerFieldState();
}

class _AppDatePickerFieldState extends State<AppDatePickerField> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.selectedDate;
  }

  Future<void> _pickDate() async {
    // determine rect
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final rect = offset & renderBox.size;

    AppPopover.show(
      context: context,
      trigger: const SizedBox.shrink(),
      anchorRect: rect,
      position: AppPopoverPosition.bottomLeft,
      content: _CalendarPopup(
        initialDate: _currentDate,
        minDate: widget.firstDate ?? DateTime(1900),
        maxDate: widget.lastDate ?? DateTime.now(),
        onSelected: (picked) {
          setState(() => _currentDate = picked);
          widget.onDateChanged(picked);
        },
      ),
      width: 320,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.calendar,
              size: 16,
              color: AppColors.mediumGray,
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(_formatDate(_currentDate), style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal calendar picker
class _CalendarPopup extends StatefulWidget {
  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;
  final ValueChanged<DateTime> onSelected;

  const _CalendarPopup({
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
    required this.onSelected,
  });

  @override
  State<_CalendarPopup> createState() => _CalendarPopupState();
}

class _CalendarPopupState extends State<_CalendarPopup> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  void _prevMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  List<Widget> _buildDayHeaders() {
    const labels = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
    return labels
        .map(
          (l) => Expanded(
            child: Center(child: Text(l, style: AppTextStyles.caption)),
          ),
        )
        .toList();
  }

  List<Widget> _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );
    final weekdayOfFirst =
        firstDayOfMonth.weekday % 7; // monday=1 convert 0 index
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;

    final totalSlots = weekdayOfFirst + daysInMonth;
    final rows = (totalSlots / 7).ceil();
    final List<Widget> rowsWidgets = [];
    int dayCounter = 1;

    for (int r = 0; r < rows; r++) {
      rowsWidgets.add(
        Row(
          children: [
            for (int c = 0; c < 7; c++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: _buildDayCell(
                    r,
                    c,
                    weekdayOfFirst,
                    daysInMonth,
                    dayCounter,
                  ),
                ),
              ),
          ],
        ),
      );
    }
    return rowsWidgets;
  }

  Widget _buildDayCell(int r, int c, int offset, int maxDay, int dayCounter) {
    final index = r * 7 + c;
    if (index < offset || index - offset + 1 > maxDay) {
      return const SizedBox.shrink();
    }
    final day = index - offset + 1;
    final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
    final bool disabled =
        date.isBefore(widget.minDate) || date.isAfter(widget.maxDate);
    final bool isSelected =
        date.year == widget.initialDate.year &&
        date.month == widget.initialDate.month &&
        date.day == widget.initialDate.day;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      color: isSelected ? AppColors.primaryBlue : null,
      disabledColor: AppColors.backgroundWhite.withAlpha(0),
      minSize: 28,
      onPressed:
          disabled
              ? null
              : () {
                widget.onSelected(date);
                Navigator.of(context).pop();
              },
      child: Text(
        '$day',
        style: TextStyle(
          color:
              disabled
                  ? AppColors.textDisabled
                  : (isSelected ? AppColors.white : AppColors.foregroundDark),
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      color: AppColors.backgroundWhite,
      child: Column(
        children: [
          // Header with month navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.chevron_left),
                  onPressed: _prevMonth,
                ),
                Text(
                  '${_visibleMonth.month.toString().padLeft(2, '0')}/${_visibleMonth.year}',
                  style: AppTextStyles.body,
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          Row(children: _buildDayHeaders()),
          const SizedBox(height: 4),
          ..._buildCalendarGrid(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
