import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/repositories/task_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/usecases/add_task_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/usecases/delete_task_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/usecases/get_tasks_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/usecases/toggle_task_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/usecases/update_task_use_case.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      TaskEntity(id: 'fallback', title: 'fallback', createdAt: DateTime(2024)),
    );
  });

  setUp(() {
    mockRepository = MockTaskRepository();
  });

  final tTask = TaskEntity(
    id: '1',
    title: 'Buy groceries',
    createdAt: DateTime(2024, 1, 1),
  );

  group('GetTasksUseCase', () {
    test('returns tasks from the repository', () async {
      when(
        () => mockRepository.getTasks(),
      ).thenAnswer((_) async => Right([tTask]));

      final result = await GetTasksUseCase(mockRepository).call();

      result.fold(
        (_) => fail('Should have returned tasks'),
        (tasks) => expect(tasks, [tTask]),
      );
      verify(() => mockRepository.getTasks()).called(1);
    });
  });

  group('AddTaskUseCase', () {
    test('returns InputFailure when title is empty', () async {
      final result = await AddTaskUseCase(
        mockRepository,
      ).call(tTask.copyWith(title: ''));

      result.fold(
        (failure) => expect(failure, isA<InputFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('delegates to the repository when title is valid', () async {
      when(
        () => mockRepository.addTask(any()),
      ).thenAnswer((_) async => Right(tTask));

      final result = await AddTaskUseCase(mockRepository).call(tTask);

      expect(result, Right<Failure, TaskEntity>(tTask));
      verify(() => mockRepository.addTask(tTask)).called(1);
    });
  });

  group('UpdateTaskUseCase', () {
    test('returns InputFailure when title is empty', () async {
      final result = await UpdateTaskUseCase(
        mockRepository,
      ).call(tTask.copyWith(title: '   '));

      result.fold(
        (failure) => expect(failure, isA<InputFailure>()),
        (_) => fail('Should have returned a failure'),
      );
      verifyZeroInteractions(mockRepository);
    });
  });

  group('ToggleTaskUseCase', () {
    test('delegates to the repository', () async {
      final toggled = tTask.copyWith(isCompleted: true);
      when(
        () => mockRepository.toggleTaskCompletion('1'),
      ).thenAnswer((_) async => Right(toggled));

      final result = await ToggleTaskUseCase(mockRepository).call('1');

      expect(result, Right<Failure, TaskEntity>(toggled));
    });
  });

  group('DeleteTaskUseCase', () {
    test('delegates to the repository', () async {
      when(
        () => mockRepository.deleteTask('1'),
      ).thenAnswer((_) async => const Right(null));

      final result = await DeleteTaskUseCase(mockRepository).call('1');

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.deleteTask('1')).called(1);
    });
  });
}
