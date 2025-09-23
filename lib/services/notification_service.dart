import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart'; // Add this import

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'marg_mitra_channel',
      'Marg Mitra Notifications',
      channelDescription: 'Notifications for Marg Mitra app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> showSosNotification() async {
    await showNotification(
      id: 999,
      title: 'SOS Alert Sent!',
      body: 'Your emergency request has been sent to nearby providers',
    );
  }

  // ADD THIS MISSING METHOD:
  Future<void> showWeatherAwareSosNotification({
    required RoadSafetyLevel safetyLevel,
    WeatherData? weather,
  }) async {
    String title;
    String body;

    // Customize notification based on safety level
    switch (safetyLevel) {
      case RoadSafetyLevel.dangerous:
        title = '🚨 CRITICAL WEATHER EMERGENCY!';
        body = 'Emergency SOS sent with dangerous weather conditions alert';
        break;
      case RoadSafetyLevel.moderate:
        title = '⚠️ Weather Alert SOS Sent';
        body = 'Emergency request sent - weather conditions may affect response';
        break;
      case RoadSafetyLevel.safe:
      default:
        title = 'SOS Alert Sent';
        body = 'Your emergency request has been sent to nearby providers';
        break;
    }

    // Add weather info to body if available
    if (weather != null) {
      body += '\nWeather: ${weather.description}, ${weather.temperature.round()}°C';
    }

    // Use high priority notification for dangerous conditions
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Notifications',
      channelDescription: 'High priority emergency notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      autoCancel: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      998, // Different ID for weather-aware SOS
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> showProviderFoundNotification(String providerName) async {
    await showNotification(
      id: 100,
      title: 'Provider Found!',
      body: '$providerName is coming to help you',
    );
  }
}

// Riverpod provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});