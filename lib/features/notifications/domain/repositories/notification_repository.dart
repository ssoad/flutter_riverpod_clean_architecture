import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_item_entity.dart';

/// Contract for reading and mutating the in-app notification feed.
abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationItemEntity>>> getNotifications();

  /// Appends (or updates, if the id already exists) a notification.
  Future<Either<Failure, void>> upsertNotification(
    NotificationItemEntity notification,
  );

  Future<Either<Failure, void>> markAsRead(String id);

  Future<Either<Failure, void>> markAllAsRead();

  Future<Either<Failure, void>> clearAll();
}
