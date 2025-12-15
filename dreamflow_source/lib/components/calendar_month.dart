import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:lentera/theme.dart';

enum MoodLevel { good, ok, low, none }

/// Minimalist monthly calendar with optional mood indicator dots and selected ring
class CalendarMonth extends StatelessWidget {
  final DateTime month; // any date within desired month
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onSelect;
  final Map<DateTime, MoodLevel> indicators; // normalized to date-only keys

  const CalendarMonth({
    super.key,
    required this.month,
    this.selectedDate,
    this.onSelect,
    this.indicators = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? kAppColorsLight;

    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Start on Monday (ISO 8601), compute leading blanks
    final startWeekday = (firstOfMonth.weekday % 7); // Mon=1..Sun=7 -> 1..0
    final leading = (startWeekday == 0) ? 6 : startWeekday - 1;
    final totalCells = leading + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        _buildWeekHeader(context),
        const SizedBox(height: 8),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: Column(
            children: List.generate(rows, (row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: List.generate(7, (col) {
                    final idx = row * 7 + col;
                    if (idx < leading || idx >= leading + daysInMonth) {
                      return _buildDayCell(context, null);
                    }
                    final day = idx - leading + 1;
                    final date = DateTime(month.year, month.month, day);
                    final isSelected = _isSameDate(date, selectedDate);
                    final mood = indicators[_truncate(date)] ?? MoodLevel.none;
                    return _buildDayCell(context, day,
                        date: date, isSelected: isSelected, mood: mood, colors: colors);
                  }),
                ),
              );
            }),
          ),
        )
      ],
    );
  }

  Widget _buildWeekHeader(BuildContext context) {
    final theme = Theme.of(context);
    final labels = ['S', 'S', 'R', 'K', 'J', 'S', 'M']; // Sen, Sel, Rab, Kam, Jum, Sab, Min (minimalist)
    // Reorder to Mon..Sun
    final reordered = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    return Row(
      children: List.generate(7, (i) {
        return Expanded(
          child: Center(
            child: Text(
              reordered[i],
              style: theme.textTheme.labelMedium?.withColor(
                theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    int? day, {
    DateTime? date,
    bool isSelected = false,
    MoodLevel mood = MoodLevel.none,
    AppColors? colors,
  }) {
    final theme = Theme.of(context);
    final appColors = colors ?? (theme.extension<AppColors>() ?? kAppColorsLight);
    final today = DateTime.now();
    final isToday = date != null && _isSameDate(date, today);
    final dotColor = switch (mood) {
      MoodLevel.good => appColors.goodDot,
      MoodLevel.ok => appColors.okDot,
      MoodLevel.low => appColors.lowDot,
      _ => Colors.transparent,
    };

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (date != null && onSelect != null)
            ? () {
                // Subtle haptic to feel responsive on mobile
                HapticFeedback.selectionClick();
                onSelect!(date);
              }
            : null,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          scale: isSelected ? 0.96 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? appColors.amber.withValues(alpha: 0.18)
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(color: appColors.amber, width: 2)
                  : (isToday
                      ? Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4))
                      : null),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day != null ? '$day' : '',
                  style: theme.textTheme.labelLarge?.semiBold.withColor(
                    theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static bool _isSameDate(DateTime a, DateTime? b) {
    if (b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime _truncate(DateTime d) => DateTime(d.year, d.month, d.day);
}
