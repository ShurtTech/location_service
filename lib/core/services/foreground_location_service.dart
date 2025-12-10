// core/services/foreground_location_service.dart

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_service.dart';

class ForegroundLocationService {
  static Timer? _locationTimer;
  static bool _isTracking = false;
  static StreamSubscription<Position>? _positionStreamSubscription;

  // Start foreground location tracking every 5 seconds
  static Future<void> startTracking() async {
    if (_isTracking) {
      print('⚠️ Foreground tracking already active');
      return;
    }

    _isTracking = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('foreground_tracking', true);

    print('✅ Foreground location tracking started (5-second interval)');

    // Option 1: Using Timer (Recommended for testing)
    _locationTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (!_isTracking) {
        timer.cancel();
        return;
      }

      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        _printLocationToTerminal(position);
        await _storeLocationLocally(position);
      }
    });

    // Option 2: Using Position Stream (Alternative - more battery intensive)
    // _startPositionStream();
  }

  // Alternative: Start position stream for continuous tracking
  static void _startPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _printLocationToTerminal(position);
        _storeLocationLocally(position);
      },
      onError: (error) {
        print('❌ Position stream error: $error');
      },
    );
  }

  // Stop foreground location tracking
  static Future<void> stopTracking() async {
    _isTracking = false;
    _locationTimer?.cancel();
    _locationTimer = null;
    
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('foreground_tracking', false);

    print('❌ Foreground location tracking stopped');
  }

  // Check if tracking is active
  static bool isTracking() => _isTracking;

  // Print location to terminal
  static void _printLocationToTerminal(Position position) {
    final now = DateTime.now();
    print('\n' + '🟢' * 30);
    print('📍 LIVE LOCATION UPDATE');
    print('🟢' * 30);
    print('🕒 Time: ${now.hour}:${now.minute}:${now.second}');
    print('📅 Date: ${now.day}/${now.month}/${now.year}');
    print('🌍 Coordinates: ${position.latitude}, ${position.longitude}');
    print('📏 Accuracy: ${position.accuracy.toStringAsFixed(2)}m');
    print('⛰️  Altitude: ${position.altitude.toStringAsFixed(2)}m');
    print('🚗 Speed: ${(position.speed * 3.6).toStringAsFixed(2)} km/h');
    print('🧭 Heading: ${position.heading.toStringAsFixed(2)}°');
    print('🔗 Maps: https://maps.google.com/?q=${position.latitude},${position.longitude}');
    print('🟢' * 30 + '\n');
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
    } catch (e) {
      print('❌ Error storing location: $e');
    }
  }
}
