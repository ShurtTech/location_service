import 'package:equatable/equatable.dart';
import '../../domain/entities/location_entity.dart';

abstract class LocationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class TrackingActive extends LocationState {
  final LocationEntity? currentLocation;

  TrackingActive({this.currentLocation});

  @override
  List<Object?> get props => [currentLocation];
}

class TrackingInactive extends LocationState {}

class LocationError extends LocationState {
  final String message;

  LocationError(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationSuccess extends LocationState {
  final LocationEntity location;

  LocationSuccess(this.location);

  @override
  List<Object?> get props => [location];
}
