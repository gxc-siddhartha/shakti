import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shakti/core/models/AttendanceModel.dart';
import 'package:shakti/core/models/SubjectModel.dart';
import 'package:shakti/features/home/controllers/AttendanceController.dart';

class AllattendancesScreen extends StatefulWidget {
  final SubjectModel subject;
  const AllattendancesScreen({super.key, required this.subject});

  @override
  State<AllattendancesScreen> createState() => _AllattendancesscresScreen();
}

class _AllattendancesscresScreen extends State<AllattendancesScreen> {
  final AttendanceController _attendanceController = Get.find();

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

  String _formatTimeFromSchedule(scheduleModel) {
    if (scheduleModel == null ||
        scheduleModel.startTimeInMillis == null ||
        scheduleModel.endTimeInMillis == null) {
      return "Time not available";
    }

    try {
      final startDateTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(scheduleModel.startTimeInMillis),
      );

      final endDateTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(scheduleModel.endTimeInMillis),
      );

      final startTime = _formatTimeString(startDateTime);
      final endTime = _formatTimeString(endDateTime);

      return "$startTime - $endTime";
    } catch (e) {
      return "Time format error";
    }
  }

  String _formatTimeString(DateTime dateTime) {
    final hour =
        dateTime.hour > 12
            ? dateTime.hour - 12
            : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text("All Records")),
      body: ListView.builder(
        itemCount: _attendanceController.attendanceRecords.length,
        itemBuilder: (context, index) {
          final attendanceRecords = _attendanceController.attendanceRecords;

          if (attendanceRecords.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No attendance records found"),
            );
          }

          // Sort records by date (most recent first)
          final sortedRecords = List<AttendanceModel>.from(attendanceRecords);
          sortedRecords.sort((a, b) {
            if (a.dateInMillis == null || b.dateInMillis == null) return 0;
            return int.parse(
              b.dateInMillis!,
            ).compareTo(int.parse(a.dateInMillis!)); // Reverse order
          });
          final record = sortedRecords[index];

          // Handle null dateInMillis safely
          if (record.dateInMillis == null) {
            return const SizedBox.shrink();
          }

          DateTime date;
          try {
            date = DateTime.fromMillisecondsSinceEpoch(
              int.parse(record.dateInMillis!),
            );
          } catch (e) {
            // Handle parsing error gracefully
            return const SizedBox.shrink();
          }

          return ClipRRect(
            child: Slidable(
              // key: ValueKey(record.dateInMillis),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext dcontext) {
                          return AlertDialog(
                            title: Text('Delete Attendance Record'),
                            content: Text(
                              'Are you sure you want to continue with this action?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => dcontext.pop(),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  dcontext.pop();
                                  await _attendanceController.deleteAttendance(
                                    record,
                                    context,
                                  );
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).colorScheme.error,
                    label: 'Remove',
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 0.3,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 72),
                  child: ListTile(
                    style: ListTileStyle.drawer,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(
                      _formatDateString(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      _formatTimeFromSchedule(record.schedule),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing:
                        record.status != null
                            ? Chip(
                              label: Text(
                                record.status!,
                                style: TextStyle(fontSize: 14),
                              ),
                              backgroundColor:
                                  record.status == "Present"
                                      ? Colors.green.withOpacity(0.2)
                                      : Theme.of(
                                        context,
                                      ).colorScheme.error.withOpacity(0.1),
                              labelStyle: TextStyle(
                                color:
                                    record.status == "Present"
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.error,
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
