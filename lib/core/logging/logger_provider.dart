import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/logging/console_logger.dart';
import 'package:flutter_riverpod_clean_architecture/core/logging/logger.dart';

/// Provider for the global logger instance
final loggerProvider = Provider<Logger>((ref) {
  // Create a root logger instance
  return ConsoleLogger(
    logLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
    includeTimestamp: true,
    includeLogLevel: true,
  );
});

/// Provider for a logger with a specific tag
final taggedLoggerProvider = Provider.family<Logger, String>((ref, tag) {
  final rootLogger = ref.watch(loggerProvider);
  return rootLogger.child(tag);
});

/// Extension methods for performance logging with automatically timed operations
extension LoggerPerformanceExtension on Logger {
  /// Run and time a synchronous operation
  T timeSync<T>(
    String operationName,
    T Function() operation, {
    Map<String, dynamic>? data,
  }) {
    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } finally {
      stopwatch.stop();
      p('$operationName completed', data: data, duration: stopwatch.elapsed);
    }
  }

  /// Run and time an asynchronous operation
  Future<T> timeAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? data,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      p('$operationName completed', data: data, duration: stopwatch.elapsed);
    }
  }
}

/// Mixin to add logging capabilities to any class
mixin LoggerMixin {
  Logger get logger => ConsoleLogger(tag: runtimeType.toString());

  void logVerbose(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.v(message, data: data, error: error, stackTrace: stackTrace);
  }

  void logDebug(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.d(message, data: data, error: error, stackTrace: stackTrace);
  }

  void logInfo(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.i(message, data: data, error: error, stackTrace: stackTrace);
  }

  void logWarning(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.w(message, data: data, error: error, stackTrace: stackTrace);
  }

  void logError(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.e(message, data: data, error: error, stackTrace: stackTrace);
  }

  void logCritical(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.c(message, data: data, error: error, stackTrace: stackTrace);
  }

  void logPerformance(
    String message, {
    Map<String, dynamic>? data,
    Duration? duration,
  }) {
    logger.p(message, data: data, duration: duration);
  }
}

/// Widget-specific logger mixin that gets the logger from provider
mixin WidgetLoggerMixin on ConsumerStatefulWidget {
  String get logTag => runtimeType.toString();
}

/// State mixin for logging with providers
mixin LoggerStateMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  late final Logger logger;

  @override
  void initState() {
    super.initState();
    if (widget is WidgetLoggerMixin) {
      final tag = (widget as WidgetLoggerMixin).logTag;
      logger = ref.read(taggedLoggerProvider(tag));
    } else {
      logger = ref.read(taggedLoggerProvider(widget.runtimeType.toString()));
    }
    logger.d('${widget.runtimeType} initialized');
  }

  @override
  void dispose() {
    logger.d('${widget.runtimeType} disposed');
    super.dispose();
  }
}
