import 'package:dartz/dartz.dart';
import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class GetLocationHistory {
  final LocationRepository repository;

  GetLocationHistory(this.repository);

  Future<Either<String, List<LocationEntity>>> call({
    required String startDate,
    required String endDate,
  }) async {
    return await repository.getLocationHistory(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
