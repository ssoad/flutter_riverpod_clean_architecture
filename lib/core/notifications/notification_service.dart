import 'dart:async';

/// Model class representing a notification message
class NotificationMessage {
  /// Unique identifier for the notification
  final String id;

  /// Notification title
  final String? title;

  /// Notification body text
  final String? body;

  /// Optional image URL
  final String? imageUrl;

  /// Optional data payload
  final Map<String, dynamic>? data;

  /// Deep link or action to take when notification is tapped
  final String? action;

  /// Notification channel or category
  final String? channel;

  /// Whether the notification was received when app was in foreground
  final bool foreground;

  const NotificationMessage({
    required this.id,
    this.title,
    this.body,
    this.imageUrl,
    this.data,
    this.action,
    this.channel,
    this.foreground = true,
  });

  @override
  String toString() {
    return 'NotificationMessage{'
        'id: $id, '
        'title: $title, '
        'body: $body, '
        'imageUrl: $imageUrl, '
        'data: $data, '
        'action: $action, '
        'channel: $channel, '
        'foreground: $foreground'
        '}';
  }
}

/// Interface for notification permission status
enum NotificationPermissionStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
}

/// Interface for notification services
abstract class NotificationService {
  /// Initialize the notification service
  Future<void> init();

  /// Request permission to show notifications
  Future<NotificationPermissionStatus> requestPermission();

  /// Get current notification permission status
  Future<NotificationPermissionStatus> getPermissionStatus();

  /// Register for push notifications with Firebase Cloud Messaging or APNs
  Future<String?> getToken();

  /// Handle a notification that arrived when the app was in the background/terminated
  Future<void> handleBackgroundMessage(Map<String, dynamic> message);

  /// Configure notification channels (Android)
  Future<void> configureChannels();

  /// Subscribe to a notification topic
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a notification topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Show a local notification
  Future<void> showLocalNotification({
    required String id,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
    String? action,
    String? channel,
  });

  /// Clear a specific notification by id
  Future<void> clearNotification(String id);

  /// Clear all notifications
  Future<void> clearAllNotifications();

  /// Stream of incoming notifications
  Stream<NotificationMessage> get notificationStream;

  /// Stream of notification taps
  Stream<NotificationMessage> get notificationTapStream;
}
