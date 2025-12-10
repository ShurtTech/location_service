import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Features - Location
import 'features/location/data/datasources/location_remote_datasource.dart';
import 'features/location/data/repositories/location_repository_impl.dart';
import 'features/location/domain/repositories/location_repository.dart';
import 'features/location/domain/usecases/start_location_tracking.dart';
import 'features/location/domain/usecases/stop_location_tracking.dart';
import 'features/location/domain/usecases/get_current_location.dart';
import 'features/location/domain/usecases/send_location_to_server.dart';
import 'features/location/domain/usecases/check_tracking_status.dart';
import 'features/location/domain/usecases/get_location_history.dart';
import 'features/location/presentation/bloc/location_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Features - Location
  
  // Bloc
  getIt.registerFactory(
    () => LocationBloc(
      startTracking: getIt(),
      stopTracking: getIt(),
      repository: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => StartLocationTracking(getIt()));
  getIt.registerLazySingleton(() => StopLocationTracking(getIt()));
  getIt.registerLazySingleton(() => GetCurrentLocation(getIt()));
  getIt.registerLazySingleton(() => SendLocationToServer(getIt()));
  getIt.registerLazySingleton(() => CheckTrackingStatus(getIt()));
  getIt.registerLazySingleton(() => GetLocationHistory(getIt()));

  // Repository
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(
      dio: getIt(),
      baseUrl: 'YOUR_BASE_URL', // Replace with your API base URL
    ),
  );

  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // Dio client with interceptors
  getIt.registerLazySingleton(() {
    final dio = Dio();
    
    // Add interceptor to attach auth token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = getIt<SharedPreferences>();
          final token = prefs.getString('auth_token');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle token expiration
          if (error.response?.statusCode == 401) {
            // Trigger logout or token refresh
            final prefs = getIt<SharedPreferences>();
            await prefs.remove('auth_token');
          }
          return handler.next(error);
        },
      ),
    );
    
    return dio;
  });
}
