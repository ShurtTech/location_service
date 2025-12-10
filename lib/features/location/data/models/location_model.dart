import '../../domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required double latitude,
    required double longitude,
    required double accuracy,
    required DateTime timestamp,
  }) : super(
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
          timestamp: timestamp,
        );

  // From JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // From Entity
  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      accuracy: entity.accuracy,
      timestamp: entity.timestamp,
    );
  }

  // From Position (geolocator)
  factory LocationModel.fromPosition(
    double latitude,
    double longitude,
    double accuracy,
    DateTime timestamp,
  ) {
    return LocationModel(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: timestamp,
    );
  }
}
