import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/clear_notifications_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/get_notifications_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/mark_notification_read_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/upsert_notification_use_case.dart';

/// Data layer dependency injection providers
/// These providers are responsible for creating and managing data layer instances

// --- Repository ---
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationLocalDataSourceProvider),
  );
});

// --- Use Cases ---
final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((
  ref,
) {
  return GetNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});

final upsertNotificationUseCaseProvider = Provider<UpsertNotificationUseCase>((
  ref,
) {
  return UpsertNotificationUseCase(ref.watch(notificationRepositoryProvider));
});

final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>((ref) {
      return MarkNotificationReadUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final markAllNotificationsReadUseCaseProvider =
    Provider<MarkAllNotificationsReadUseCase>((ref) {
      return MarkAllNotificationsReadUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final clearNotificationsUseCaseProvider = Provider<ClearNotificationsUseCase>((
  ref,
) {
  return ClearNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});
