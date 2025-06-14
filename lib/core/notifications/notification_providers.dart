import 'package:flutter/widgets.dart';
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
    if (service is DebugNotificationService) {
      service.dispose();
    }
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
class NotificationDeepLinkHandler extends ChangeNotifier {
  final NotificationService _service;
  String? _pendingDeepLink;

  NotificationDeepLinkHandler(this._service) {
    _service.notificationTapStream.listen(_handleNotificationTap);
  }

  /// Get the pending deep link, if any
  String? get pendingDeepLink => _pendingDeepLink;

  /// Clear the pending deep link
  void clearPendingDeepLink() {
    _pendingDeepLink = null;
    notifyListeners();
  }

  void _handleNotificationTap(NotificationMessage notification) {
    if (notification.action != null) {
      _pendingDeepLink = notification.action;
      notifyListeners();
    }
  }
}

/// Provider for the notification deep link handler
final notificationDeepLinkHandlerProvider =
    ChangeNotifierProvider<NotificationDeepLinkHandler>((ref) {
      final service = ref.watch(notificationServiceProvider);
      return NotificationDeepLinkHandler(service);
    });
