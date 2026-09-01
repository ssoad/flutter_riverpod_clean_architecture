import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, UserEntity>> execute(UserEntity user) {
    if (user.name.trim().isEmpty) {
      return Future.value(
        const Left(InputFailure(message: 'Name cannot be empty')),
      );
    }
    if (!_isValidEmail(user.email)) {
      return Future.value(
        const Left(InputFailure(message: 'Enter a valid email address')),
      );
    }
    return _repository.updateProfile(user);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }
}
