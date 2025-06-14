import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_event.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_service.dart';

/// Provider for the analytics service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  // In a real app, you would initialize all your analytics services here
  // For example: FirebaseAnalyticsService(), MixpanelService(), etc.
  return CompositeAnalyticsService([DebugAnalyticsService()]);
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
