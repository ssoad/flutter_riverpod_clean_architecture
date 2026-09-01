import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/local_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/data/models/notification_item_model.dart';

/// Persists the in-app notification feed as a JSON-encoded list via
/// [LocalStorageService].
abstract class NotificationLocalDataSource {
  Future<List<NotificationItemModel>> getNotifications();
  Future<void> saveNotifications(List<NotificationItemModel> notifications);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final LocalStorageService _localStorageService;

  NotificationLocalDataSourceImpl(this._localStorageService);

  @override
  Future<List<NotificationItemModel>> getNotifications() async {
    try {
      final data = _localStorageService.getObject(
        AppConstants.notificationsStorageKey,
      );
      if (data == null) return [];
      return (data as List)
          .map((e) => NotificationItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: 'Failed to parse stored notifications: $e');
    }
  }

  @override
  Future<void> saveNotifications(
    List<NotificationItemModel> notifications,
  ) async {
    await _localStorageService.setObject(
      AppConstants.notificationsStorageKey,
      notifications.map((n) => n.toJson()).toList(),
    );
  }
}

final notificationLocalDataSourceProvider =
    Provider<NotificationLocalDataSource>((ref) {
      return NotificationLocalDataSourceImpl(
        ref.watch(localStorageServiceProvider),
      );
    });
