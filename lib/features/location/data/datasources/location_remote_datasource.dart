import 'package:dio/dio.dart';
import '../models/location_model.dart';
import '../../domain/entities/location_entity.dart';

abstract class LocationRemoteDataSource {
  Future<void> sendLocation(LocationEntity location);
  Future<List<LocationModel>> getLocationHistory({
    required String startDate,
    required String endDate,
  });
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  LocationRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<void> sendLocation(LocationEntity location) async {
    try {
      final locationModel = LocationModel.fromEntity(location);
      
      final response = await dio.post(
        '$baseUrl/api/location/update',
        data: locationModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send location: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access forbidden');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error sending location: $e');
    }
  }

  @override
  Future<List<LocationModel>> getLocationHistory({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/location/history',
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['locations'] ?? [];
        return data.map((json) => LocationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch location history');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching location history: $e');
    }
  }
}
