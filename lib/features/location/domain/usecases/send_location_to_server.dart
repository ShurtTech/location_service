import 'package:dartz/dartz.dart';
import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class SendLocationToServer {
  final LocationRepository repository;

  SendLocationToServer(this.repository);

  Future<Either<String, void>> call(LocationEntity location) async {
    return await repository.sendLocationToServer(location);
  }
}
