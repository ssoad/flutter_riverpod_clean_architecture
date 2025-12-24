import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/domain/repositories/survey_repository.dart';

class CheckUsernameUseCase {
  final SurveyRepository _repository;

  CheckUsernameUseCase(this._repository);

  Future<Either<Failure, bool>> call(String username) {
    return _repository.isUsernameAvailable(username);
  }
}
