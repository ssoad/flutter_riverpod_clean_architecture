import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/notifications/debug_notification_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/notifications/notification_service.dart';

/// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  // In a real app, you would use a real notification service implementation
  // such as FirebaseNotificationService
  final service = DebugNotificationService();

  // Log notification events to analytics
  final analytics = ref.watch(analyticsProvider);

  // Handle notification received events
  service.notificationStream.listen((notification) {
    analytics.logUserAction(
      action: 'notification_received',
      category: 'notification',
      label: notification.channel ?? 'default',
      parameters: {
        'notification_id': notification.id,
        'title': notification.title,
        'foreground': notification.foreground,
      },
    );
  });

  // Handle notification tap events
  service.notificationTapStream.listen((notification) {
    analytics.logUserAction(
      action: 'notification_tapped',
      category: 'notification',
      label: notification.channel ?? 'default',
      parameters: {
        'notification_id': notification.id,
        'action': notification.action,
      },
    );
  });

  // Initialize the service
  service.init();

  // Dispose the service when the provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for whether notifications are enabled
final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  final status = await service.getPermissionStatus();
  return status == NotificationPermissionStatus.authorized ||
      status == NotificationPermissionStatus.provisional;
});

/// Controller for handling deep links from notifications
/// Controller for handling deep links from notifications
class NotificationDeepLinkHandler extends Notifier<String?> {
  @override
  String? build() {
    final service = ref.watch(notificationServiceProvider);

    // Listen to stream, but we need to be careful not to create side effects in build
    // Typically in Notifier, we setup subscriptions in build or use a StreamProvider.
    // Here we'll subscribe and update state.
    final sub = service.notificationTapStream.listen(_handleNotificationTap);

    ref.onDispose(sub.cancel);

    return null;
  }

  /// Get the pending deep link, if any
  String? get pendingDeepLink => state;

  /// Clear the pending deep link
  void clearPendingDeepLink() {
    state = null;
  }

  void _handleNotificationTap(NotificationMessage notification) {
    if (notification.action != null) {
      state = notification.action;
    }
  }
}

/// Provider for the notification deep link handler
final notificationDeepLinkHandlerProvider =
    NotifierProvider<NotificationDeepLinkHandler, String?>(
      NotificationDeepLinkHandler.new,
    );
