import 'package:dartz/dartz.dart';
import 'package:location_tracking/core/services/background_location_service.dart';
import 'package:location_tracking/core/services/location_service.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, LocationEntity>> getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      
      if (position == null) {
        return Left('Failed to get location');
      }

      return Right(LocationEntity(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      ));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> sendLocationToServer(
    LocationEntity location,
  ) async {
    try {
      await remoteDataSource.sendLocation(location);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> startLocationTracking(String authToken) async {
    try {
      // Request permissions
      final hasPermission = await LocationService.requestLocationPermissions();
      
      if (!hasPermission) {
        return Left('Location permission denied');
      }

      // Check if location service is enabled
      final isEnabled = await LocationService.isLocationServiceEnabled();
      
      if (!isEnabled) {
        return Left('Location services are disabled');
      }

      await BackgroundLocationService.startTracking(authToken);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> stopLocationTracking() async {
    try {
      await BackgroundLocationService.stopTracking();
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<bool> isTrackingActive() async {
    return await BackgroundLocationService.isTracking();
  }

  @override
  Future<Either<String, List<LocationEntity>>> getLocationHistory({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final locationModels = await remoteDataSource.getLocationHistory(
        startDate: startDate,
        endDate: endDate,
      );
      
      // Convert models to entities
      final entities = locationModels
          .map((model) => LocationEntity(
                latitude: model.latitude,
                longitude: model.longitude,
                accuracy: model.accuracy,
                timestamp: model.timestamp,
              ))
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
