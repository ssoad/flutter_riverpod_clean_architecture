import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteTask(id);
  }
}
