import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/repositories/notification_repository.dart';

class UpsertNotificationUseCase {
  final NotificationRepository _repository;

  UpsertNotificationUseCase(this._repository);

  Future<Either<Failure, void>> call(NotificationItemEntity notification) {
    return _repository.upsertNotification(notification);
  }
}
