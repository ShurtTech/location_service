import 'package:dartz/dartz.dart';
import '../repositories/location_repository.dart';

class StopLocationTracking {
  final LocationRepository repository;

  StopLocationTracking(this.repository);

  Future<Either<String, void>> call() async {
    return await repository.stopLocationTracking();
  }
}
