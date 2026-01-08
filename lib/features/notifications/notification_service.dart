import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    // Android Initialization
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_test', 
      'Test Channel',
      channelDescription: 'Channel for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _notificationsPlugin.show(
      999,
      'Test Notification',
      'If you see this, notifications are working!',
      details,
    );
  }

  Future<bool> requestPermissions() async {
    print("Requesting permissions...");
    bool? result = false;
    
    // iOS
    result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    // Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final bool? androidResult = await androidImplementation.requestNotificationsPermission();
      print("Android Permission Result: $androidResult");
      result = (result ?? false) || (androidResult ?? false);
    }

    return result ?? false;
  }

  Future<void> scheduleWaterReminder() async {

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_water', 
      'Water Reminder',
      channelDescription: 'Reminds you to drink water',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _notificationsPlugin.periodicallyShow(
      100,
      'Time to Hydrate! 💧',
      'Drink a glass of water to stay healthy.',
      RepeatInterval.everyMinute,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle
    );
  }

  Future<void> scheduleWaterReminderHourly() async {
    await _notificationsPlugin.cancel(100);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_water', 
      'Water Reminder',
      channelDescription: 'Reminds you to drink water',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _notificationsPlugin.periodicallyShow(
      100,
      'Time to Hydrate! 💧',
      'Don\'t forget to drink water.',
      RepeatInterval.hourly, 
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle
    );
  }

  Future<void> scheduleExerciseReminder() async {
    await _notificationsPlugin.cancel(200);

    await _scheduleDaily(
      200,
      'Workout Time! 💪',
      'Your daily exercise goal is waiting for you.',
      18, 00 // 6 PM
    );
  }

  Future<void> scheduleAIMotivation() async {
    await _notificationsPlugin.cancel(300);

    final quotes = [
      "Believe you can and you're halfway there.",
      "The only bad workout is the one that didn't happen.",
      "Your health is your investment.",
      "One day or day one. You decide."
    ];
    final quote = (quotes..shuffle()).first;

    await _scheduleDaily(
      300,
      'Daily Motivation 🚀',
      quote,
      9, 00
    );
  }

  Future<void> _scheduleDaily(int id, String title, String body, int hour, int minute) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_daily', 
      'Daily Reminders',
      channelDescription: 'Daily scheduled reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
  
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
