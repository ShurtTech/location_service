import 'dart:async';
import 'dart:isolate';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'location_service.dart';
import 'notification_service.dart';
import 'dart:developer' as developer;

// Background callback - runs even when app is killed
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

// Task handler for background execution
class LocationTaskHandler extends TaskHandler {
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('🚀 Foreground service started');
    
    // Start periodic location updates every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await _updateLocation();
    });
    
    // Get immediate location
    await _updateLocation();
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    // This runs periodically - we use Timer instead for more control
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTaskRemoved) async {
    print('❌ Foreground service stopped');
    _timer?.cancel();
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Handle notification button press if needed
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
  }

  @override
  void onNotificationDismissed() {
    // Handle notification dismissed
  }

  Future<void> _updateLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isTracking = prefs.getBool('is_tracking_location') ?? false;

      if (!isTracking) {
        print('⚠️ Tracking disabled');
        return;
      }

      Position? position = await LocationService.getCurrentLocation();

      if (position == null) {
        position = await LocationService.getLastKnownLocation();
      }

      if (position != null) {
        // Get count
        final count = prefs.getInt('location_count') ?? 0;
        final newCount = count + 1;
        await prefs.setInt('location_count', newCount);

        // Print to console
        _printLocation(position, newCount);

        // Store location
        await _storeLocation(position, prefs);

        // Show notification
        await NotificationService.initialize();
        await NotificationService.showLocationNotification(
          position: position,
          locationCount: newCount,
        );

        // Update foreground notification
        FlutterForegroundTask.updateService(
          notificationTitle: '📍 Location Update #$newCount',
          notificationText: 'Lat: ${position.latitude.toStringAsFixed(4)}, '
              'Lng: ${position.longitude.toStringAsFixed(4)}',
        );
      }
    } catch (e) {
      print('❌ Error updating location: $e');
      developer.log('Error updating location', name: 'LocationTracker', error: e);
    }
  }

  void _printLocation(Position position, int count) {
    final now = DateTime.now();
    final output = '''
============================================================
📍 LOCATION UPDATE #$count - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}
============================================================
🌍 Lat: ${position.latitude.toStringAsFixed(6)}
🌍 Lng: ${position.longitude.toStringAsFixed(6)}
📏 Accuracy: ${position.accuracy.toStringAsFixed(2)}m
🚗 Speed: ${(position.speed * 3.6).toStringAsFixed(1)} km/h
⛰️  Altitude: ${position.altitude.toStringAsFixed(1)}m
🧭 Heading: ${position.heading.toStringAsFixed(1)}°
============================================================
''';
    print(output);
    developer.log(output, name: 'LocationUpdate');
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
}

class SimpleLocationTracker {
  static const String _isTrackingKey = 'is_tracking_location';

  // Start location tracking with foreground service
  static Future<void> startTracking(String authToken) async {
    try {
      print('📍 Starting location tracking...');

      // Request permissions
      final hasPermission = await _requestLocationPermissions();
      if (!hasPermission) {
        throw Exception('Location permissions denied. Please grant location permissions in settings.');
      }

      // Check location service
      final isEnabled = await _checkLocationService();
      if (!isEnabled) {
        throw Exception('Location services are disabled. Please enable location services.');
      }

      // Save tracking state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isTrackingKey, true);
      await prefs.setString('auth_token', authToken);
      await prefs.setInt('location_count', 0);

      // Initialize notifications
      await NotificationService.initialize();

      // Request battery optimization exemption
      await _requestIgnoreBatteryOptimization();

      // Initialize foreground service
    FlutterForegroundTask.init(
  androidNotificationOptions: AndroidNotificationOptions(
    channelId: 'location_tracking_service',
    channelName: 'Location Tracking Service',
    channelDescription: 'This notification appears when location tracking is running',
    onlyAlertOnce: true,
    channelImportance: NotificationChannelImportance.LOW,
    priority: NotificationPriority.LOW,
    // Do NOT use icon or iconData here anymore
  ),
  iosNotificationOptions: const IOSNotificationOptions(
    showNotification: true,
    playSound: false,
  ),
  foregroundTaskOptions: ForegroundTaskOptions(
    eventAction: ForegroundTaskEventAction.repeat(5000), // 5 seconds
    autoRunOnBoot: true,
    autoRunOnMyPackageReplaced: true,
    allowWakeLock: true,
    allowWifiLock: true,
  ),
);



      // Start foreground service
      final serviceResult = await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: '📍 Location Tracking Active',
        notificationText: 'Tracking your location every 5 seconds',
        callback: startCallback,
      );

      // Check if service started successfully
      if (serviceResult != null) {
        await NotificationService.showTrackingStartedNotification();
        print('✅ Location tracking started successfully');
        developer.log('✅ Location tracking started', name: 'LocationTracker');
      } else {
        throw Exception('Failed to start foreground service');
      }
    } catch (e) {
      print('❌ Failed to start tracking: $e');
      developer.log('Failed to start tracking', name: 'LocationTracker', error: e);
      rethrow;
    }
  }

  // Stop tracking
  static Future<void> stopTracking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isTrackingKey, false);

      final result = await FlutterForegroundTask.stopService();
      
      if (result != null) {
        print('✅ Foreground service stopped successfully');
      } else {
        print('⚠️ Error stopping foreground service');
      }

      await NotificationService.showTrackingStoppedNotification();

      print('❌ Location tracking stopped');
      developer.log('❌ Location tracking stopped', name: 'LocationTracker');
    } catch (e) {
      print('❌ Error stopping tracking: $e');
      developer.log('Error stopping tracking', name: 'LocationTracker', error: e);
    }
  }

  // Check if tracking
  static Future<bool> isTracking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isTrackingKey) ?? false;
  }

  // Request battery optimization exemption
  static Future<void> _requestIgnoreBatteryOptimization() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        print('📱 Requesting battery optimization exemption...');
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (e) {
      print('⚠️ Could not request battery optimization exemption: $e');
    }
  }

  // Request permissions
  static Future<bool> _requestLocationPermissions() async {
    try {
      print('📍 Checking location permissions...');
      
      var locationStatus = await Permission.location.status;
      print('📍 Location permission status: $locationStatus');
      
      if (locationStatus.isDenied) {
        print('📍 Requesting location permission...');
        locationStatus = await Permission.location.request();
        print('📍 Location permission result: $locationStatus');
      }
      
      if (locationStatus.isPermanentlyDenied) {
        print('⚠️ Location permission permanently denied. Opening settings...');
        await openAppSettings();
        await Future.delayed(Duration(seconds: 2));
        locationStatus = await Permission.location.status;
        
        if (!locationStatus.isGranted) {
          print('❌ Location permission still not granted');
          return false;
        }
      }
      
      if (!locationStatus.isGranted) {
        print('❌ Location permission not granted');
        return false;
      }

      print('✅ Location permission granted');

      // Try to get background location permission
      var alwaysStatus = await Permission.locationAlways.status;
      print('📍 Background location permission status: $alwaysStatus');
      
      if (alwaysStatus.isDenied) {
        print('📍 Requesting background location permission...');
        alwaysStatus = await Permission.locationAlways.request();
        print('📍 Background location permission result: $alwaysStatus');
      }

      if (alwaysStatus.isGranted) {
        print('✅ Background location permission granted');
      } else {
        print('⚠️ Background location not granted, will work in foreground only');
      }

      return locationStatus.isGranted;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      developer.log('Error requesting permissions', name: 'LocationTracker', error: e);
      return false;
    }
  }

  // Check location service
  static Future<bool> _checkLocationService() async {
    try {
      print('📍 Checking location services...');
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!isEnabled) {
        print('⚠️ Location services are disabled, attempting to open settings...');
        
        try {
          await Geolocator.openLocationSettings();
          print('📍 Opened location settings');
          
          await Future.delayed(Duration(seconds: 2));
          final isEnabledNow = await Geolocator.isLocationServiceEnabled();
          
          if (isEnabledNow) {
            print('✅ Location services enabled');
            return true;
          } else {
            print('❌ Location services still disabled');
            return false;
          }
        } catch (e) {
          print('⚠️ Could not open location settings: $e');
          return false;
        }
      }

      print('✅ Location services enabled');
      return true;
    } catch (e) {
      print('❌ Error checking location service: $e');
      developer.log('Error checking location service', name: 'LocationTracker', error: e);
      return false;
    }
  }

  // Get location history
  static Future<List<Map<String, dynamic>>> getLocationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationHistory = prefs.getStringList('location_history') ?? [];

      return locationHistory.map((data) {
        final parts = data.split(',');
        return {
          'timestamp': DateTime.parse(parts[0]),
          'latitude': double.parse(parts[1]),
          'longitude': double.parse(parts[2]),
          'accuracy': double.parse(parts[3]),
          'altitude': double.parse(parts[4]),
          'speed': double.parse(parts[5]),
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting location history: $e');
      developer.log('Error getting location history', name: 'LocationTracker', error: e);
      return [];
    }
  }

  // Clear history
  static Future<void> clearLocationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('location_history');
      await prefs.setInt('location_count', 0);
      print('🗑️  Location history cleared');
      developer.log('Location history cleared', name: 'LocationTracker');
    } catch (e) {
      print('❌ Error clearing location history: $e');
      developer.log('Error clearing location history', name: 'LocationTracker', error: e);
    }
  }

  // Get tracking statistics
  static Future<Map<String, dynamic>> getTrackingStatistics() async {
    try {
      final history = await getLocationHistory();
      
      if (history.isEmpty) {
        return {
          'totalLocations': 0,
          'firstUpdate': null,
          'lastUpdate': null,
          'averageAccuracy': 0.0,
          'maxSpeed': 0.0,
        };
      }

      final accuracies = history.map((loc) => loc['accuracy'] as double).toList();
      final speeds = history.map((loc) => loc['speed'] as double).toList();
      
      return {
        'totalLocations': history.length,
        'firstUpdate': history.first['timestamp'],
        'lastUpdate': history.last['timestamp'],
        'averageAccuracy': accuracies.reduce((a, b) => a + b) / accuracies.length,
        'maxSpeed': speeds.reduce((a, b) => a > b ? a : b) * 3.6, // Convert to km/h
      };
    } catch (e) {
      print('❌ Error getting statistics: $e');
      return {
        'totalLocations': 0,
        'firstUpdate': null,
        'lastUpdate': null,
        'averageAccuracy': 0.0,
        'maxSpeed': 0.0,
      };
    }
  }
}
