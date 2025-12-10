import 'package:dartz/dartz.dart';
import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocation {
  final LocationRepository repository;

  GetCurrentLocation(this.repository);

  Future<Either<String, LocationEntity>> call() async {
    return await repository.getCurrentLocation();
  }
}
