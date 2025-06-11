// Base Exception
abstract class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException({required this.message, this.prefix});

  @override
  String toString() {
    return "$prefix$message";
  }
}

// Network related exceptions
class NetworkException extends AppException {
  NetworkException({String message = 'No internet connection'})
      : super(message: message, prefix: 'Network Error: ');
}

class TimeoutException extends AppException {
  TimeoutException({String message = 'Connection timeout'})
      : super(message: message, prefix: 'Timeout Error: ');
}

// Server related exceptions
class ServerException extends AppException {
  ServerException({String message = 'Internal server error'})
      : super(message: message, prefix: 'Server Error: ');
}

class BadRequestException extends AppException {
  BadRequestException({String? message})
      : super(message: message ?? 'Bad request', prefix: 'Invalid Request: ');
}

class UnauthorizedException extends AppException {
  UnauthorizedException({String? message})
      : super(message: message ?? 'Unauthorized', prefix: 'Unauthorized: ');
}

class ForbiddenException extends AppException {
  ForbiddenException({String? message})
      : super(message: message ?? 'Forbidden', prefix: 'Forbidden: ');
}

class NotFoundException extends AppException {
  NotFoundException({String? message})
      : super(message: message ?? 'Not found', prefix: 'Not Found: ');
}

class RequestCancelledException extends AppException {
  RequestCancelledException({String message = 'Request cancelled'})
      : super(message: message, prefix: 'Request Cancelled: ');
}

// Cache related exceptions
class CacheException extends AppException {
  CacheException({String message = 'Cache error'})
      : super(message: message, prefix: 'Cache Error: ');
}

// Authentication related exceptions
class AuthenticationException extends AppException {
  AuthenticationException({String message = 'Authentication failed'})
      : super(message: message, prefix: 'Authentication Error: ');
}
