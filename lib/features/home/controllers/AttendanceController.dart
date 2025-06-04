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

  Rx<DateTime> minimumDate = DateTime.now().obs;
  Rx<DateTime> maximumDate = DateTime.now().obs;

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
    HomeController homeController,
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
        await homeController.fetchSubjects();
      },
    );
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
    // Clear any existing data
    attendanceChartData.clear();

    if (attendanceRecords.isEmpty) {
      return;
    }

    // Sort records by date
    final sortedRecords = List<AttendanceModel>.from(attendanceRecords);
    sortedRecords.sort((a, b) {
      if (a.dateInMillis == null || b.dateInMillis == null) return 0;
      return int.parse(a.dateInMillis!).compareTo(int.parse(b.dateInMillis!));
    });

    // Track running totals for percentage calculation
    int attendedCount = 0;
    List<ChartData> chartPoints = [];

    // Process each record chronologically
    for (int i = 0; i < sortedRecords.length; i++) {
      final record = sortedRecords[i];
      if (record.dateInMillis == null) continue;

      // Increment attended count if present
      if (record.status == 'Present') {
        attendedCount++;
      }

      // Calculate current percentage
      double percentage = (attendedCount / (i + 1)) * 100;

      // Create date point (just use the actual record date)
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(record.dateInMillis!),
      );

      // Add data point
      chartPoints.add(ChartData(date, percentage));

      // For debugging
      print(
        'Added chart point: ${date.toString()}, ${percentage.toStringAsFixed(1)}',
      );
    }

    // Set the chart data directly from actual records, without interpolation
    attendanceChartData.value = chartPoints;

    // Set min/max dates for chart bounds
    if (sortedRecords.isNotEmpty) {
      minimumDate.value = DateTime.fromMillisecondsSinceEpoch(
        int.parse(sortedRecords.first.dateInMillis!),
      );
      maximumDate.value = DateTime.fromMillisecondsSinceEpoch(
        int.parse(sortedRecords.last.dateInMillis!),
      );

      print('Chart date range: ${minimumDate.value} to ${maximumDate.value}');
    }
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

  // Delete an attendance record
  Future<bool> deleteAttendance(
    AttendanceModel attendance,
    BuildContext context,
  ) async {
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

          await fetchAttendanceRecords(attendance.subject!);
          if (context.mounted) {
            context.pop();
          }
          print('Attendance record deleted successfully');
          success = true;
        },
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: ${e.toString()}';
      print('Exception while deleting attendance record: $e');
    }

    return success;
  }
}
