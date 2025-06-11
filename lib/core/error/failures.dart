import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection', super.statusCode});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred', super.statusCode});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Connection timeout', super.statusCode});
}

// Data failures
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache failure', super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation error', super.statusCode});
}

// Auth failures
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed', super.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Unauthorized access', super.statusCode});
}

class InputFailure extends Failure {
  const InputFailure({super.message = 'Invalid input', super.statusCode});
}
