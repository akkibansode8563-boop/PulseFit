import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// NotificationService — delivers high-priority lockscreen notifications
/// even when the app is CLOSED or the phone screen is OFF.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'pulsefit_reminders';
  static const String _channelName = 'PulseFit Reminders';
  static const String _channelDesc =
      'Water intake, meal, and activity reminders';

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Create high-importance notification channel (required for Android 8+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Push an immediate lockscreen notification (works when screen is OFF / app closed)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'PulseFit',
      visibility: NotificationVisibility.public, // shows on lockscreen
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Water intake reminder notification
  Future<void> showWaterReminder({int sipsDue = 3}) async {
    await showNotification(
      id: 1001,
      title: '💧 Time to Hydrate!',
      body: 'Drink $sipsDue sips of water now. Stay on track with your daily goal!',
    );
  }

  /// Meal reminder notification
  Future<void> showMealReminder(String mealName) async {
    await showNotification(
      id: 1002,
      title: '🥗 $mealName Time!',
      body: 'Log your $mealName to keep your nutrition on track.',
    );
  }

  /// Activity reminder notification
  Future<void> showActivityReminder() async {
    await showNotification(
      id: 1003,
      title: '🏃 Move Your Body!',
      body: 'Time for your evening walk or workout. Tap to start GPS tracking.',
    );
  }

  /// GPS activity completed notification
  Future<void> showActivityCompleted({
    required String activityType,
    required String distance,
    required String duration,
    required String calories,
  }) async {
    await showNotification(
      id: 1004,
      title: '🎉 $activityType Complete!',
      body: '$distance km • $duration • $calories kcal burned. Great work!',
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
