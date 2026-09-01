import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/local_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/data/models/task_model.dart';

/// Persists tasks on-device as a JSON-encoded list via [LocalStorageService].
abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> saveTasks(List<TaskModel> tasks);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final LocalStorageService _localStorageService;

  TaskLocalDataSourceImpl(this._localStorageService);

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final data = _localStorageService.getObject(AppConstants.tasksStorageKey);
      if (data == null) return [];
      return (data as List)
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: 'Failed to parse stored tasks: $e');
    }
  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    await _localStorageService.setObject(
      AppConstants.tasksStorageKey,
      tasks.map((t) => t.toJson()).toList(),
    );
  }
}

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSourceImpl(ref.watch(localStorageServiceProvider));
});
