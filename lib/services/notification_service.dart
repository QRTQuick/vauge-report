import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

class NewsNotificationService {
  NewsNotificationService._();

  static final NewsNotificationService instance = NewsNotificationService._();

  static const String _lastNotifiedKey = 'last_notified_url';
  static const String _notificationEnabledKey = 'notifications_enabled';
  static const String _channelId = 'breaking_news';
  static const String _channelName = 'Breaking News';
  static const String _channelDescription = 'Current news and important updates';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _notificationsEnabled = true;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
    _initialized = true;

    // Load notification preference
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationEnabledKey) ?? true;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      try {
        final dynamic platform = androidPlugin;
        await platform.requestPermission();
        await platform.createNotificationChannel(_createAndroidChannel());
      } catch (_) {
        // Ignore if permission API isn't available on this platform.
      }
    }
  }

  AndroidNotificationChannel _createAndroidChannel() {
    return const AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
      enableLights: true,
    );
  }

  Future<void> notifyIfNew(Article article) async {
    if (!_initialized || !_notificationsEnabled || article.url.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastUrl = prefs.getString(_lastNotifiedKey);
    if (lastUrl == article.url) {
      return;
    }

    final body =
        article.description.isNotEmpty ? article.description : article.source;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
      playSound: true,
      enableLights: true,
      enableVibration: true,
    );

    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      100,
      article.title.isNotEmpty ? article.title : 'Current News',
      body.isNotEmpty ? body : 'New article available',
      details,
      payload: article.url,
    );

    await prefs.setString(_lastNotifiedKey, article.url);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
  }

  bool get notificationsEnabled => _notificationsEnabled;
}
