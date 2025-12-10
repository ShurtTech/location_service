import 'package:dartz/dartz.dart';
import '../repositories/location_repository.dart';

class StartLocationTracking {
  final LocationRepository repository;

  StartLocationTracking(this.repository);

  Future<Either<String, void>> call(String authToken) async {
    return await repository.startLocationTracking(authToken);
  }
}
