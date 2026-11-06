import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.10:8000/api';

  static final GetStorage _box = GetStorage();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _box.read('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

  /// Ambil pesan error yang ramah dari DioException
  static String errorMessage(
    DioException e, {
    String fallback = 'Terjadi kesalahan.',
  }) {
    if (e.response != null) {
      final data = e.response?.data;
      if (e.response?.statusCode == 422 &&
          data is Map &&
          data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
      }

      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return fallback;
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server.';
    }

    return fallback;
  }
}