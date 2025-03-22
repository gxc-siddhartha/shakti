import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shakti/core/helpers/HelperWidgets.dart';
import 'package:shakti/core/models/AttendanceModel.dart';
import 'package:shakti/core/models/ScheduleModel.dart';
import 'package:shakti/core/models/SubjectModel.dart';
import 'package:shakti/features/home/controllers/AttendanceController.dart';
import 'package:shakti/features/home/controllers/HomeController.dart';
import 'package:shakti/features/home/screens/MarkAttendanceDialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SubjectDetailsScreen extends StatefulWidget {
  final SubjectModel subject;
  const SubjectDetailsScreen({super.key, required this.subject});

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  final HomeController _homeController = Get.find<HomeController>();
  final AttendanceController _attendanceController =
      Get.find<AttendanceController>();

  @override
  void initState() {
    super.initState();
    // Fetch attendance records for this subject
    _attendanceController.fetchAttendanceRecords(widget.subject);
    // _attendanceController.fetchAttendanceBySubject(widget.subject.subjectName!);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subject.subjectName ?? "",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // Important for keyboard handling
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                ),
                builder:
                    (context) => MarkAttendanceDialog(subject: widget.subject),
              ).then((result) {
                if (result != null && result is Map<String, dynamic>) {
                  // Extract schedule and status from result
                  final selectedSchedule = result['schedule'] as ScheduleModel;
                  final status = result['status'] as String;
                  final selectedDate = result['selectedDate'] as DateTime?;

                  // Use the AttendanceController to mark attendance
                  _attendanceController.markAttendance(
                    selectedSchedule,
                    status,
                    selectedDate!,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Marked ${status} for ${widget.subject.subjectName}",
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              });
            },
            child: Text("Mark"),
          ),
        ],
      ),
      body: Obx(() {
        final isLoading = _attendanceController.isLoading.value;

        if (isLoading || _homeController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return PopUpAnimationWidget(
          duration: Duration(milliseconds: 1000),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: CCardText(
                    content: _buildAttendanceChart(),
                    iconThemeColor: Color(0xff5F99AE),
                    cardTitle: "Percentage Chart",
                    icon: SFIcons.sf_chart_xyaxis_line,
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 0, left: 16, right: 8),
                        child: CCardText(
                          content: Text(
                            _attendanceController.attendedClasses.value
                                .toString(),
                            style: TextStyle(
                              fontSize: 24,

                              // Using the primary theme color instead of conditional color
                            ),
                          ),
                          iconThemeColor: Color(0xffBE5985),
                          cardTitle: "Classes Attended",
                          icon: SFIcons.sf_hand_raised,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 0, left: 8, right: 16),
                        child: CCardText(
                          content: Text(
                            _attendanceController.attendanceRecords.length
                                .toString(),
                            style: TextStyle(
                              fontSize: 24,

                              // Using the primary theme color instead of conditional color
                            ),
                          ),
                          iconThemeColor: Color(0xffD98324),
                          cardTitle: "Total Classes",
                          icon: SFIcons.sf_sum,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 0, left: 16, right: 8),
                        child: CCardText(
                          content: Text(
                            _attendanceController.attendancePercentage
                                .round()
                                .toString(),
                            style: TextStyle(
                              fontSize: 24,

                              // Using the primary theme color instead of conditional color
                            ),
                          ),
                          iconThemeColor: Color(0xff89AC46),
                          cardTitle: "Current Percentage",
                          icon: SFIcons.sf_chart_pie,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 0, left: 8, right: 16),
                        child: CCardText(
                          content: Text(
                            _getRemainingClassesText(),
                            style: TextStyle(
                              fontSize: 24,

                              // Using the primary theme color instead of conditional color
                            ),
                          ),
                          iconThemeColor: Theme.of(context).colorScheme.primary,
                          cardTitle: "Status",
                          icon:
                              SFIcons.sf_gauge_open_with_lines_needle_33percent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.15),
                      ),
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 30,
                                width: 30,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.15),
                                ),
                                child: Center(
                                  child: SFIcon(
                                    SFIcons.sf_list_and_film,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              SizedBox(width: screenWidth * 0.02),
                              Expanded(
                                child: Text(
                                  "Attendance Logs",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        _buildAttendanceLogs(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.surface,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(
                            width: 0.5,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _showDeleteConfirmationDialog();
                    },
                    child: Text(
                      "Remove Subject",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAttendanceChart() {
    final chartData = _attendanceController.attendanceChartData;

    if (chartData.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(child: Text("No attendance data available for chart")),
      );
    }

    // Calculate the date range for the last week to today
    final DateTime upperLimit = DateTime.now();
    final DateTime lowerLimit = upperLimit.subtract(const Duration(days: 6));

    return SizedBox(
      height: 150,
      child: SfCartesianChart(
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat.MMMd(),
          intervalType: DateTimeIntervalType.days,
          majorGridLines: const MajorGridLines(width: 0),
          title: AxisTitle(text: 'Last 7 Days'),
          minimum: lowerLimit,
          isVisible: false,
          maximum: upperLimit,
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: 100,
          interval: 25,
          isVisible: false,
          labelFormat: '{value}%',
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          // title: AxisTitle(text: 'Attendance %'),
        ),
        plotAreaBorderWidth: 0,
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x : point.y%',
          header: '',
        ),
        series: <CartesianSeries>[
          AreaSeries<ChartData, DateTime>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.date,
            yValueMapper: (ChartData data, _) => data.percentage,
            name: 'Attendance Area',
            color: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.3), // Primary color
            borderColor: Colors.transparent, // Hide the border of the area
            borderWidth: 0,
            // Gradient fill with primary color
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
                Theme.of(context).colorScheme.primary.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          LineSeries<ChartData, DateTime>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.date,
            yValueMapper: (ChartData data, _) => data.percentage,
            name: 'Attendance',
            color: Theme.of(context).colorScheme.primary, // Primary color
            width: 2,
            markerSettings: const MarkerSettings(
              isVisible: true,
              shape: DataMarkerType.circle,
              height: 6,
              width: 6,
            ),
            // Only show data labels for first and last points to avoid crowding
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.top,
              showZeroValue: true,
              useSeriesColor: true,
              builder: (
                dynamic data,
                dynamic point,
                dynamic series,
                int pointIndex,
                int seriesIndex,
              ) {
                // Only show labels for first, last, and days with attendance changes
                bool showLabel =
                    pointIndex == 0 ||
                    pointIndex == chartData.length - 1 ||
                    (pointIndex > 0 &&
                        data.percentage !=
                            chartData[pointIndex - 1].percentage);

                if (!showLabel) return const SizedBox.shrink();

                return Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 60),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      '${data.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: "monospace",
                        // fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        legend: const Legend(isVisible: false),
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: false,
          zoomMode: ZoomMode.x,
          enableMouseWheelZooming: false,
          enablePinching: false,
          enableDoubleTapZooming: false,
          enableSelectionZooming: false,
        ),
      ),
    );
  }

  String _getRemainingClassesText() {
    double percentage = _attendanceController.attendancePercentage.value;

    if (percentage >= 75) {
      return "Good";
    } else {
      // Calculate classes needed to reach 75%
      int totalClasses = widget.subject.occuredEvents ?? 0;
      int attendedClasses = widget.subject.attendedEvents ?? 0;

      // Formula: (attended + x) / (total + x) = 0.75
      // Solving for x: x = (0.75*total - attended) / 0.25
      double classesNeeded = (0.75 * totalClasses - attendedClasses) / 0.25;
      int roundedClassesNeeded = classesNeeded.ceil();

      if (roundedClassesNeeded <= 0) {
        return "On Track";
      } else {
        return "Need $roundedClassesNeeded";
      }
    }
  }

  // This is the fixed _buildAttendanceLogs() method to replace in your SubjectDetailsScreen class

  // Replace your _buildAttendanceLogs() method with this updated version
  Widget _buildAttendanceLogs() {
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

    // Replace ListView.builder with a Column containing a fixed list of widgets
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        sortedRecords.length < 10 ? sortedRecords.length : 10,
        (index) {
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
                    onPressed: (context) {
                      _attendanceController.confirmAndDeleteAttendance(
                        context,
                        record,
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
                        fontWeight: FontWeight.bold,
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

  // Helper method to format the date as "17th March, '25"
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

  // Add this method to your _SubjectDetailsScreenState class
  void _showDeleteConfirmationDialog() {
    // Count related schedules for this subject
    final relatedSchedules =
        _homeController.schedules
            .where(
              (schedule) =>
                  schedule.subject?.subjectName == widget.subject.subjectName,
            )
            .length;

    // Prepare warning message
    String warningMessage =
        'Are you sure you want to remove "${widget.subject.subjectName}"?';

    if (relatedSchedules > 0) {
      warningMessage +=
          '\n\nThis will also delete $relatedSchedules associated schedule(s).';
    }

    warningMessage += '\n\nThis action cannot be undone.';

    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (mcontext) => AlertDialog(
            title: const Text('Remove Subject'),
            content: Text(warningMessage),
            actions: [
              // Cancel button
              TextButton(
                onPressed: () => mcontext.pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              // Delete button
              TextButton(
                onPressed: () async {
                  // Close the dialog first
                  mcontext.pop();

                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleting subject...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  // Call the delete method
                  final success = await _homeController.deleteSubject(
                    widget.subject.subjectName ?? "",
                    context,
                  );

                  if (success) {
                    // Show success message
                    if (context.mounted) {
                      context.pop();
                    }
                  } else {
                    // Show error message
                  }
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
