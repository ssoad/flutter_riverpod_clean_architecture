import 'package:dio/dio.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: 30000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 30000);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  // GET request
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // POST request
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // PUT request
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // DELETE request
  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // Handle Dio errors
  void _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException();
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400:
            throw BadRequestException(message: e.response?.data['message']);
          case 401:
            throw UnauthorizedException(message: e.response?.data['message']);
          case 403:
            throw ForbiddenException(message: e.response?.data['message']);
          case 404:
            throw NotFoundException(message: e.response?.data['message']);
          case 500:
          case 501:
          case 502:
          case 503:
            throw ServerException(message: e.response?.data['message']);
          default:
            throw ServerException(
                message: e.response?.data['message'] ?? 'Unknown error occurred');
        }
      case DioExceptionType.cancel:
        throw RequestCancelledException();
      case DioExceptionType.unknown:
        if (e.error.toString().contains('SocketException')) {
          throw NetworkException();
        }
        throw ServerException(message: 'Unknown error occurred');
      default:
        throw ServerException(message: 'Unknown error occurred');
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
