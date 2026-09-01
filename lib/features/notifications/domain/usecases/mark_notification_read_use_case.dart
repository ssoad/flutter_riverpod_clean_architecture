import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.markAsRead(id);
  }
}

class MarkAllNotificationsReadUseCase {
  final NotificationRepository _repository;

  MarkAllNotificationsReadUseCase(this._repository);

  Future<Either<Failure, void>> call() {
    return _repository.markAllAsRead();
  }
}
