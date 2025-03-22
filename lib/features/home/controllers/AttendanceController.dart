import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shakti/core/models/AttendanceModel.dart';
import 'package:shakti/core/models/ScheduleModel.dart';
import 'package:shakti/core/models/SubjectModel.dart';
import 'package:shakti/features/home/controllers/HomeController.dart';
import 'package:shakti/features/home/repositories/AttendanceRepository.dart';

class ChartData {
  final DateTime date;
  final double percentage;

  ChartData(this.date, this.percentage);
}

class AttendanceController extends GetxController {
  final AttendanceRepository _attendanceRepository =
      Get.find<AttendanceRepository>();
  final HomeController _homeController = Get.find<HomeController>();

  // Observables
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // Attendance records
  RxList<AttendanceModel> attendanceRecords = <AttendanceModel>[].obs;

  // Chart data
  RxList<ChartData> attendanceChartData = <ChartData>[].obs;

  // Current period attendance status
  RxString currentAttendanceStatus = 'Not Marked'.obs;

  // Statistics
  RxInt totalClasses = 0.obs;
  RxInt attendedClasses = 0.obs;
  RxDouble attendancePercentage = 0.0.obs;

  // Mark attendance for a specific schedule
  Future<void> markAttendance(
    ScheduleModel schedule,
    String status,
    DateTime selectedDate,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';

    // Create an attendance model
    final attendance = AttendanceModel(
      subject: schedule.subject,
      schedule: schedule,
      status: status,
      dateInMillis: selectedDate.millisecondsSinceEpoch.toString(),
    );

    // Call the repository to mark attendance
    final result = await _attendanceRepository.markAttendance(attendance);

    result.fold(
      (failure) {
        errorMessage.value = failure;
        print(failure);
      },
      (_) async {
        await fetchAttendanceRecords(attendance.subject!);
      },
    );

    isLoading.value = false;
  }

  // Fetch all attendance records
  Future<void> fetchAttendanceRecords(SubjectModel subject) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _attendanceRepository.getAttendanceRecords(subject);

    result.fold(
      (failure) {
        errorMessage.value = failure;
        print(failure);
      },
      (records) {
        attendanceRecords.value = records;
        checkCurrentAttendanceStatus();
        updateAttendanceStatistics();
        generateChartData();
      },
    );

    isLoading.value = false;
  }

  // Generate chart data for attendance percentage over time
  void generateChartData() {
    if (attendanceRecords.isEmpty) {
      attendanceChartData.clear();
      return;
    }

    // Sort records by date
    final sortedRecords = List<AttendanceModel>.from(attendanceRecords);
    sortedRecords.sort((a, b) {
      if (a.dateInMillis == null || b.dateInMillis == null) return 0;
      return int.parse(a.dateInMillis!).compareTo(int.parse(b.dateInMillis!));
    });

    // Create map to track percentage on each date
    final Map<String, ChartData> chartDataMap = {};

    int cumulativeTotal = 0;
    int cumulativePresent = 0;

    // Get all dates for overall percentage calculation
    for (var record in sortedRecords) {
      if (record.dateInMillis == null) continue;

      // Get the date without time
      final dateMillis = int.parse(record.dateInMillis!);
      final date = DateTime.fromMillisecondsSinceEpoch(dateMillis);
      final dateKey = '${date.year}-${date.month}-${date.day}';

      // Increment counters
      cumulativeTotal++;
      if (record.status == 'Present') {
        cumulativePresent++;
      }

      // Calculate percentage
      final percentage = (cumulativePresent / cumulativeTotal) * 100;

      // Update chart data for this date
      chartDataMap[dateKey] = ChartData(
        DateTime(date.year, date.month, date.day),
        percentage,
      );
    }

    // Calculate the date for 1 week ago
    final today = DateTime.now();
    final lastWeek = today.subtract(Duration(days: 7));

    // Fill in missing dates between last week and today
    DateTime currentDate = DateTime(
      lastWeek.year,
      lastWeek.month,
      lastWeek.day,
    );
    final endDate = DateTime(today.year, today.month, today.day);

    List<ChartData> lastWeekData = [];

    // If we have no data at all, just show a flat line at 0%
    if (chartDataMap.isEmpty) {
      while (currentDate.isBefore(endDate) ||
          currentDate.isAtSameMomentAs(endDate)) {
        lastWeekData.add(
          ChartData(
            DateTime(currentDate.year, currentDate.month, currentDate.day),
            0.0,
          ),
        );
        currentDate = currentDate.add(Duration(days: 1));
      }
      attendanceChartData.value = lastWeekData;
      return;
    }

    // Find the percentage value for lastWeek date or earlier
    double startPercentage = 0.0;
    List<String> sortedKeys = chartDataMap.keys.toList()..sort();
    for (var key in sortedKeys) {
      DateTime dateFromKey = DateTime(
        int.parse(key.split('-')[0]),
        int.parse(key.split('-')[1]),
        int.parse(key.split('-')[2]),
      );

      if (dateFromKey.isBefore(lastWeek) ||
          dateFromKey.isAtSameMomentAs(lastWeek)) {
        startPercentage = chartDataMap[key]!.percentage;
      }
    }

    // Create data for each day in the last week
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final dateKey =
          '${currentDate.year}-${currentDate.month}-${currentDate.day}';

      if (chartDataMap.containsKey(dateKey)) {
        // Use actual data if we have it
        lastWeekData.add(chartDataMap[dateKey]!);
      } else {
        // Use the last known percentage before this date
        double previousPercentage = startPercentage;

        for (var key in sortedKeys) {
          DateTime dateFromKey = DateTime(
            int.parse(key.split('-')[0]),
            int.parse(key.split('-')[1]),
            int.parse(key.split('-')[2]),
          );

          if (dateFromKey.isBefore(currentDate) &&
              chartDataMap[key]!.percentage != previousPercentage) {
            previousPercentage = chartDataMap[key]!.percentage;
          }
        }

        lastWeekData.add(
          ChartData(
            DateTime(currentDate.year, currentDate.month, currentDate.day),
            previousPercentage,
          ),
        );
      }

      currentDate = currentDate.add(Duration(days: 1));
    }

    // Sort by date to ensure chronological order
    lastWeekData.sort((a, b) => a.date.compareTo(b.date));

    // Update chart data
    attendanceChartData.value = lastWeekData;
  }

  // Check if attendance is already marked for the current active schedule
  void checkCurrentAttendanceStatus() {
    // Get the active schedule from HomeController
    ScheduleModel? activeSchedule = _homeController.activeSchedule.value;

    if (activeSchedule == null) {
      currentAttendanceStatus.value = 'No Active Class';
      return;
    }

    // Get today's date without time
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStart = today.millisecondsSinceEpoch.toString();
    final todayEnd =
        DateTime(
          now.year,
          now.month,
          now.day,
          23,
          59,
          59,
        ).millisecondsSinceEpoch.toString();

    // Check if there's an attendance record for this schedule today
    final existingRecord = attendanceRecords.firstWhere((record) {
      try {
        // Match the subject and schedule
        bool matchesSubjectAndSchedule =
            record.subject?.subjectName ==
                activeSchedule.subject?.subjectName &&
            record.schedule?.startTimeInMillis ==
                activeSchedule.startTimeInMillis;

        // Check if it's today
        bool isToday =
            record.dateInMillis != null &&
            int.parse(record.dateInMillis!) >= int.parse(todayStart) &&
            int.parse(record.dateInMillis!) <= int.parse(todayEnd);

        return matchesSubjectAndSchedule && isToday;
      } catch (e) {
        return false;
      }
    }, orElse: () => AttendanceModel(status: 'Not Marked'));

    currentAttendanceStatus.value = existingRecord.status ?? 'Not Marked';
  }

  // Update attendance statistics
  void updateAttendanceStatistics() {
    int total = attendanceRecords.length;
    int attended =
        attendanceRecords.where((record) => record.status == 'Present').length;

    totalClasses.value = total;
    attendedClasses.value = attended;

    if (total > 0) {
      attendancePercentage.value = (attended / total) * 100;
    } else {
      attendancePercentage.value = 0.0;
    }
  }

  // Get formatted attendance percentage
  String getFormattedAttendancePercentage() {
    return attendancePercentage.value.toStringAsFixed(1) + '%';
  }

  // Get attendance status color based on percentage
  String getAttendanceStatusColor() {
    if (attendancePercentage.value >= 75) {
      return 'green';
    } else if (attendancePercentage.value >= 60) {
      return 'orange';
    } else {
      return 'red';
    }
  }

  // Get attendance status text based on percentage
  String getAttendanceStatusText() {
    if (attendancePercentage.value >= 75) {
      return 'Good';
    } else if (attendancePercentage.value >= 60) {
      return 'Average';
    } else {
      return 'Poor';
    }
  }

  // Helper method to format a timestamp string into a readable date
  String _formatDate(String? millisStr) {
    if (millisStr == null) return 'Unknown date';

    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(millisStr),
      );
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Delete an attendance record
  Future<bool> deleteAttendance(AttendanceModel attendance) async {
    isLoading.value = true;
    errorMessage.value = '';
    bool success = false;

    try {
      // Call the repository to delete the attendance record
      final result = await _attendanceRepository.deleteAttendanceRecord(
        attendance,
      );

      result.fold(
        (failure) {
          // Handle failure
          errorMessage.value = failure;
          isLoading.value = false;
          print('Error deleting attendance record: $failure');
        },
        (_) async {
          // Success - remove from the local list
          attendanceRecords.removeWhere(
            (record) =>
                record.subject?.subjectName ==
                    attendance.subject?.subjectName &&
                record.schedule?.startTimeInMillis ==
                    attendance.schedule?.startTimeInMillis &&
                record.dateInMillis == attendance.dateInMillis,
          );

          fetchAttendanceRecords(attendance.subject!);

          print('Attendance record deleted successfully');
          success = true;
          isLoading.value = false;
        },
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: ${e.toString()}';
      print('Exception while deleting attendance record: $e');
    }

    return success;
  }

  // Show confirmation dialog before deleting attendance
  Future<void> confirmAndDeleteAttendance(
    BuildContext context,
    AttendanceModel attendance,
  ) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Attendance Record'),
          content: Text(
            'Are you sure you want to delete this attendance record for ${attendance.subject?.subjectName} on ${_formatDate(attendance.dateInMillis)}?',
          ),
          actions: [
            TextButton(onPressed: () => context.pop(), child: Text('Cancel')),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await deleteAttendance(attendance);

                if (success) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Attendance record deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage.value),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
