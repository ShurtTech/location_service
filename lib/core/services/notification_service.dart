import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  static int _notificationId = 0;

  // Initialize notifications
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request notification permissions
      await _requestPermissions();

      _isInitialized = true;
      print('✅ Notification service initialized');
      developer.log('Notification service initialized', name: 'NotificationService');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
      developer.log('Error initializing notifications', name: 'NotificationService', error: e);
    }
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    try {
      // Android 13+ requires notification permission
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // iOS permissions
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      print('✅ Notification permissions requested');
    } catch (e) {
      print('⚠️ Error requesting notification permissions: $e');
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
  }

  // Show location update notification
  static Future<void> showLocationNotification({
    required Position position,
    required int locationCount,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _notificationId++;

      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}';

      // Android notification details
      final androidDetails = AndroidNotificationDetails(
        'location_tracking',
        'Location Tracking',
        channelDescription: 'Notifications for location updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        when: now.millisecondsSinceEpoch,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          '📍 Lat: ${position.latitude.toStringAsFixed(6)}\n'
          '📍 Lng: ${position.longitude.toStringAsFixed(6)}\n'
          '📏 Accuracy: ${position.accuracy.toStringAsFixed(1)}m\n'
          '🚗 Speed: ${(position.speed * 3.6).toStringAsFixed(1)} km/h',
          htmlFormatBigText: true,
          contentTitle: '📍 Location Update #$locationCount',
          summaryText: timeStr,
        ),
        sound: null, // Silent notification
        playSound: false,
        enableVibration: false,
        ongoing: false,
        autoCancel: true,
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        _notificationId,
        '📍 Location Update #$locationCount',
        'Lat: ${position.latitude.toStringAsFixed(4)}, '
        'Lng: ${position.longitude.toStringAsFixed(4)} at $timeStr',
        notificationDetails,
        payload: 'location_update_${position.timestamp.toIso8601String()}',
      );

      print('✅ Notification shown: #$_notificationId');
      developer.log('Notification shown: #$_notificationId', name: 'NotificationService');
    } catch (e) {
      print('❌ Error showing notification: $e');
      developer.log('Error showing notification', name: 'NotificationService', error: e);
    }
  }

  // Show tracking started notification
  static Future<void> showTrackingStartedNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'location_tracking',
        'Location Tracking',
        channelDescription: 'Notifications for location tracking status',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF4CAF50),
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        999999, // Fixed ID for status notifications
        '✅ Location Tracking Started',
        'Your location will be tracked every 5 seconds',
        notificationDetails,
      );

      print('✅ Tracking started notification shown');
    } catch (e) {
      print('❌ Error showing tracking started notification: $e');
    }
  }

  // Show tracking stopped notification
  static Future<void> showTrackingStoppedNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'location_tracking',
        'Location Tracking',
        channelDescription: 'Notifications for location tracking status',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFF44336),
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        999999, // Fixed ID for status notifications
        '❌ Location Tracking Stopped',
        'Location tracking has been disabled',
        notificationDetails,
      );

      print('✅ Tracking stopped notification shown');
    } catch (e) {
      print('❌ Error showing tracking stopped notification: $e');
    }
  }

  // Show persistent notification (for foreground service)
  static Future<void> showPersistentNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'location_tracking_persistent',
        'Location Tracking Active',
        channelDescription: 'Persistent notification for active location tracking',
        importance: Importance.low,
        priority: Priority.low,
        icon: '@mipmap/ic_launcher',
        ongoing: true,
        autoCancel: false,
        showProgress: true,
        indeterminate: true,
        playSound: false,
        enableVibration: false,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        888888, // Fixed ID for persistent notification
        '📍 Location Tracking Active',
        'Tap to open app',
        notificationDetails,
      );

      print('✅ Persistent notification shown');
    } catch (e) {
      print('❌ Error showing persistent notification: $e');
    }
  }

  // Cancel persistent notification
  static Future<void> cancelPersistentNotification() async {
    try {
      await _notifications.cancel(888888);
      print('✅ Persistent notification cancelled');
    } catch (e) {
      print('❌ Error cancelling persistent notification: $e');
    }
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }
}
