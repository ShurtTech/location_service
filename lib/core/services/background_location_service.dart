import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'location_service.dart';
import 'dart:developer' as developer;

class BackgroundLocationService {
  static const String locationTrackingTask = 'location_tracking_task';
  static const String _isTrackingKey = 'is_tracking_location';
  static const String _authTokenKey = 'auth_token';
  static bool _isWorkmanagerInitialized = false;

  // Initialize Workmanager lazily
  static Future<void> _initializeWorkmanager() async {
    if (_isWorkmanagerInitialized) return;

    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
      _isWorkmanagerInitialized = true;
      print('✅ Workmanager initialized on demand');
    } catch (e) {
      print('⚠️ Workmanager initialization failed: $e');
      throw Exception('Failed to initialize Workmanager: $e');
    }
  }

  // Start background location tracking
  static Future<void> startTracking(String authToken) async {
    try {
      // Initialize Workmanager first
      await _initializeWorkmanager();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isTrackingKey, true);
      await prefs.setString(_authTokenKey, authToken);

      // Cancel any existing tasks first
      await Workmanager().cancelAll();

      // Register periodic task
      await Workmanager().registerPeriodicTask(
        locationTrackingTask,
        locationTrackingTask,
        frequency: Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: Duration(seconds: 10),
      );

      // Register one-time task for immediate execution
      await Workmanager().registerOneOffTask(
        'location_tracking_immediate',
        locationTrackingTask,
        initialDelay: Duration(seconds: 5),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );

      developer.log('✅ Location tracking started', name: 'LocationService');
      print('✅ Location tracking started');
    } catch (e) {
      developer.log('❌ Failed to start tracking: $e', name: 'LocationService');
      print('❌ Failed to start tracking: $e');
      rethrow;
    }
  }

  // Rest of your code remains the same...
  static Future<void> stopTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isTrackingKey, false);
    await prefs.remove(_authTokenKey);

    try {
      await Workmanager().cancelAll();
    } catch (e) {
      print('⚠️ Error cancelling workmanager tasks: $e');
    }

    developer.log('❌ Location tracking stopped', name: 'LocationService');
    print('❌ Location tracking stopped');
  }

  static Future<bool> isTracking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isTrackingKey) ?? false;
  }

  static Future<void> sendLocationUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isTracking = prefs.getBool(_isTrackingKey) ?? false;

      developer.log('🔍 Checking tracking status: $isTracking', name: 'LocationService');

      if (!isTracking) {
        developer.log('⚠️ Tracking disabled, skipping', name: 'LocationService');
        print('⚠️ Tracking is disabled, skipping location update');
        return;
      }

      developer.log('📍 Getting current location...', name: 'LocationService');

      Position? position = await LocationService.getCurrentLocation();

      if (position == null) {
        developer.log('⚠️ Current location null, trying last known', name: 'LocationService');
        position = await LocationService.getLastKnownLocation();
      }

      if (position != null) {
        developer.log(
          '✅ Location obtained: ${position.latitude}, ${position.longitude}',
          name: 'LocationService',
        );

        _printLocationToTerminal(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          speed: position.speed,
          timestamp: position.timestamp,
        );

        await _storeLocationLocally(position);
      } else {
        developer.log('❌ Failed to get location', name: 'LocationService');
        print('❌ Failed to get any location');
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error in sendLocationUpdate',
        name: 'LocationService',
        error: e,
        stackTrace: stackTrace,
      );
      print('❌ Error in sendLocationUpdate: $e');
    }
  }

  static void _printLocationToTerminal({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double altitude,
    required double speed,
    required DateTime timestamp,
  }) {
    final output = '''
============================================================
📍 LOCATION UPDATE - ${timestamp.toLocal()}
============================================================
🕒 Timestamp: ${timestamp.toLocal()}
🌍 Latitude: $latitude
🌍 Longitude: $longitude
📏 Accuracy: ${accuracy.toStringAsFixed(2)} meters
⛰️  Altitude: ${altitude.toStringAsFixed(2)} meters
🚗 Speed: ${speed.toStringAsFixed(2)} m/s (${(speed * 3.6).toStringAsFixed(2)} km/h)
🔗 Google Maps: https://www.google.com/maps?q=$latitude,$longitude
============================================================
''';

    print(output);
    developer.log(output, name: 'LocationUpdate');
  }

  static Future<void> _storeLocationLocally(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationHistory = prefs.getStringList('location_history') ?? [];

      final locationData = '${position.timestamp.toIso8601String()},'
          '${position.latitude},'
          '${position.longitude},'
          '${position.accuracy},'
          '${position.altitude},'
          '${position.speed}';

      locationHistory.add(locationData);

      if (locationHistory.length > 500) {
        locationHistory.removeAt(0);
      }

      await prefs.setStringList('location_history', locationHistory);

      developer.log(
        '💾 Location saved (Total: ${locationHistory.length})',
        name: 'LocationService',
      );
      print('💾 Location saved to local storage (Total: ${locationHistory.length})');
    } catch (e) {
      developer.log('❌ Error storing location', name: 'LocationService', error: e);
      print('❌ Error storing location locally: $e');
    }
  }

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
      return [];
    }
  }

  static Future<void> clearLocationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('location_history');
    print('🗑️  Location history cleared');
  }
}

// Top-level callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await BackgroundLocationService.sendLocationUpdate();
      return Future.value(true);
    } catch (e) {
      print('❌ Background task failed: $e');
      return Future.value(false);
    }
  });
}
