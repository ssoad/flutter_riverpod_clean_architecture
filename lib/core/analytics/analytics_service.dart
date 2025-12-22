import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_event.dart';

/// Interface for analytics service implementations
abstract class AnalyticsService {
  /// Initialize the analytics service
  FutureOr<void> init();

  /// Log an analytics event
  void logEvent(AnalyticsEvent event);

  /// Set user properties for user-scoped analytics
  void setUserProperties({
    required String userId,
    Map<String, dynamic>? properties,
  });

  /// Clear all user properties and identifiers
  void resetUser();

  /// Enable analytics collection
  void enable();

  /// Disable analytics collection
  void disable();

  /// Check if analytics collection is enabled
  bool get isEnabled;
}

/// A service that logs events to multiple analytics providers
class CompositeAnalyticsService implements AnalyticsService {
  final List<AnalyticsService> _services;

  CompositeAnalyticsService(this._services);

  @override
  FutureOr<void> init() async {
    for (final service in _services) {
      await service.init();
    }
  }

  @override
  void logEvent(AnalyticsEvent event) {
    for (final service in _services) {
      service.logEvent(event);
    }
  }

  @override
  void setUserProperties({
    required String userId,
    Map<String, dynamic>? properties,
  }) {
    for (final service in _services) {
      service.setUserProperties(userId: userId, properties: properties);
    }
  }

  @override
  void resetUser() {
    for (final service in _services) {
      service.resetUser();
    }
  }

  @override
  void enable() {
    for (final service in _services) {
      service.enable();
    }
  }

  @override
  void disable() {
    for (final service in _services) {
      service.disable();
    }
  }

  @override
  bool get isEnabled =>
      _services.isNotEmpty ? _services.first.isEnabled : false;
}

/// A service that logs analytics events to the debug console
class DebugAnalyticsService implements AnalyticsService {
  bool _enabled = true;

  @override
  FutureOr<void> init() {
    debugPrint('🔍 DebugAnalyticsService initialized');
  }

  @override
  void logEvent(AnalyticsEvent event) {
    if (!_enabled) return;
    debugPrint('📊 Analytics Event: ${event.name}');
    debugPrint('📊 Parameters: ${event.parameters}');
  }

  @override
  void setUserProperties({
    required String userId,
    Map<String, dynamic>? properties,
  }) {
    if (!_enabled) return;
    debugPrint('👤 User identified: $userId');
    if (properties != null) {
      debugPrint('👤 User properties: $properties');
    }
  }

  @override
  void resetUser() {
    if (!_enabled) return;
    debugPrint('👤 User reset');
  }

  @override
  void enable() {
    _enabled = true;
    debugPrint('📊 Analytics enabled');
  }

  @override
  void disable() {
    _enabled = false;
    debugPrint('📊 Analytics disabled');
  }

  @override
  bool get isEnabled => _enabled;
}
