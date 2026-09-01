import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/data/models/task_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _localDataSource;
  final Uuid _uuid;

  TaskRepositoryImpl(this._localDataSource, {Uuid uuid = const Uuid()})
    : _uuid = uuid;

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      final tasks = await _localDataSource.getTasks();
      // Newest first
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(tasks);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> addTask(TaskEntity task) async {
    try {
      final tasks = await _localDataSource.getTasks();
      final newTask = TaskModel.fromEntity(
        task.copyWith(id: task.id.isEmpty ? _uuid.v4() : task.id),
      );
      tasks.add(newTask);
      await _localDataSource.saveTasks(tasks);
      return Right(newTask.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    try {
      final tasks = await _localDataSource.getTasks();
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index == -1) {
        return const Left(CacheFailure(message: 'Task not found'));
      }
      final updated = TaskModel.fromEntity(task);
      tasks[index] = updated;
      await _localDataSource.saveTasks(tasks);
      return Right(updated.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      final tasks = await _localDataSource.getTasks();
      tasks.removeWhere((t) => t.id == id);
      await _localDataSource.saveTasks(tasks);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> toggleTaskCompletion(String id) async {
    try {
      final tasks = await _localDataSource.getTasks();
      final index = tasks.indexWhere((t) => t.id == id);
      if (index == -1) {
        return const Left(CacheFailure(message: 'Task not found'));
      }
      final toggled = TaskModel.fromEntity(
        tasks[index].copyWith(isCompleted: !tasks[index].isCompleted),
      );
      tasks[index] = toggled;
      await _localDataSource.saveTasks(tasks);
      return Right(toggled.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
