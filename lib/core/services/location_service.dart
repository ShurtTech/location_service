import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

class LocationService {
  static Future<bool> requestLocationPermissions() async {
    try {
      // Request location when in use permission first
      var status = await Permission.location.status;
      developer.log('Location permission status: $status', name: 'LocationService');

      if (status.isDenied) {
        status = await Permission.location.request();
        developer.log('Location permission requested: $status', name: 'LocationService');
      }

      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      if (!status.isGranted) {
        return false;
      }

      // Request always location permission for background tracking
      var alwaysStatus = await Permission.locationAlways.status;
      developer.log('Location always permission status: $alwaysStatus', name: 'LocationService');

      if (alwaysStatus.isDenied) {
        alwaysStatus = await Permission.locationAlways.request();
        developer.log('Location always permission requested: $alwaysStatus', name: 'LocationService');
      }

      if (alwaysStatus.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      return alwaysStatus.isGranted;
    } catch (e) {
      developer.log('Error requesting permissions', name: 'LocationService', error: e);
      return false;
    }
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      developer.log('Requesting current location...', name: 'LocationService');

      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log('Location services disabled', name: 'LocationService');
        throw Exception('Location services are disabled');
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      developer.log(
        'Location obtained: ${position.latitude}, ${position.longitude}',
        name: 'LocationService',
      );

      return position;
    } catch (e) {
      developer.log('Error getting current location', name: 'LocationService', error: e);
      print('Error getting location: $e');
      return null;
    }
  }

  static Future<Position?> getLastKnownLocation() async {
    try {
      developer.log('Getting last known location...', name: 'LocationService');
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        developer.log(
          'Last known location: ${position.latitude}, ${position.longitude}',
          name: 'LocationService',
        );
      }
      return position;
    } catch (e) {
      developer.log('Error getting last known location', name: 'LocationService', error: e);
      print('Error getting last known location: $e');
      return null;
    }
  }
}
