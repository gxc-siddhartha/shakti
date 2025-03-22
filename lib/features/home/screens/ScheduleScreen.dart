// ScheduleScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shakti/core/helpers/HelperWidgets.dart';
import 'package:shakti/core/models/ScheduleModel.dart';
import 'package:shakti/core/models/SubjectModel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:shakti/features/home/screens/AddScheduleBottomSheet.dart';
import 'package:shakti/features/home/controllers/HomeController.dart';
import 'dart:ui';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final HomeController homeController = Get.find<HomeController>();
  // Initialize with empty list right away
  final ScheduleDataSource _scheduleDataSource = ScheduleDataSource([]);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.fetchSchedules().then((_) {
        _updateAppointments();
      });

      // Add a reactive listener for schedule changes
      ever(homeController.schedules, (_) {
        _updateAppointments();
      });
    });
  }

  // Convert option like "Weekly" to a proper recurrence rule
  String _convertToRecurrenceRule(
    String? option,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (option == null || option.isEmpty) {
      return "";
    }

    // Format end date for the UNTIL part (YYYYMMDD format)
    String endDateStr = _formatDateForRecurrence(endDate);

    switch (option) {
      case 'Weekly':
        // For weekly recurrence, we need to specify which day of the week
        String dayOfWeek = _getDayOfWeekName(startDate.weekday);
        return 'FREQ=WEEKLY;INTERVAL=1;BYDAY=$dayOfWeek;UNTIL=$endDateStr';
      case 'Monthly':
        // For monthly, we'll set it to repeat on the same day of month
        int dayOfMonth = startDate.day;
        return 'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=$dayOfMonth;UNTIL=$endDateStr';
      case 'Yearly':
        // For yearly, we'll set it to repeat on the same month and day
        return 'FREQ=YEARLY;INTERVAL=1;UNTIL=$endDateStr';
      default:
        return '';
    }
  }

  // Get day of week in format needed for recurrence rule (MO, TU, WE, etc.)
  String _getDayOfWeekName(int weekday) {
    // weekday in DateTime: 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
    switch (weekday) {
      case 1:
        return 'MO';
      case 2:
        return 'TU';
      case 3:
        return 'WE';
      case 4:
        return 'TH';
      case 5:
        return 'FR';
      case 6:
        return 'SA';
      case 7:
        return 'SU';
      default:
        return 'MO'; // Default to Monday if something goes wrong
    }
  }

  // Format date to YYYYMMDD format for recurrence rule
  String _formatDateForRecurrence(DateTime date) {
    String year = date.year.toString();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    return '$year$month${day}T235959Z';
  }

  void _updateAppointments() {
    List<Appointment> appointments = [];

    for (ScheduleModel schedule in homeController.schedules) {
      try {
        // Convert milliseconds string to DateTime
        final startDateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(schedule.startTimeInMillis!),
        );

        final endDateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(schedule.endTimeInMillis!),
        );

        final repeatEndDate =
            schedule.repeatEndDateInMillis != null
                ? DateTime.fromMillisecondsSinceEpoch(
                  int.parse(schedule.repeatEndDateInMillis!),
                )
                : null;

        // Get recurrence rule
        String recurrenceRule = "";
        if (schedule.canRepeat == true &&
            schedule.repeatRule != null &&
            repeatEndDate != null) {
          recurrenceRule = _convertToRecurrenceRule(
            schedule.repeatRule,
            startDateTime,
            repeatEndDate,
          );
        }

        // Create appointment
        appointments.add(
          Appointment(
            startTime: startDateTime,
            endTime: endDateTime,
            subject: schedule.subject!.subjectName!,
            color: Theme.of(context).colorScheme.primary,
            notes: 'Subject Class',
            recurrenceRule: recurrenceRule,
            isAllDay: false,
          ),
        );

        print('Created appointment with recurrence rule: $recurrenceRule');
      } catch (e) {
        // Log error but continue processing other schedules
        print('Error creating appointment: $e');
      }
    }

    // Update the data source
    if (mounted) {
      setState(() {
        _scheduleDataSource.appointments = appointments;
        _scheduleDataSource.notifyListeners(
          CalendarDataSourceAction.reset,
          appointments,
        );
      });
    }
  }

  // Method to show the bottom sheet
  void _showAddScheduleBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const AddScheduleButtonSheet();
      },
    );

    // Handle the selected data
    if (result != null) {
      try {
        final subject = result['subject'] as String;
        final startDate = result['startDate'] as DateTime;
        final startTime = result['startTime'] as TimeOfDay;
        final endTime = result['endTime'] as TimeOfDay;

        // Use the correct key from the bottom sheet
        final repeatOption = result['repeatOption'] as String?;

        final endDate = result['endDate'] as DateTime;

        // Find the subject model based on subject name
        final SubjectModel? selectedSubject = homeController.subjects
            .firstWhereOrNull((sub) => sub.subjectName == subject);

        if (selectedSubject != null) {
          // Create start and end DateTimes
          final startDateTime = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
            startTime.hour,
            startTime.minute,
          );

          final endDateTime = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
            endTime.hour,
            endTime.minute,
          );

          // Create the schedule model
          final scheduleModel = ScheduleModel(
            startTimeInMillis: startDateTime.millisecondsSinceEpoch.toString(),
            endTimeInMillis: endDateTime.millisecondsSinceEpoch.toString(),
            subject: selectedSubject,
            repeatRule: repeatOption,
            repeatEndDateInMillis: endDate.millisecondsSinceEpoch.toString(),
            canRepeat: repeatOption != null && repeatOption.isNotEmpty,
          );

          // Pass to the controller to handle saving
          await homeController.addSchedule(scheduleModel);

          // Update appointments after adding new schedule
          _updateAppointments();

          // Show a success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Schedule created for $subject'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          // Subject not found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subject not found'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        // Handle any casting or other errors
        print('Error processing form data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing form data: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          TextButton(
            onPressed: () => _showAddScheduleBottomSheet(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Always return the calendar, just with empty data if no schedules
          PopUpAnimationWidget(
            child: SfCalendar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              firstDayOfWeek: 1,
              view:
                  CalendarView
                      .day, // Changed to week for better layout like Apple Calendar
              dataSource: _scheduleDataSource,

              todayHighlightColor: Theme.of(context).colorScheme.secondary,
              cellBorderColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.1),
              // monthViewSettings: MonthViewSettings(
              //   appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              //   showAgenda: true,
              // ),
              appointmentBuilder: _customAppointmentBuilder,
              selectionDecoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              headerStyle: CalendarHeaderStyle(
                backgroundColor: Theme.of(context).colorScheme.primary,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.6,
                ),
              ),
              viewHeaderStyle: ViewHeaderStyle(
                backgroundColor: Theme.of(context).colorScheme.surface,
                dayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                dateTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              timeSlotViewSettings: TimeSlotViewSettings(
                startHour: 7,
                endHour: 22,
                timeFormat: 'h:mm a',
                timeIntervalHeight: 60,
                timeTextStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),

          // Loading indicator
          Obx(
            () =>
                homeController.isLoading.value
                    ? ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(1),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    )
                    : Container(),
          ),
        ],
      ),
    );
  }

  // Show options when a schedule is long-pressed
  void _showScheduleOptions(BuildContext context, Appointment appointment) {
    // Find the corresponding ScheduleModel
    ScheduleModel? schedule = _findScheduleFromAppointment(appointment);

    if (schedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to identify the selected schedule'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show a bottom sheet with options
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Schedule Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showScheduleDetails(context, schedule);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Delete Schedule',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteSchedule(context, schedule);
                },
              ),
            ],
          ),
    );
  }

  // Find the ScheduleModel that corresponds to an Appointment
  ScheduleModel? _findScheduleFromAppointment(Appointment appointment) {
    // We need to match based on subject name and start/end times
    final DateTime appStartTime = appointment.startTime;
    final DateTime appEndTime = appointment.endTime;

    // First try to find a direct time match (for non-recurring events)
    for (ScheduleModel schedule in homeController.schedules) {
      try {
        // Convert milliseconds to DateTime
        final scheduleStartTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(schedule.startTimeInMillis!),
        );
        final scheduleEndTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(schedule.endTimeInMillis!),
        );

        // For non-recurring schedules, check for exact time match
        if (schedule.canRepeat != true) {
          if (appStartTime.isAtSameMomentAs(scheduleStartTime) &&
              appEndTime.isAtSameMomentAs(scheduleEndTime) &&
              appointment.subject == schedule.subject?.subjectName) {
            return schedule;
          }
        } else {
          // For recurring schedules, check if the pattern matches
          // This is a simplification - just checking subject and time of day match
          if (appointment.subject == schedule.subject?.subjectName &&
              appStartTime.hour == scheduleStartTime.hour &&
              appStartTime.minute == scheduleStartTime.minute &&
              appEndTime.hour == scheduleEndTime.hour &&
              appEndTime.minute == scheduleEndTime.minute) {
            return schedule;
          }
        }
      } catch (e) {
        print('Error matching schedule: $e');
      }
    }

    return null;
  }

  // Show more details about the schedule
  void _showScheduleDetails(BuildContext context, ScheduleModel schedule) {
    try {
      final startDateTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(schedule.startTimeInMillis!),
      );
      final endDateTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(schedule.endTimeInMillis!),
      );

      final String formattedDate = DateFormat(
        'EEEE, MMMM d, yyyy',
      ).format(startDateTime);
      final String timeRange =
          "${_formatTime(startDateTime)} - ${_formatTime(endDateTime)}";

      String repeatText = "Does not repeat";
      if (schedule.canRepeat == true && schedule.repeatRule != null) {
        repeatText = "Repeats ${schedule.repeatRule}";

        if (schedule.repeatEndDateInMillis != null) {
          final endDate = DateTime.fromMillisecondsSinceEpoch(
            int.parse(schedule.repeatEndDateInMillis!),
          );
          repeatText += " until ${DateFormat('MMM d, yyyy').format(endDate)}";
        }
      }

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(schedule.subject?.subjectName ?? "Schedule Details"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: $formattedDate'),
                  const SizedBox(height: 8),
                  Text('Time: $timeRange'),
                  const SizedBox(height: 8),
                  Text('Repeat: $repeatText'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDeleteSchedule(context, schedule);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error showing schedule details: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Confirm schedule deletion
  void _confirmDeleteSchedule(BuildContext context, ScheduleModel schedule) {
    String scheduleName = schedule.subject?.subjectName ?? "this schedule";
    String warningMessage = 'Are you sure you want to delete $scheduleName?';

    if (schedule.canRepeat == true) {
      warningMessage +=
          '\n\nThis will delete all occurrences of this recurring schedule.';
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Schedule'),
            content: Text(warningMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleting schedule...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  final success = await homeController.deleteSchedule(schedule);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Schedule deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          homeController.errorMessage.value.isEmpty
                              ? 'Failed to delete schedule'
                              : 'Error: ${homeController.errorMessage.value}',
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  // Custom appointment builder to match Apple Calendar style
  // Custom appointment builder with long-press detection
  Widget _customAppointmentBuilder(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final Appointment appointment = details.appointments.first as Appointment;

    // Format time for display
    final String startTime = _formatTime(appointment.startTime);
    final String endTime = _formatTime(appointment.endTime);
    final String timeRange = "$startTime - $endTime";

    return GestureDetector(
      onLongPress: () => _showScheduleOptions(context, appointment),
      child: Container(
        width: details.bounds.width,
        height: details.bounds.height,
        decoration: BoxDecoration(
          color: appointment.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Left color indicator strip (Apple Calendar style)
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: appointment.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),

            // Appointment content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 4.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject text
                    Text(
                      appointment.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // Only show time range if there's enough space
                    if (details.bounds.height > 45)
                      Text(
                        timeRange,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to format time for display
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

// Custom data source for the calendar
class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Appointment> source) {
    appointments = source;
  }
}
