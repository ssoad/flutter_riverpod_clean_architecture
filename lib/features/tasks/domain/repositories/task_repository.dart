import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/entities/task_entity.dart';

/// Contract for reading and mutating [TaskEntity] items.
abstract class TaskRepository {
  /// Returns every persisted task.
  Future<Either<Failure, List<TaskEntity>>> getTasks();

  /// Persists a new task.
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task);

  /// Persists changes to an existing task.
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);

  /// Removes a task by id.
  Future<Either<Failure, void>> deleteTask(String id);

  /// Flips the `isCompleted` flag of a task by id.
  Future<Either<Failure, TaskEntity>> toggleTaskCompletion(String id);
}
