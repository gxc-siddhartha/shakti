import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shakti/core/models/ScheduleModel.dart';
import 'package:shakti/core/models/SubjectModel.dart';
import 'package:shakti/core/models/UserModel.dart';
import 'package:shakti/core/services/NotificationService.dart';
import 'package:shakti/features/auth/controllers/AuthController.dart';
import 'package:shakti/features/home/controllers/AttendanceController.dart';
import 'package:shakti/features/home/repositories/HomeRepository.dart';

class HomeController extends GetxController {
  final HomeRepository _homeRepository = Get.find<HomeRepository>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  // Observables
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  RxString overallPercentage = '0'.obs;
  RxInt todaySchedulesCount = 0.obs;
  RxInt remainingTodaySchedulesCount = 0.obs;

  RxList<SubjectModel> subjects = <SubjectModel>[].obs;
  RxList<ScheduleModel> schedules = <ScheduleModel>[].obs;

  // Add a new observable for the current active schedule
  Rx<ScheduleModel?> activeSchedule = Rx<ScheduleModel?>(null);

  // User data
  final Rx<UserModel> activeUser = UserModel.empty().obs;

  // Overall Percentage Chart Data
  RxList<ChartData> overallPercentageChartData = <ChartData>[].obs;

  @override
  void onInit() {
    super.onInit();
    Get.find<AuthController>(tag: null);
  }

  // Get date range for attendance charts with proper distribution
  // A more precise function to get chart date range
  DateTimeRange getExactChartDateRange(String? subjectName) {
    final attendanceController = Get.find<AttendanceController>();
    final DateTime now = DateTime.now();

    // Default fallback range (7 days)
    DateTime minDate = now.subtract(const Duration(days: 6));
    DateTime maxDate = now;

    if (attendanceController.attendanceChartData.isNotEmpty) {
      try {
        // Extract all dates from chart data
        List<DateTime> chartDates =
            attendanceController.attendanceChartData
                .map((data) => data.date)
                .toList();

        if (chartDates.isNotEmpty) {
          // Sort and get exact min/max from actual data points
          chartDates.sort((a, b) => a.compareTo(b));
          minDate = chartDates.first;
          maxDate = chartDates.last;

          // If we only have one date or dates very close together,
          // ensure a minimum range for better visualization
          if (maxDate.difference(minDate).inDays < 2) {
            // Only expand if we have just one date or very close dates
            minDate = minDate.subtract(const Duration(days: 1));
            maxDate = maxDate.add(const Duration(days: 1));
          }
        }
      } catch (e) {
        print('Error calculating exact chart date range: $e');
      }
    }

    // Return date range with times set to start/end of day for clean boundaries
    return DateTimeRange(
      start: DateTime(minDate.year, minDate.month, minDate.day),
      end: DateTime(maxDate.year, maxDate.month, maxDate.day, 23, 59, 59),
    );
  }

  void calculateOverallStatistics() {
    overallPercentage.value = " ${getOverallPercentage()}%";
    todaySchedulesCount.value = getTodaySchedulesCount();
    remainingTodaySchedulesCount.value = getRemainingTodaySchedulesCount();
    checkCurrentActiveSchedule();
  }

  Future<void> addSubject(SubjectModel subject) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _homeRepository.createSubject(subject);

    result.fold(
      (failure) {
        errorMessage.value = failure;
        print(failure);
      },
      (_) {
        // Success - add to the local list
        subjects.add(subject);
        fetchSubjects();
      },
    );
  }

  Future<void> fetchSubjects() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _homeRepository.getSubjects();

    result.fold(
      (failure) {
        errorMessage.value = failure;
        print(failure);
      },
      (fetchedSubjects) async {
        subjects.value = fetchedSubjects;
        print("Subjects fetched: ${subjects.length}");

        // Calculate overall stats after fetching subjects
        await fetchSchedules();
      },
    );
    await Future.delayed(Duration(seconds: 1));
    isLoading.value = false;
  }

  // New function to add a schedule
  Future<void> addSchedule(ScheduleModel schedule) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _homeRepository.createSchedule(schedule);

    result.fold(
      (failure) {
        errorMessage.value = failure;
        print(failure);
      },
      (_) async {
        // Success - this is where we would update local state if needed
        await fetchSchedules();
      },
    );

    isLoading.value = false;
  }

  Future<void> fetchSchedules() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _homeRepository.getSchedules();

    result.fold(
      (failure) {
        errorMessage.value = failure;
        print(failure);
      },
      (fetchedSchedules) async {
        schedules.value = fetchedSchedules;
        calculateOverallStatistics();

        await Future.delayed(Duration(seconds: 2));
        await _notificationService.checkForNotificationPermission();
        await _notificationService.scheduleNotificationsForToday(
          fetchedSchedules,
        );
      },
    );
    isLoading.value = false;
  }

  // Check which schedule is currently active
  void checkCurrentActiveSchedule() {
    final DateTime now = DateTime.now();
    ScheduleModel? currentActive;

    for (ScheduleModel schedule in schedules) {
      try {
        // Convert milliseconds string to DateTime
        final startDateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(schedule.startTimeInMillis!),
        );

        final endDateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(schedule.endTimeInMillis!),
        );

        // For recurring schedules, we need to check if today's instance is active
        if (schedule.canRepeat == true && schedule.repeatRule != null) {
          // Get the day of week for the original schedule and today
          final int scheduleWeekday = startDateTime.weekday;
          final int todayWeekday = now.weekday;

          // For weekly recurrence, check if it's the same day of week
          if (schedule.repeatRule == 'Weekly' &&
              scheduleWeekday == todayWeekday) {
            // Create a DateTime for today with the same time as the schedule
            final todayScheduleStart = DateTime(
              now.year,
              now.month,
              now.day,
              startDateTime.hour,
              startDateTime.minute,
            );

            final todayScheduleEnd = DateTime(
              now.year,
              now.month,
              now.day,
              endDateTime.hour,
              endDateTime.minute,
            );

            // Check if current time is within today's instance of the schedule
            if (now.isAfter(todayScheduleStart) &&
                now.isBefore(todayScheduleEnd)) {
              currentActive = schedule;
              break;
            }
          }
          // For monthly recurrence, check if it's the same day of month
          else if (schedule.repeatRule == 'Monthly' &&
              startDateTime.day == now.day) {
            // Create a DateTime for today with the same time as the schedule
            final todayScheduleStart = DateTime(
              now.year,
              now.month,
              now.day,
              startDateTime.hour,
              startDateTime.minute,
            );

            final todayScheduleEnd = DateTime(
              now.year,
              now.month,
              now.day,
              endDateTime.hour,
              endDateTime.minute,
            );

            // Check if current time is within today's instance of the schedule
            if (now.isAfter(todayScheduleStart) &&
                now.isBefore(todayScheduleEnd)) {
              currentActive = schedule;
              break;
            }
          }
          // For yearly recurrence, check if it's the same day of year
          else if (schedule.repeatRule == 'Yearly' &&
              startDateTime.month == now.month &&
              startDateTime.day == now.day) {
            // Create a DateTime for today with the same time as the schedule
            final todayScheduleStart = DateTime(
              now.year,
              now.month,
              now.day,
              startDateTime.hour,
              startDateTime.minute,
            );

            final todayScheduleEnd = DateTime(
              now.year,
              now.month,
              now.day,
              endDateTime.hour,
              endDateTime.minute,
            );

            // Check if current time is within today's instance of the schedule
            if (now.isAfter(todayScheduleStart) &&
                now.isBefore(todayScheduleEnd)) {
              currentActive = schedule;
              break;
            }
          }
        }
        // For non-recurring schedules, simply check if now is between start and end times
        else {
          if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
            currentActive = schedule;
            break;
          }
        }
      } catch (e) {
        print('Error checking schedule: $e');
      }
    }

    // Update the observable
    activeSchedule.value = currentActive;

    if (currentActive != null) {
      print('Currently active schedule: ${currentActive.subject?.subjectName}');
    } else {
      print('No active schedule at the moment');
    }
  }

  // Get formatted time for the current active schedule (for UI display)
  String getActiveScheduleTimeText() {
    if (activeSchedule.value == null) {
      return 'No active schedule';
    }

    try {
      final startDateTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(activeSchedule.value!.startTimeInMillis!),
      );

      final endDateTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(activeSchedule.value!.endTimeInMillis!),
      );

      // Format times for display
      final startTime = _formatTimeString(startDateTime);
      final endTime = _formatTimeString(endDateTime);

      return '$startTime - $endTime';
    } catch (e) {
      return 'Time unavailable';
    }
  }

  // Helper method to format time
  String _formatTimeString(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  // Get overall percentage across all subjects
  String getOverallPercentage() {
    if (subjects.isEmpty) return '0';

    int totalAttended = 0;
    int totalOccurred = 0;

    for (SubjectModel subject in subjects) {
      totalAttended += subject.currentPercentage ?? 0;
    }

    // Calculate overall percentage and round to nearest integer
    int calculatedPercentage = ((totalAttended / subjects.length)).round();
    print(
      "Overall Percentage: $calculatedPercentage% ($totalAttended/$totalOccurred)",
    );

    return calculatedPercentage.toString();
  }

  // Get count of schedules occurring today
  int getTodaySchedulesCount() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    int count = 0;

    for (ScheduleModel schedule in schedules) {
      try {
        // Convert milliseconds string to DateTime for start time
        final startDateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(schedule.startTimeInMillis!),
        );

        // For non-recurring schedules, check if they fall on today's date
        if (schedule.canRepeat != true) {
          final scheduleDate = DateTime(
            startDateTime.year,
            startDateTime.month,
            startDateTime.day,
          );

          if (scheduleDate.isAtSameMomentAs(today)) {
            count++;
          }
        }
        // For recurring schedules
        else if (schedule.repeatRule != null) {
          // Get original schedule date
          DateTime(startDateTime.year, startDateTime.month, startDateTime.day);

          // Check if the schedule has ended (if it has an end date)
          bool hasEnded = false;
          if (schedule.repeatEndDateInMillis != null) {
            final endDate = DateTime.fromMillisecondsSinceEpoch(
              int.parse(schedule.repeatEndDateInMillis!),
            );
            if (now.isAfter(endDate)) {
              hasEnded = true;
            }
          }

          if (!hasEnded) {
            // Weekly recurrence
            if (schedule.repeatRule == 'Weekly' &&
                startDateTime.weekday == now.weekday) {
              count++;
            }
            // Monthly recurrence
            else if (schedule.repeatRule == 'Monthly' &&
                startDateTime.day == now.day) {
              count++;
            }
            // Yearly recurrence
            else if (schedule.repeatRule == 'Yearly' &&
                startDateTime.month == now.month &&
                startDateTime.day == now.day) {
              count++;
            }
          }
        }
      } catch (e) {
        print('Error calculating today\'s schedule: $e');
      }
    }

    return count;
  }

  // Get count of remaining schedules for today (after current time)
  int getRemainingTodaySchedulesCount() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    int count = 0;

    for (ScheduleModel schedule in schedules) {
      try {
        // Convert milliseconds string to DateTime
        final startDateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(schedule.startTimeInMillis!),
        );

        // Check if the schedule starts after the current time
        bool startsAfterNow = startDateTime.isAfter(now);

        // For non-recurring schedules, check if they fall on today's date AND start after now
        if (schedule.canRepeat != true) {
          final scheduleDate = DateTime(
            startDateTime.year,
            startDateTime.month,
            startDateTime.day,
          );

          if (scheduleDate.isAtSameMomentAs(today) && startsAfterNow) {
            count++;
          }
        }
        // For recurring schedules
        else if (schedule.repeatRule != null) {
          // Check if the schedule has ended (if it has an end date)
          bool hasEnded = false;
          if (schedule.repeatEndDateInMillis != null) {
            final endDate = DateTime.fromMillisecondsSinceEpoch(
              int.parse(schedule.repeatEndDateInMillis!),
            );
            if (now.isAfter(endDate)) {
              hasEnded = true;
            }
          }

          if (!hasEnded) {
            // Create today's instance of this recurring schedule
            DateTime todayScheduleStart;

            // Weekly recurrence
            if (schedule.repeatRule == 'Weekly' &&
                startDateTime.weekday == now.weekday) {
              todayScheduleStart = DateTime(
                today.year,
                today.month,
                today.day,
                startDateTime.hour,
                startDateTime.minute,
              );

              if (todayScheduleStart.isAfter(now)) {
                count++;
              }
            }
            // Monthly recurrence
            else if (schedule.repeatRule == 'Monthly' &&
                startDateTime.day == now.day) {
              todayScheduleStart = DateTime(
                today.year,
                today.month,
                today.day,
                startDateTime.hour,
                startDateTime.minute,
              );

              if (todayScheduleStart.isAfter(now)) {
                count++;
              }
            }
            // Yearly recurrence
            else if (schedule.repeatRule == 'Yearly' &&
                startDateTime.month == now.month &&
                startDateTime.day == now.day) {
              todayScheduleStart = DateTime(
                today.year,
                today.month,
                today.day,
                startDateTime.hour,
                startDateTime.minute,
              );

              if (todayScheduleStart.isAfter(now)) {
                count++;
              }
            }
          }
        }
      } catch (e) {
        print('Error calculating remaining today\'s schedules: $e');
      }
    }

    return count;
  }

  // Add this method to HomeController class
  Future<bool> deleteSubject(String subjectName, BuildContext context) async {
    isLoading.value = true;
    errorMessage.value = '';
    bool success = false;

    try {
      // Find the subject in the local list first
      SubjectModel? subjectToDelete = subjects.firstWhereOrNull(
        (subject) => subject.subjectName == subjectName,
      );

      if (subjectToDelete == null) {
        errorMessage.value = 'Subject not found';
        return false;
      }

      final result = await _homeRepository.deleteSubject(subjectName);

      result.fold(
        (failure) {
          // Handle failure
          errorMessage.value = failure;
          print('Error deleting subject: $failure');
          isLoading.value = false;
        },
        (_) async {
          await fetchSubjects();
          // Success - remove from the local lists and update UI
          subjects.removeWhere((subject) => subject.subjectName == subjectName);

          // Remove all related schedules from local list
          schedules.removeWhere(
            (schedule) => schedule.subject?.subjectName == subjectName,
          );
          print(
            'Subject "$subjectName" and its schedules deleted successfully',
          );

          success = true;
          if (context.mounted) {
            context.pop();
          }
          isLoading.value = false;
        },
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: ${e.toString()}';
      print('Exception while deleting subject: $e');
      isLoading.value = false;
    }

    return success;
  }

  // You might also want a method to confirm deletion with the user
  Future<bool> confirmAndDeleteSubject(
    BuildContext context,
    String subjectName, {
    required Function(bool) onComplete,
  }) async {
    // First check how many schedules would be deleted

    // Note: This method needs to be called from a UI component
    // that can show a dialog to the user. I'm returning
    // implementation details rather than a complete dialog.

    // After confirmation UI, call the actual delete method
    final success = await deleteSubject(subjectName, context);
    onComplete(success);
    return success;
  }

  // Add this method to HomeController class
  Future<bool> deleteSchedule(ScheduleModel schedule) async {
    isLoading.value = true;
    errorMessage.value = '';
    bool success = false;

    try {
      final result = await _homeRepository.deleteSchedule(schedule);

      result.fold(
        (failure) {
          // Handle failure
          errorMessage.value = failure;
          print('Error deleting schedule: $failure');
        },
        (_) {
          // Success - remove from the local list
          schedules.removeWhere(
            (s) =>
                s.subject?.subjectName == schedule.subject?.subjectName &&
                s.startTimeInMillis == schedule.startTimeInMillis,
          );

          // Update statistics and active schedule status
          calculateOverallStatistics();
          success = true;
        },
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: ${e.toString()}';
      print('Exception while deleting schedule: $e');
    } finally {
      isLoading.value = false;
    }

    return success;
  }
}
