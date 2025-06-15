import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_event.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/firebase_analytics_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/feature_flags/feature_flag_providers.dart';

/// A debug analytics service for development
class DebugAnalyticsService implements AnalyticsService {
  bool _isEnabled = true;

  @override
  Future<void> init() async {
    debugPrint('📊 Debug Analytics initialized');
  }

  @override
  void logEvent(AnalyticsEvent event) {
    if (!_isEnabled) return;
    debugPrint('📊 DEBUG ANALYTICS: ${event.name} - ${event.parameters}');
  }

  @override
  void setUserProperties({
    required String userId,
    Map<String, dynamic>? properties,
  }) {
    if (!_isEnabled) return;
    debugPrint('📊 DEBUG ANALYTICS: Set user ID: $userId');
    if (properties != null) {
      debugPrint('📊 DEBUG ANALYTICS: User properties: $properties');
    }
  }

  @override
  void resetUser() {
    if (!_isEnabled) return;
    debugPrint('📊 DEBUG ANALYTICS: Reset user');
  }

  @override
  void enable() {
    _isEnabled = true;
    debugPrint('📊 DEBUG ANALYTICS: Enabled');
  }

  @override
  void disable() {
    _isEnabled = false;
    debugPrint('📊 DEBUG ANALYTICS: Disabled');
  }

  @override
  bool get isEnabled => _isEnabled;
}

/// Provider for the analytics service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  // Check if analytics are enabled via feature flag
  final analyticsEnabled = ref.watch(
    featureFlagProvider('enable_analytics', defaultValue: true),
  );

  // Create an appropriate analytics service implementation
  final services = <AnalyticsService>[];

  // Always add Firebase Analytics in production
  if (!kDebugMode ||
      ref.watch(
        featureFlagProvider('force_firebase_analytics', defaultValue: false),
      )) {
    services.add(FirebaseAnalyticsService());
  }

  // Add debug analytics in debug mode
  if (kDebugMode) {
    services.add(DebugAnalyticsService());
  }

  // Create a composite service with all enabled analytics providers
  final service = CompositeAnalyticsService(services);

  // Enable/disable based on user preference
  if (analyticsEnabled) {
    service.enable();
  } else {
    service.disable();
  }

  return service;
});

/// Provider for accessing the analytics event logger
final analyticsProvider = Provider<Analytics>((ref) {
  final service = ref.watch(analyticsServiceProvider);
  return Analytics(service);
});

/// Helper class to log analytics events
class Analytics {
  final AnalyticsService _service;

  Analytics(this._service);

  /// Log a screen view event
  void logScreenView(String screenName, {Map<String, dynamic>? parameters}) {
    _service.logEvent(
      ScreenViewEvent(screenName, screenParameters: parameters),
    );
  }

  /// Log a user action event
  void logUserAction({
    required String action,
    String? category,
    String? label,
    int? value,
    Map<String, dynamic>? parameters,
  }) {
    _service.logEvent(
      UserActionEvent(
        action: action,
        category: category,
        label: label,
        value: value,
        extraParams: parameters,
      ),
    );
  }

  /// Log an error event
  void logError({
    required String errorType,
    required String message,
    String? stackTrace,
    bool isFatal = false,
  }) {
    _service.logEvent(
      ErrorEvent(
        errorType: errorType,
        message: message,
        stackTrace: stackTrace,
        isFatal: isFatal,
      ),
    );
  }

  /// Log a performance event
  void logPerformance({
    required String name,
    required num value,
    String unit = 'ms',
    Map<String, dynamic>? parameters,
  }) {
    _service.logEvent(
      PerformanceEvent(
        metricName: name,
        value: value,
        unit: unit,
        extraParams: parameters,
      ),
    );
  }

  /// Set user properties
  void setUser({required String userId, Map<String, dynamic>? properties}) {
    _service.setUserProperties(userId: userId, properties: properties);
  }

  /// Reset user
  void resetUser() {
    _service.resetUser();
  }

  /// Enable analytics
  void enable() {
    _service.enable();
  }

  /// Disable analytics
  void disable() {
    _service.disable();
  }

  /// Check if analytics is enabled
  bool get isEnabled => _service.isEnabled;
}

/// A widget that automatically tracks screen views
class AnalyticsScreenView extends StatefulWidget {
  final String screenName;
  final Map<String, dynamic>? parameters;
  final Widget child;

  const AnalyticsScreenView({
    Key? key,
    required this.screenName,
    this.parameters,
    required this.child,
  }) : super(key: key);

  @override
  State<AnalyticsScreenView> createState() => _AnalyticsScreenViewState();
}

class _AnalyticsScreenViewState extends State<AnalyticsScreenView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analytics = ProviderScope.containerOf(
        context,
      ).read(analyticsProvider);
      analytics.logScreenView(widget.screenName, parameters: widget.parameters);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
