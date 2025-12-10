import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartTrackingEvent extends LocationEvent {
  final String authToken;

  StartTrackingEvent(this.authToken);

  @override
  List<Object?> get props => [authToken];
}

class StopTrackingEvent extends LocationEvent {}

class CheckTrackingStatusEvent extends LocationEvent {}

class GetCurrentLocationEvent extends LocationEvent {}

class SendLocationEvent extends LocationEvent {}
