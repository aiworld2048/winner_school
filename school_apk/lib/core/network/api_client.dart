import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../providers/session_provider.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  ApiException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'Unable to reach the server. Please check your internet connection or try again shortly.',
        );
      case DioExceptionType.badResponse:
        return ApiException(
          error.response?.data?['message']?.toString() ?? 'Server responded with an error.',
          statusCode: error.response?.statusCode,
        );
      default:
        return ApiException(error.message ?? 'Unexpected network error.', statusCode: error.response?.statusCode);
    }
  }
}

final dioProvider = Provider<Dio>((ref) {
  final session = ref.watch(sessionManagerProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = session.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
);

