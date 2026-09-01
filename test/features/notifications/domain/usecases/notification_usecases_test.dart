import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/clear_notifications_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/get_notifications_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/mark_notification_read_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/upsert_notification_use_case.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      NotificationItemEntity(
        id: 'fallback',
        title: 'fallback',
        body: 'fallback',
        receivedAt: DateTime(2024),
      ),
    );
  });

  setUp(() {
    mockRepository = MockNotificationRepository();
  });

  final tNotification = NotificationItemEntity(
    id: '1',
    title: 'New message',
    body: 'You have a new message',
    receivedAt: DateTime(2024, 1, 1),
  );

  test(
    'GetNotificationsUseCase returns notifications from the repository',
    () async {
      when(
        () => mockRepository.getNotifications(),
      ).thenAnswer((_) async => Right([tNotification]));

      final result = await GetNotificationsUseCase(mockRepository).call();

      result.fold(
        (_) => fail('Should have returned notifications'),
        (items) => expect(items, [tNotification]),
      );
    },
  );

  test('UpsertNotificationUseCase delegates to the repository', () async {
    when(
      () => mockRepository.upsertNotification(tNotification),
    ).thenAnswer((_) async => const Right(null));

    final result = await UpsertNotificationUseCase(
      mockRepository,
    ).call(tNotification);

    expect(result, const Right<Failure, void>(null));
    verify(() => mockRepository.upsertNotification(tNotification)).called(1);
  });

  test('MarkNotificationReadUseCase delegates to the repository', () async {
    when(
      () => mockRepository.markAsRead('1'),
    ).thenAnswer((_) async => const Right(null));

    final result = await MarkNotificationReadUseCase(mockRepository).call('1');

    expect(result, const Right<Failure, void>(null));
    verify(() => mockRepository.markAsRead('1')).called(1);
  });

  test('MarkAllNotificationsReadUseCase delegates to the repository', () async {
    when(
      () => mockRepository.markAllAsRead(),
    ).thenAnswer((_) async => const Right(null));

    final result = await MarkAllNotificationsReadUseCase(mockRepository).call();

    expect(result, const Right<Failure, void>(null));
  });

  test('ClearNotificationsUseCase propagates a repository failure', () async {
    const tFailure = CacheFailure(message: 'Could not clear');
    when(
      () => mockRepository.clearAll(),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await ClearNotificationsUseCase(mockRepository).call();

    expect(result, const Left(tFailure));
  });
}
