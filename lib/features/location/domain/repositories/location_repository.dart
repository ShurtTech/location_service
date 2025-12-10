import 'package:dartz/dartz.dart';
import '../entities/location_entity.dart';

abstract class LocationRepository {
  Future<Either<String, LocationEntity>> getCurrentLocation();
  Future<Either<String, void>> sendLocationToServer(LocationEntity location);
  Future<Either<String, void>> startLocationTracking(String authToken);
  Future<Either<String, void>> stopLocationTracking();
  Future<bool> isTrackingActive();
  Future<Either<String, List<LocationEntity>>> getLocationHistory({
    required String startDate,
    required String endDate,
  });
}
