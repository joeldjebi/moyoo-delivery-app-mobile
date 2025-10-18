import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class CalendarFilterWidget extends StatefulWidget {
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const CalendarFilterWidget({
    super.key,
    this.selectedStartDate,
    this.selectedEndDate,
    required this.onDateRangeSelected,
  });

  @override
  State<CalendarFilterWidget> createState() => _CalendarFilterWidgetState();
}

class _CalendarFilterWidgetState extends State<CalendarFilterWidget> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startDate = widget.selectedStartDate;
    _endDate = widget.selectedEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Row(
              children: [
                Text(
                  'Sélectionner la période',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Date range display
          if (_startDate != null || _endDate != null)
            Container(
              margin: const EdgeInsets.all(AppDimensions.spacingM),
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range, color: AppColors.primary, size: 16),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      _getDateRangeText(),
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearDates,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Calendar
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
              ),
              child: _buildCalendar(),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearDates,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingS,
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                    ),
                    child: Text(
                      'Effacer',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyDateRange,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingS,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Appliquer',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        // Month navigation
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                    );
                  });
                },
                icon: Icon(Icons.chevron_left, color: AppColors.primary),
              ),
              Text(
                _getMonthYearText(_focusedDay),
                style: GoogleFonts.montserrat(
                  fontSize: AppDimensions.fontSizeM,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month + 1,
                    );
                  });
                },
                icon: Icon(Icons.chevron_right, color: AppColors.primary),
              ),
            ],
          ),
        ),

        // Calendar grid
        Expanded(child: _buildCalendarGrid()),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    return Column(
      children: [
        // Weekday headers
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
          child: Row(
            children:
                ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) {
                  return Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeXS,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),

        // Calendar days
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 42, // 6 weeks * 7 days
            itemBuilder: (context, index) {
              final dayNumber = index - firstDayWeekday + 2;
              final isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
              final day =
                  isCurrentMonth
                      ? DateTime(_focusedDay.year, _focusedDay.month, dayNumber)
                      : null;

              if (!isCurrentMonth) {
                return const SizedBox.shrink();
              }

              final isSelected = _isDateSelected(day!);
              final isInRange = _isDateInRange(day);
              final isToday = _isToday(day);

              return GestureDetector(
                onTap: () => _onDateTap(day),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary
                            : isInRange
                            ? AppColors.primary.withOpacity(0.2)
                            : isToday
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        isToday
                            ? Border.all(color: AppColors.primary, width: 1)
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      dayNumber.toString(),
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeXS,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected
                                ? Colors.white
                                : isToday
                                ? AppColors.primary
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getMonthYearText(DateTime date) {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      return 'Du ${_formatDate(_startDate!)} au ${_formatDate(_endDate!)}';
    } else if (_startDate != null) {
      return 'À partir du ${_formatDate(_startDate!)}';
    } else if (_endDate != null) {
      return 'Jusqu\'au ${_formatDate(_endDate!)}';
    }
    return 'Aucune période sélectionnée';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool _isDateSelected(DateTime date) {
    return (_startDate != null && _isSameDay(date, _startDate!)) ||
        (_endDate != null && _isSameDay(date, _endDate!));
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
        date.isBefore(_endDate!.add(const Duration(days: 1)));
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return _isSameDay(date, today);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (_startDate == null) {
        _startDate = date;
      } else if (_endDate == null) {
        if (date.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
      } else {
        _startDate = date;
        _endDate = null;
      }
    });
  }

  void _clearDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyDateRange() {
    widget.onDateRangeSelected(_startDate, _endDate);
    Navigator.of(context).pop();
  }
}
