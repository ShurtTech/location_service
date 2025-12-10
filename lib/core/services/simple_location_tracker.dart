import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_service.dart';
import 'notification_service.dart';
import 'dart:developer' as developer;

class SimpleLocationTracker {
  static const String _isTrackingKey = 'is_tracking_location';
  static Timer? _timer;
  static bool _isTracking = false;
  static int _locationUpdateCount = 0;

  // Start location tracking with timer
  static Future<void> startTracking(String authToken) async {
    if (_isTracking) {
      print('⚠️ Tracking already active');
      return;
    }

    try {
      // Initialize notifications
      await NotificationService.initialize();

      // Request location permissions first
      print('📍 Requesting location permissions...');
      final hasPermission = await _requestLocationPermissions();
      
      if (!hasPermission) {
        throw Exception('Location permissions denied. Please grant location access in settings.');
      }

      // Check if location service is enabled
      print('📍 Checking location services...');
      final isEnabled = await _checkLocationService();
      
      if (!isEnabled) {
        throw Exception('Location services are disabled. Please enable location services.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isTrackingKey, true);
      await prefs.setString('auth_token', authToken);

      _isTracking = true;
      _locationUpdateCount = 0;

      // Show persistent notification
      await NotificationService.showPersistentNotification();

      // Show tracking started notification
      await NotificationService.showTrackingStartedNotification();

      // Start periodic location updates every 5 seconds
      _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        if (!_isTracking) {
          timer.cancel();
          return;
        }

        try {
          final position = await LocationService.getCurrentLocation();
          if (position != null) {
            _locationUpdateCount++;
            
            // Print to console
            _printLocationToTerminal(position);
            
            // Store locally
            await _storeLocationLocally(position);
            
            // Show notification
            await NotificationService.showLocationNotification(
              position: position,
              locationCount: _locationUpdateCount,
            );
          }
        } catch (e) {
          print('❌ Error getting location: $e');
          developer.log('Error getting location', name: 'LocationTracker', error: e);
        }
      });

      // Also get immediate location
      print('📍 Getting initial location...');
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        _locationUpdateCount++;
        _printLocationToTerminal(position);
        await _storeLocationLocally(position);
        await NotificationService.showLocationNotification(
          position: position,
          locationCount: _locationUpdateCount,
        );
      } else {
        print('⚠️ Could not get initial location, will retry in 5 seconds');
      }

      print('✅ Simple location tracking started (5-second interval)');
      developer.log('✅ Location tracking started', name: 'LocationTracker');
    } catch (e) {
      print('❌ Failed to start tracking: $e');
      developer.log('Failed to start tracking', name: 'LocationTracker', error: e);
      _isTracking = false;
      rethrow;
    }
  }

  // Request location permissions with detailed feedback
  static Future<bool> _requestLocationPermissions() async {
    try {
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
        print('❌ Location permission not granted: $locationStatus');
        return false;
      }

      print('✅ Location permission granted');

      var alwaysLocationStatus = await Permission.locationAlways.status;
      print('📍 Background location permission status: $alwaysLocationStatus');

      if (alwaysLocationStatus.isDenied) {
        print('📍 Requesting background location permission...');
        alwaysLocationStatus = await Permission.locationAlways.request();
        print('📍 Background location permission result: $alwaysLocationStatus');
      }

      if (alwaysLocationStatus.isPermanentlyDenied) {
        print('⚠️ Background location permission permanently denied. Opening settings...');
        await openAppSettings();
        await Future.delayed(Duration(seconds: 2));
        alwaysLocationStatus = await Permission.locationAlways.status;
      }

      if (alwaysLocationStatus.isGranted) {
        print('✅ Background location permission granted');
      } else {
        print('⚠️ Background location not granted, will use foreground location only');
      }

      return locationStatus.isGranted;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      developer.log('Error requesting permissions', name: 'LocationTracker', error: e);
      return false;
    }
  }

  // Check if location service is enabled
  static Future<bool> _checkLocationService() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!isEnabled) {
        print('⚠️ Location services are disabled');
        
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

  // Stop tracking
  static Future<void> stopTracking() async {
    _isTracking = false;
    _timer?.cancel();
    _timer = null;
    _locationUpdateCount = 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isTrackingKey, false);

    // Cancel persistent notification
    await NotificationService.cancelPersistentNotification();

    // Show tracking stopped notification
    await NotificationService.showTrackingStoppedNotification();

    print('❌ Simple location tracking stopped');
    developer.log('❌ Location tracking stopped', name: 'LocationTracker');
  }

  // Check if tracking
  static Future<bool> isTracking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isTrackingKey) ?? false;
  }

  // Get current tracking status
  static bool isCurrentlyTracking() {
    return _isTracking;
  }

  // Print location
  static void _printLocationToTerminal(Position position) {
    final now = DateTime.now();
    final output = '''
============================================================
📍 LOCATION UPDATE #$_locationUpdateCount - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}
============================================================
🕒 Time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}
📅 Date: ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}
🌍 Latitude: ${position.latitude.toStringAsFixed(6)}
🌍 Longitude: ${position.longitude.toStringAsFixed(6)}
📏 Accuracy: ${position.accuracy.toStringAsFixed(2)} meters
⛰️  Altitude: ${position.altitude.toStringAsFixed(2)} meters
🚗 Speed: ${(position.speed * 3.6).toStringAsFixed(2)} km/h
🧭 Heading: ${position.heading.toStringAsFixed(2)}°
🔗 Google Maps: https://maps.google.com/?q=${position.latitude},${position.longitude}
============================================================
''';

    print(output);
    developer.log(output, name: 'LocationUpdate');
  }

  // Store location locally
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
      print('💾 Location saved (Total: ${locationHistory.length})');
      developer.log('Location saved (Total: ${locationHistory.length})', name: 'LocationTracker');
    } catch (e) {
      print('❌ Error storing location: $e');
      developer.log('Error storing location', name: 'LocationTracker', error: e);
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
      print('🗑️  Location history cleared');
      developer.log('Location history cleared', name: 'LocationTracker');
    } catch (e) {
      print('❌ Error clearing location history: $e');
      developer.log('Error clearing location history', name: 'LocationTracker', error: e);
    }
  }
}
