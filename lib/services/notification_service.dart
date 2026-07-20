import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    // Default fallback timezone to Asia/Kolkata (IST)
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (e) {
      debugPrint('[NotificationService] Failed to set location to Asia/Kolkata: $e');
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[NotificationService] Notification clicked: ${details.payload}');
      },
    );
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> schedulePickupReminders({
    required int pickupId,
    required DateTime pickupDate,
  }) async {
    final now = DateTime.now();

    // 1. Reminder the day before (around 4:00 PM)
    final dayBefore = pickupDate.subtract(const Duration(days: 1));
    final dayBeforeSchedule = DateTime(
      dayBefore.year,
      dayBefore.month,
      dayBefore.day,
      16, // 4:00 PM
      0,
    );

    if (dayBeforeSchedule.isAfter(now)) {
      await _scheduleNotification(
        id: pickupId * 2, // Unique ID for day before
        title: 'SuchiGo Pickup Reminder',
        body: 'Your garbage pickup is scheduled for tomorrow. Please keep your bags ready!',
        scheduledDateTime: dayBeforeSchedule,
        payload: 'pickup_$pickupId',
      );
      debugPrint('[NotificationService] Scheduled day-before reminder at $dayBeforeSchedule');
    }

    // 2. Reminder on the day of the pickup (around 8:00 AM)
    final dayOfSchedule = DateTime(
      pickupDate.year,
      pickupDate.month,
      pickupDate.day,
      8, // 8:00 AM (morning 7-10 AM)
      0,
    );

    if (dayOfSchedule.isAfter(now)) {
      await _scheduleNotification(
        id: pickupId * 2 + 1, // Unique ID for day of
        title: 'SuchiGo Pickup Today',
        body: 'Our collector will arrive today. Please ensure waste is accessible!',
        scheduledDateTime: dayOfSchedule,
        payload: 'pickup_$pickupId',
      );
      debugPrint('[NotificationService] Scheduled day-of reminder at $dayOfSchedule');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pickup_reminders',
      'Pickup Reminders',
      channelDescription: 'Notifications to remind you of scheduled waste collections',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> showBookingConfirmedNotification({
    required int pickupId,
    required String wasteType,
    required String date,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'booking_confirmations',
      'Booking Confirmations',
      channelDescription: 'Notifications for successful bookings',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      pickupId,
      'Booking Confirmed! 🎉',
      'Your pickup for $wasteType is scheduled on $date. Thank you for using Suchigo!',
      platformDetails,
      payload: 'pickup_$pickupId',
    );
  }
}
