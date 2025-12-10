import '../repositories/location_repository.dart';

class CheckTrackingStatus {
  final LocationRepository repository;

  CheckTrackingStatus(this.repository);

  Future<bool> call() async {
    return await repository.isTrackingActive();
  }
}
