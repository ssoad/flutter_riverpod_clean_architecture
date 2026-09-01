import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/providers/task_providers.dart';

/// Presentation layer state management
/// This file contains only UI-related state providers

enum TasksStatus { initial, loading, loaded, error }

/// Which subset of tasks the UI should currently display.
enum TaskFilter { all, active, completed }

class TasksState {
  final TasksStatus status;
  final List<TaskEntity> tasks;
  final TaskFilter filter;
  final String? errorMessage;

  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.filter = TaskFilter.all,
    this.errorMessage,
  });

  List<TaskEntity> get visibleTasks {
    switch (filter) {
      case TaskFilter.active:
        return tasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.completed:
        return tasks.where((t) => t.isCompleted).toList();
      case TaskFilter.all:
        return tasks;
    }
  }

  int get completedCount => tasks.where((t) => t.isCompleted).length;

  TasksState copyWith({
    TasksStatus? status,
    List<TaskEntity>? tasks,
    TaskFilter? filter,
    String? errorMessage,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
    );
  }
}

class TasksNotifier extends Notifier<TasksState> {
  @override
  TasksState build() {
    return const TasksState();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(status: TasksStatus.loading, errorMessage: null);

    final result = await ref.read(getTasksUseCaseProvider).call();

    result.fold(
      (failure) => state = state.copyWith(
        status: TasksStatus.error,
        errorMessage: failure.message,
      ),
      (tasks) =>
          state = state.copyWith(status: TasksStatus.loaded, tasks: tasks),
    );
  }

  Future<bool> addTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    final task = TaskEntity(
      id: '',
      title: title.trim(),
      description: description?.trim().isEmpty ?? true
          ? null
          : description!.trim(),
      priority: priority,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );

    final result = await ref.read(addTaskUseCaseProvider).call(task);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (added) {
        state = state.copyWith(
          tasks: [added, ...state.tasks],
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> updateTask(TaskEntity task) async {
    final result = await ref.read(updateTaskUseCaseProvider).call(task);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (updated) {
        state = state.copyWith(
          tasks: [
            for (final t in state.tasks)
              if (t.id == updated.id) updated else t,
          ],
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<void> toggleTask(String id) async {
    // Optimistic update for a snappy UI.
    final previous = state.tasks;
    state = state.copyWith(
      tasks: [
        for (final t in previous)
          if (t.id == id) t.copyWith(isCompleted: !t.isCompleted) else t,
      ],
    );

    final result = await ref.read(toggleTaskUseCaseProvider).call(id);

    result.fold((failure) {
      // Roll back on failure.
      state = state.copyWith(tasks: previous, errorMessage: failure.message);
    }, (_) {});
  }

  Future<void> deleteTask(String id) async {
    final previous = state.tasks;
    state = state.copyWith(tasks: previous.where((t) => t.id != id).toList());

    final result = await ref.read(deleteTaskUseCaseProvider).call(id);

    result.fold((failure) {
      state = state.copyWith(tasks: previous, errorMessage: failure.message);
    }, (_) {});
  }

  void setFilter(TaskFilter filter) {
    state = state.copyWith(filter: filter);
  }
}

final tasksProvider = NotifierProvider<TasksNotifier, TasksState>(
  TasksNotifier.new,
);
