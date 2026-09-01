import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/repositories/task_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/usecases/add_task_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/usecases/delete_task_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/usecases/get_tasks_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/usecases/toggle_task_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/usecases/update_task_use_case.dart';

/// Data layer dependency injection providers
/// These providers are responsible for creating and managing data layer instances

// --- Repository ---
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskLocalDataSourceProvider));
});

// --- Use Cases ---
final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
});

final addTaskUseCaseProvider = Provider<AddTaskUseCase>((ref) {
  return AddTaskUseCase(ref.watch(taskRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

final toggleTaskUseCaseProvider = Provider<ToggleTaskUseCase>((ref) {
  return ToggleTaskUseCase(ref.watch(taskRepositoryProvider));
});
