import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> execute({
    required String email,
    required String password,
  }) {
    // Add any validation logic here if needed
    if (email.isEmpty || password.isEmpty) {
      return Future.value(
        const Left(InputFailure(message: 'Email and password cannot be empty')),
      );
    }

    return _repository.login(email: email, password: password);
  }
}
