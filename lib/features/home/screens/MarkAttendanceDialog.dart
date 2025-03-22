import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shakti/core/models/ScheduleModel.dart';
import 'package:shakti/core/models/SubjectModel.dart';
import 'package:shakti/features/home/controllers/HomeController.dart';

class MarkAttendanceDialog extends StatefulWidget {
  final SubjectModel subject;

  const MarkAttendanceDialog({super.key, required this.subject});

  @override
  State<MarkAttendanceDialog> createState() => _MarkAttendanceDialogState();
}

class _MarkAttendanceDialogState extends State<MarkAttendanceDialog> {
  final HomeController _homeController = Get.find<HomeController>();
  ScheduleModel? selectedSchedule;
  List<ScheduleModel> subjectSchedules = [];
  bool isPresent = true; // Default to Present

  // Properties for date selection
  DateTime? selectedDate;
  List<DateTime> availableDates = [];

  @override
  void initState() {
    super.initState();
    // Filter schedules for this subject by comparing subjectName
    subjectSchedules =
        _homeController.schedules
            .where(
              (schedule) =>
                  schedule.subject?.subjectName == widget.subject.subjectName,
            )
            .toList();
  }

  // Generate available dates based on the selected schedule
  void _generateAvailableDates() {
    availableDates = [];
    selectedDate = null;

    if (selectedSchedule == null) return;

    try {
      // Get the reference date from the schedule
      final referenceDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(selectedSchedule!.startTimeInMillis!),
      );

      // Get the weekday of the reference date (1-7, Monday-Sunday)
      final referenceWeekday = referenceDate.weekday;

      // Generate dates for the past month and upcoming month that match the weekday
      final today = DateTime.now();
      final oneMonthAgo = today.subtract(const Duration(days: 30));
      final oneMonthAhead = today.add(const Duration(days: 30));

      // Start from one month ago and find all matching weekdays up to one month ahead
      DateTime current = oneMonthAgo;
      while (current.isBefore(oneMonthAhead)) {
        if (current.weekday == referenceWeekday) {
          availableDates.add(
            DateTime(current.year, current.month, current.day),
          );
        }
        current = current.add(const Duration(days: 1));
      }

      // Set today as the default selected date if it's available
      final todayDate = DateTime(today.year, today.month, today.day);
      if (availableDates.any((date) => _isSameDay(date, todayDate))) {
        selectedDate = todayDate;
      } else {
        // Otherwise, find the closest date to today
        availableDates.sort((a, b) {
          final diffA =
              (a.millisecondsSinceEpoch - today.millisecondsSinceEpoch).abs();
          final diffB =
              (b.millisecondsSinceEpoch - today.millisecondsSinceEpoch).abs();
          return diffA.compareTo(diffB);
        });

        if (availableDates.isNotEmpty) {
          selectedDate = availableDates.first;
        }
      }
    } catch (e) {
      // Handle any parsing errors
      print('Error generating dates: $e');
    }
  }

  // Helper to check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Format date with weekday
  String _formatDateString(DateTime date) {
    // Get day with suffix (1st, 2nd, 3rd, etc.)
    String dayWithSuffix = _getDayWithSuffix(date.day);

    // Get month name
    List<String> months = [
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
    String monthName = months[date.month - 1];

    // Get weekday name
    List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    // Note: In Dart, weekday is 1-based (Monday=1, Sunday=7)
    String weekdayName = weekdays[date.weekday - 1];

    return "$dayWithSuffix $monthName, $weekdayName";
  }

  // Helper method to get day with appropriate suffix
  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return "${day}th";
    }

    switch (day % 10) {
      case 1:
        return "${day}st";
      case 2:
        return "${day}nd";
      case 3:
        return "${day}rd";
      default:
        return "${day}th";
    }
  }

  // Show date picker dialog
  Future<void> _showDatePicker() async {
    if (availableDates.isEmpty) return;

    // Determine first and last selectable date
    final firstDate = availableDates.reduce((a, b) => a.isBefore(b) ? a : b);
    final lastDate = availableDates.reduce((a, b) => a.isAfter(b) ? a : b);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? availableDates.first,
      firstDate: firstDate,
      lastDate: lastDate,
      // Only allow selecting from available dates
      selectableDayPredicate: (DateTime day) {
        return availableDates.any((date) => _isSameDay(date, day));
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Customize theme if needed
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mark Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a schedule and date to mark attendance',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),

            // Label for schedule dropdown
            Text(
              'Schedule',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Dropdown for schedule selection
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() {
                  // Refresh subject schedules when the schedules list changes
                  subjectSchedules =
                      _homeController.schedules
                          .where(
                            (schedule) =>
                                schedule.subject?.subjectName ==
                                widget.subject.subjectName,
                          )
                          .toList();

                  return DropdownButton<ScheduleModel>(
                    isExpanded: true,
                    value: selectedSchedule,
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Select a schedule',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onChanged: (ScheduleModel? newValue) {
                      setState(() {
                        selectedSchedule = newValue;
                        // Generate available dates when a schedule is selected
                        _generateAvailableDates();
                      });
                    },
                    items:
                        subjectSchedules.map<DropdownMenuItem<ScheduleModel>>((
                          ScheduleModel schedule,
                        ) {
                          // Format the date and time for display
                          String displayText = _formatScheduleDisplay(schedule);

                          return DropdownMenuItem<ScheduleModel>(
                            value: schedule,
                            child: Text(displayText),
                          );
                        }).toList(),
                  );
                }),
              ),
            ),

            // Only show date picker if a schedule is selected
            if (selectedSchedule != null) ...[
              const SizedBox(height: 20),

              // Label for date selection
              Text(
                'Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Date picker field
              InkWell(
                onTap: _showDatePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate != null
                              ? _formatDateString(selectedDate!)
                              : 'Select a date',
                          style: TextStyle(
                            color:
                                selectedDate != null
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),

              if (selectedDate != null &&
                  _isSameDay(selectedDate!, DateTime.now())) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '(Today)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 24),

            // Attendance Status Selection
            Row(
              children: [
                Text(
                  'Status:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  'Absent',
                  style: TextStyle(
                    fontWeight: !isPresent ? FontWeight.bold : null,
                    fontSize: 14,
                    color:
                        isPresent
                            ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.4)
                            : Theme.of(context).colorScheme.primary,
                  ),
                ),
                Switch(
                  value: isPresent,
                  onChanged: (value) {
                    setState(() {
                      isPresent = value;
                    });
                  },
                ),
                Text(
                  'Present',
                  style: TextStyle(
                    fontWeight: isPresent ? FontWeight.bold : null,
                    fontSize: 14,
                    color:
                        !isPresent
                            ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.4)
                            : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),

            // Action buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed:
                      selectedSchedule == null || selectedDate == null
                          ? null
                          : () {
                            // Create a copy of the schedule with the selected date
                            final adjustedSchedule =
                                _createScheduleWithSelectedDate(
                                  selectedSchedule!,
                                  selectedDate!,
                                );

                            // Return both the schedule and attendance status
                            context.pop({
                              'schedule': adjustedSchedule,
                              'status': isPresent ? 'Present' : 'Absent',
                              'selectedDate': selectedDate,
                            });
                          },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    elevation: 0,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isPresent ? 'Mark Present' : 'Mark Absent'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Create a new schedule with the selected date while preserving time
  ScheduleModel _createScheduleWithSelectedDate(
    ScheduleModel schedule,
    DateTime selectedDate,
  ) {
    try {
      // Get the original start and end times
      final originalStart = DateTime.fromMillisecondsSinceEpoch(
        int.parse(schedule.startTimeInMillis!),
      );
      final originalEnd = DateTime.fromMillisecondsSinceEpoch(
        int.parse(schedule.endTimeInMillis!),
      );

      // Create new DateTime objects with the selected date but original times
      final newStartDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        originalStart.hour,
        originalStart.minute,
      );

      final newEndDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        originalEnd.hour,
        originalEnd.minute,
      );

      // Create a copy of the schedule with updated timestamps
      return schedule.copyWith(
        startTimeInMillis: newStartDateTime.millisecondsSinceEpoch.toString(),
        endTimeInMillis: newEndDateTime.millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      print('Error adjusting schedule date: $e');
      return schedule; // Return original schedule if there's an error
    }
  }

  // Helper method to format schedule display
  String _formatScheduleDisplay(ScheduleModel schedule) {
    try {
      final startDateTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(schedule.startTimeInMillis!),
      );

      final endDateTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(schedule.endTimeInMillis!),
      );

      // For recurring schedules, show the day name instead of just "Weekly"
      if (schedule.canRepeat == true && schedule.repeatRule != null) {
        final startTimeStr = _formatTimeString(startDateTime);
        final endTimeStr = _formatTimeString(endDateTime);

        if (schedule.repeatRule == 'Weekly') {
          // Get day name
          final dayNames = [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ];
          final dayName = dayNames[startDateTime.weekday - 1]; // weekday is 1-7

          return "$dayName at $startTimeStr - $endTimeStr";
        } else if (schedule.repeatRule == 'Monthly') {
          // For monthly, show the day of the month
          final dayOfMonth = startDateTime.day;
          String daySuffix;
          if (dayOfMonth == 1 || dayOfMonth == 21 || dayOfMonth == 31) {
            daySuffix = 'st';
          } else if (dayOfMonth == 2 || dayOfMonth == 22) {
            daySuffix = 'nd';
          } else if (dayOfMonth == 3 || dayOfMonth == 23) {
            daySuffix = 'rd';
          } else {
            daySuffix = 'th';
          }

          return "Monthly on $dayOfMonth$daySuffix at $startTimeStr - $endTimeStr";
        } else {
          // For yearly or other recurrence patterns
          final monthNames = [
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
          final monthName =
              monthNames[startDateTime.month - 1]; // month is 1-12

          return "$monthName ${startDateTime.day} at $startTimeStr - $endTimeStr";
        }
      } else {
        // For non-recurring schedules, show the date
        final dateStr =
            "${startDateTime.day}/${startDateTime.month}/${startDateTime.year}";
        final startTimeStr = _formatTimeString(startDateTime);
        final endTimeStr = _formatTimeString(endDateTime);

        return "$dateStr: $startTimeStr - $endTimeStr";
      }
    } catch (e) {
      return "Schedule information unavailable";
    }
  }

  // Reuse the time formatting function
  String _formatTimeString(DateTime dateTime) {
    final hour =
        dateTime.hour > 12
            ? dateTime.hour - 12
            : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
