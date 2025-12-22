import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod_clean_architecture/core/notifications/notification_service.dart';

/// A simple debug implementation of notification service
class DebugNotificationService implements NotificationService {
  final _notificationStreamController =
      StreamController<NotificationMessage>.broadcast();
  final _notificationTapStreamController =
      StreamController<NotificationMessage>.broadcast();

  NotificationPermissionStatus _permissionStatus =
      NotificationPermissionStatus.notDetermined;

  @override
  Future<void> init() async {
    debugPrint('🔔 Debug notification service initialized');
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    debugPrint('🔔 Requesting notification permission');
    _permissionStatus = NotificationPermissionStatus.authorized;
    return _permissionStatus;
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    return _permissionStatus;
  }

  @override
  Future<String?> getToken() async {
    final token = 'debug-token-${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('🔔 Generated debug token: $token');
    return token;
  }

  @override
  Future<void> handleBackgroundMessage(Map<String, dynamic> message) async {
    debugPrint('🔔 Handling background message: $message');
  }

  @override
  Future<void> configureChannels() async {
    debugPrint('🔔 Configuring notification channels');
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    debugPrint('🔔 Subscribed to topic: $topic');
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    debugPrint('🔔 Unsubscribed from topic: $topic');
  }

  @override
  Future<void> showLocalNotification({
    required String id,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
    String? action,
    String? channel,
  }) async {
    debugPrint('🔔 Showing local notification:');
    debugPrint('🔔 ID: $id');
    debugPrint('🔔 Title: $title');
    debugPrint('🔔 Body: $body');
    if (imageUrl != null) debugPrint('🔔 Image: $imageUrl');
    if (data != null) debugPrint('🔔 Data: $data');
    if (action != null) debugPrint('🔔 Action: $action');
    if (channel != null) debugPrint('🔔 Channel: $channel');

    final notification = NotificationMessage(
      id: id,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      action: action,
      channel: channel,
      foreground: true,
    );

    _notificationStreamController.add(notification);
  }

  @override
  Future<void> clearNotification(String id) async {
    debugPrint('🔔 Cleared notification: $id');
  }

  @override
  Future<void> clearAllNotifications() async {
    debugPrint('🔔 Cleared all notifications');
  }

  @override
  Stream<NotificationMessage> get notificationStream =>
      _notificationStreamController.stream;

  @override
  Stream<NotificationMessage> get notificationTapStream =>
      _notificationTapStreamController.stream;

  /// Simulate a notification tap for testing purposes
  void simulateTap(NotificationMessage notification) {
    _notificationTapStreamController.add(notification);
  }

  /// Dispose resources
  void dispose() {
    _notificationStreamController.close();
    _notificationTapStreamController.close();
  }
}
