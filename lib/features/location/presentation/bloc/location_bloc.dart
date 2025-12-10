import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_tracking/features/location/domain/usecases/stop_location_tracking.dart';
import '../../domain/usecases/start_location_tracking.dart';
import '../../domain/repositories/location_repository.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final StartLocationTracking startTracking;
  final StopLocationTracking stopTracking;
  final LocationRepository repository;

  LocationBloc({
    required this.startTracking,
    required this.stopTracking,
    required this.repository,
  }) : super(LocationInitial()) {
    on<StartTrackingEvent>(_onStartTracking);
    on<StopTrackingEvent>(_onStopTracking);
    on<CheckTrackingStatusEvent>(_onCheckTrackingStatus);
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
  }

  Future<void> _onStartTracking(
    StartTrackingEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    final result = await startTracking(event.authToken);
    
    result.fold(
      (error) => emit(LocationError(error)),
      (_) => emit(TrackingActive()),
    );
  }

  Future<void> _onStopTracking(
    StopTrackingEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    final result = await stopTracking();
    
    result.fold(
      (error) => emit(LocationError(error)),
      (_) => emit(TrackingInactive()),
    );
  }

  Future<void> _onCheckTrackingStatus(
    CheckTrackingStatusEvent event,
    Emitter<LocationState> emit,
  ) async {
    final isActive = await repository.isTrackingActive();
    
    if (isActive) {
      emit(TrackingActive());
    } else {
      emit(TrackingInactive());
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    final result = await repository.getCurrentLocation();
    
    result.fold(
      (error) => emit(LocationError(error)),
      (location) => emit(LocationSuccess(location)),
    );
  }
}
