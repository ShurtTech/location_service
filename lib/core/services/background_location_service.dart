import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'location_service.dart';
import 'notification_service.dart';
import 'dart:developer' as developer;

// IMPORTANT: Top-level function for background execution
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      developer.log('🔄 Background task started: $task', name: 'BackgroundTask');
      print('🔄 Background task started: $task');

      // Check if tracking is enabled
      final prefs = await SharedPreferences.getInstance();
      final isTracking = prefs.getBool('is_tracking_location') ?? false;

      if (!isTracking) {
        print('⚠️ Tracking disabled, skipping');
        return Future.value(true);
      }

      // Get location
      Position? position = await LocationService.getCurrentLocation();

      if (position == null) {
        position = await LocationService.getLastKnownLocation();
      }

      if (position != null) {
        // Get current count
        final count = prefs.getInt('location_count') ?? 0;
        final newCount = count + 1;
        await prefs.setInt('location_count', newCount);

        // Print to log
        _printLocation(position, newCount);

        // Store location
        await _storeLocation(position, prefs);

        // Show notification
        await NotificationService.initialize();
        await NotificationService.showLocationNotification(
          position: position,
          locationCount: newCount,
        );

        print('✅ Background task completed successfully');
        return Future.value(true);
      } else {
        print('❌ Failed to get location');
        return Future.value(false);
      }
    } catch (e) {
      print('❌ Background task error: $e');
      return Future.value(false);
    }
  });
}

void _printLocation(Position position, int count) {
  final now = DateTime.now();
  final output = '''
============================================================
📍 BACKGROUND UPDATE #$count - ${now.hour}:${now.minute}:${now.second}
============================================================
🌍 Lat: ${position.latitude.toStringAsFixed(6)}
🌍 Lng: ${position.longitude.toStringAsFixed(6)}
📏 Accuracy: ${position.accuracy.toStringAsFixed(2)}m
============================================================
''';
  print(output);
  developer.log(output, name: 'BackgroundLocation');
}

Future<void> _storeLocation(Position position, SharedPreferences prefs) async {
  try {
    final history = prefs.getStringList('location_history') ?? [];
    final data = '${position.timestamp.toIso8601String()},'
        '${position.latitude},${position.longitude},'
        '${position.accuracy},${position.altitude},${position.speed}';
    
    history.add(data);
    if (history.length > 500) history.removeAt(0);
    
    await prefs.setStringList('location_history', history);
    print('💾 Location saved (Total: ${history.length})');
  } catch (e) {
    print('❌ Error storing: $e');
  }
}

class BackgroundLocationTracker {
  static const String _taskName = 'location_tracking_task';

  static Future<void> startTracking(String authToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_tracking_location', true);
      await prefs.setString('auth_token', authToken);
      await prefs.setInt('location_count', 0);

      // Initialize Workmanager
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

      // Cancel existing tasks
      await Workmanager().cancelAll();

      // Register periodic task (15 minutes minimum on Android)
      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency: Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );

      // Register immediate one-time task
      await Workmanager().registerOneOffTask(
        '${_taskName}_immediate',
        _taskName,
        initialDelay: Duration(seconds: 10),
      );

      // Show notifications
      await NotificationService.initialize();
      await NotificationService.showTrackingStartedNotification();
      await NotificationService.showPersistentNotification();

      print('✅ Background tracking started');
    } catch (e) {
      print('❌ Failed to start background tracking: $e');
      rethrow;
    }
  }

  static Future<void> stopTracking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_tracking_location', false);

      await Workmanager().cancelAll();
      
      await NotificationService.cancelPersistentNotification();
      await NotificationService.showTrackingStoppedNotification();

      print('❌ Background tracking stopped');
    } catch (e) {
      print('❌ Error stopping tracking: $e');
    }
  }

  static Future<bool> isTracking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_tracking_location') ?? false;
  }
}
