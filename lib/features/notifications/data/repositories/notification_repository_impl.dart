import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/data/models/notification_item_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource _localDataSource;

  NotificationRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<NotificationItemEntity>>>
  getNotifications() async {
    try {
      final items = await _localDataSource.getNotifications();
      items.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
      return Right(items);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> upsertNotification(
    NotificationItemEntity notification,
  ) async {
    try {
      final items = await _localDataSource.getNotifications();
      final index = items.indexWhere((n) => n.id == notification.id);
      final model = NotificationItemModel.fromEntity(notification);
      if (index == -1) {
        items.add(model);
      } else {
        items[index] = model;
      }
      await _localDataSource.saveNotifications(items);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    try {
      final items = await _localDataSource.getNotifications();
      final index = items.indexWhere((n) => n.id == id);
      if (index == -1) {
        return const Left(CacheFailure(message: 'Notification not found'));
      }
      items[index] = NotificationItemModel.fromEntity(
        items[index].copyWith(isRead: true),
      );
      await _localDataSource.saveNotifications(items);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      final items = await _localDataSource.getNotifications();
      final updated = items
          .map(
            (n) => NotificationItemModel.fromEntity(n.copyWith(isRead: true)),
          )
          .toList();
      await _localDataSource.saveNotifications(updated);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      await _localDataSource.saveNotifications(const []);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
