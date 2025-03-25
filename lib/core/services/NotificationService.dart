import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/instance_manager.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import 'package:shakti/core/models/ScheduleModel.dart';
import 'package:shakti/core/models/SubjectModel.dart';
import 'package:shakti/core/router/RouterConstants.dart';
import 'package:shakti/core/router/RouterService.dart';
import 'package:shakti/core/typedefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      Get.find<FlutterLocalNotificationsPlugin>();

  // Initialize notifications
  Future<void> initialize() async {
    try {
      // Define the notification settings for Android
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Define notification settings for iOS
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Combine the settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize with the settings and set up the notification tap callback
      await flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  // Handle notification taps
  void _onNotificationTap(NotificationResponse response) {
    try {
      // Extract the payload that contains subject info
      final String? payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        // Parse subject data from payload
        final Map<String, dynamic> payloadData = _parsePayload(payload);
        final String subjectName = payloadData['subjectName'] ?? '';

        // Create a basic SubjectModel to pass to the details screen
        if (subjectName.isNotEmpty) {
          final SubjectModel subject = SubjectModel(
            subjectName: subjectName,
            totalEvents: 0,
            attendedEvents: 0,
            occuredEvents: 0,
            missedEvents: 0,
            percentageRequiredToCover: 0,
            currentPercentage: 0,
          );

          // Navigate to subject details screen
          _navigateToSubjectDetails(subject);
        }
      }
    } catch (e) {
      print('Error handling notification tap: $e');
    }
  }

  // Parse the notification payload
  Map<String, dynamic> _parsePayload(String payload) {
    try {
      // Simple parsing for key-value pairs in format: "key1:value1;key2:value2"
      final Map<String, dynamic> data = {};
      final pairs = payload.split(';');

      for (final pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          data[keyValue[0]] = keyValue[1];
        }
      }

      return data;
    } catch (e) {
      print('Error parsing notification payload: $e');
      return {};
    }
  }

  // Navigate to subject details
  void _navigateToSubjectDetails(SubjectModel subject) {
    // Use the RouterService to navigate
    // Note: This approach uses a global navigator to work from outside the widget tree
    RouterService.routerService.pushNamed(
      RouterConstants.subjectDetailsScreenRouteName,
      extra: subject,
    );
    print('Navigated to subject details for: ${subject.subjectName}');
  }

  // This method is called from your HomeScreen
  Future<void> checkForNotificationPermission() async {
    try {
      final result = await _requestPermission();
      print("Notification permission granted: $result");
    } catch (e) {
      print("Error requesting notification permission: $e");
    }
  }

  // Private implementation that handles both iOS and Android
  Future<bool> _requestPermission() async {
    bool permissionGranted = false;

    try {
      if (Platform.isIOS) {
        // iOS permission request
        final settings = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        permissionGranted = settings ?? false;
      } else if (Platform.isAndroid) {
        // For Android, use permission_handler which is more reliable
        final status = await Permission.notification.request();
        permissionGranted = status.isGranted;
      }

      return permissionGranted;
    } catch (e) {
      print("Permission request error: $e");
      return false;
    }
  }

  FutureEither<void> scheduleNotificationsForToday(
    List<ScheduleModel> schedules,
  ) async {
    final _prefs = await SharedPreferences.getInstance();
    try {
      if (schedules.isEmpty) {
        return right(null);
      }

      // Check notification permission first
      bool permissionGranted = await _requestPermission();
      if (!permissionGranted) {
        return left('Notification permission not granted');
      }

      // Retrieve existing scheduled notifications
      List<String> existingScheduledNotifications =
          _prefs.getStringList("todaysNotifications") ?? [];

      // Get today's date as a string for comparison (format: YYYY-MM-DD)
      final todaysDateString =
          "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
      final lastScheduledDate = _prefs.getString("lastScheduledDate") ?? "";

      // If the date has changed, clear the existing notifications
      if (lastScheduledDate != todaysDateString) {
        existingScheduledNotifications = [];
        await flutterLocalNotificationsPlugin.cancelAll();
      }

      List<ScheduleModel> todaysSchedules = [];
      List<String> scheduleNames = [
        ...existingScheduledNotifications,
      ]; // Start with existing notifications
      final todaysDate = DateTime.now();
      print("Today's date: ${todaysDate.weekday}");

      for (int i = 0; i < schedules.length; i++) {
        final scheduleModel = schedules[i];
        final scheduleDate = DateTime.fromMillisecondsSinceEpoch(
          int.parse(scheduleModel.startTimeInMillis!),
        );

        if (scheduleDate.day == todaysDate.day &&
            scheduleDate.month == todaysDate.month &&
            scheduleDate.year == todaysDate.year) {
          todaysSchedules.add(scheduleModel);
        } else {
          continue;
        }
      }

      // Set up notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'class_reminder_channel',
            'Class Reminders',
            channelDescription: 'Notifications for upcoming classes',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          );

      // Create notification details
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      // Schedule notifications for today's schedules
      int notificationCount = 0;
      for (int i = 0; i < todaysSchedules.length; i++) {
        final schedule = todaysSchedules[i];
        final scheduleStartTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(schedule.startTimeInMillis!),
        );

        // Create a unique identifier for this schedule
        final String scheduleIdentifier =
            "${schedule.subject!.subjectName!.toLowerCase().replaceAll(" ", "_")}_${schedule.startTimeInMillis}";

        // Only schedule notifications for future times (not past classes)
        if (scheduleStartTime.isAfter(todaysDate)) {
          // Schedule a notification 15 minutes before class starts
          final notificationTime = scheduleStartTime.add(Duration(minutes: 35));

          // Only schedule if the notification time is in the future and not already scheduled
          if (notificationTime.isAfter(todaysDate) &&
              !existingScheduledNotifications.contains(scheduleIdentifier)) {
            // Create a payload with subject information for navigation when tapped
            final String payload =
                "subjectName:${schedule.subject?.subjectName}";

            // Convert DateTime to TZDateTime
            final tz.TZDateTime tzNotificationTime = tz.TZDateTime.from(
              notificationTime,
              tz.local,
            );

            await flutterLocalNotificationsPlugin.zonedSchedule(
              schedule.hashCode, // Use hashCode for a more reliable unique ID
              '⏰ ${schedule.subject?.subjectName ?? "Subject"}',
              'Class is about to end, mark your attendance!',
              tzNotificationTime,
              notificationDetails,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              payload: payload, // Add the payload for navigation
            );

            // Add to the list of scheduled notifications
            scheduleNames.add(scheduleIdentifier);

            notificationCount++;
            print(
              'Scheduled notification for ${schedule.subject?.subjectName} at ${notificationTime.toString()}',
            );
          } else {
            print(
              'Skipped notification for ${schedule.subject?.subjectName} (already scheduled)',
            );
          }
        }
      }

      // Save the updated list of scheduled notifications
      await _prefs.setStringList("todaysNotifications", scheduleNames);

      // Save today's date for future reference
      await _prefs.setString("lastScheduledDate", todaysDateString);

      print('Scheduled $notificationCount new notifications for today');

      return right(null);
    } catch (e) {
      print('Error scheduling notifications: $e');
      return left('Failed to schedule notifications: $e');
    }
  }
}
