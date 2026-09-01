import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/repositories/task_repository.dart';

class AddTaskUseCase {
  final TaskRepository _repository;

  AddTaskUseCase(this._repository);

  Future<Either<Failure, TaskEntity>> call(TaskEntity task) {
    if (task.title.trim().isEmpty) {
      return Future.value(
        const Left(InputFailure(message: 'Task title cannot be empty')),
      );
    }
    return _repository.addTask(task);
  }
}
