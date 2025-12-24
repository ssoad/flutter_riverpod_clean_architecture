import 'package:fpdart/fpdart.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import '../../core/error/failures.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  // GET request
  Future<Either<Failure, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  // POST request
  Future<Either<Failure, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  // PUT request
  Future<Either<Failure, dynamic>> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  // DELETE request
  Future<Either<Failure, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  // Handle Dio errors
  Failure _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerFailure(message: 'Connection timeout');
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400:
            return ServerFailure(
              message: e.response?.data['message'] ?? 'Bad Request',
            );
          case 401:
            return UnauthorizedFailure(
              message: e.response?.data['message'] ?? 'Unauthorized',
            );
          case 403:
            return ServerFailure(
              message: e.response?.data['message'] ?? 'Forbidden',
            );
          case 404:
            return ServerFailure(
              message: e.response?.data['message'] ?? 'Not Found',
            );
          case 500:
          case 501:
          case 502:
          case 503:
            return ServerFailure(
              message: e.response?.data['message'] ?? 'Server Error',
            );
          default:
            return ServerFailure(
              message: e.response?.data['message'] ?? 'Unknown error occurred',
            );
        }
      case DioExceptionType.cancel:
        return const ServerFailure(message: 'Request cancelled');
      case DioExceptionType.unknown:
        if (e.error.toString().contains('SocketException')) {
          return const ServerFailure(message: 'No internet connection');
        }
        return const ServerFailure(message: 'Unknown error occurred');
      default:
        return const ServerFailure(message: 'Unknown error occurred');
    }
  }

  // Add token to headers
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove token from headers
  void removeToken() {
    _dio.options.headers.remove('Authorization');
  }
}
