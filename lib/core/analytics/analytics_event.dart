import 'package:flutter/foundation.dart';

/// Base class for all analytics events in the app
abstract class AnalyticsEvent {
  /// The name of the event as it will be reported to analytics services
  String get name;

  /// Parameters associated with this event
  Map<String, dynamic> get parameters => {};

  @override
  String toString() => 'AnalyticsEvent(name: $name, parameters: $parameters)';
}

/// An event that tracks screen views
class ScreenViewEvent extends AnalyticsEvent {
  final String screenName;
  final Map<String, dynamic>? screenParameters;

  ScreenViewEvent(this.screenName, {this.screenParameters});

  @override
  String get name => 'screen_view';

  @override
  Map<String, dynamic> get parameters => {
    'screen_name': screenName,
    if (screenParameters != null) ...screenParameters!,
  };
}

/// An event that tracks user actions such as button clicks
class UserActionEvent extends AnalyticsEvent {
  final String action;
  final String? category;
  final String? label;
  final int? value;
  final Map<String, dynamic>? extraParams;

  UserActionEvent({
    required this.action,
    this.category,
    this.label,
    this.value,
    this.extraParams,
  });

  @override
  String get name => 'user_action';

  @override
  Map<String, dynamic> get parameters => {
    'action': action,
    if (category != null) 'category': category,
    if (label != null) 'label': label,
    if (value != null) 'value': value,
    if (extraParams != null) ...extraParams!,
  };
}

/// An event that tracks errors or exceptions
class ErrorEvent extends AnalyticsEvent {
  final String errorType;
  final String message;
  final String? stackTrace;
  final bool isFatal;

  ErrorEvent({
    required this.errorType,
    required this.message,
    this.stackTrace,
    this.isFatal = false,
  });

  @override
  String get name => 'app_error';

  @override
  Map<String, dynamic> get parameters => {
    'error_type': errorType,
    'message': message,
    'is_fatal': isFatal,
    if (stackTrace != null) 'stack_trace': stackTrace,
  };
}

/// An event that tracks performance related metrics
class PerformanceEvent extends AnalyticsEvent {
  final String metricName;
  final num value;
  final String unit;
  final Map<String, dynamic>? extraParams;

  PerformanceEvent({
    required this.metricName,
    required this.value,
    this.unit = 'ms',
    this.extraParams,
  });

  @override
  String get name => 'performance';

  @override
  Map<String, dynamic> get parameters => {
    'metric_name': metricName,
    'value': value,
    'unit': unit,
    if (extraParams != null) ...extraParams!,
  };
}
