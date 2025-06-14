import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod_clean_architecture/core/logging/logger.dart';

/// A logger implementation that logs to the debug console
class ConsoleLogger implements Logger {
  /// The tag for this logger
  final String _tag;

  /// The minimum log level to display
  LogLevel _logLevel;

  /// Whether to include timestamps in log messages
  final bool _includeTimestamp;

  /// Whether to include the log level in log messages
  final bool _includeLogLevel;

  /// Format for timestamps
  final DateFormat _timestampFormat;

  /// Create a new console logger
  ConsoleLogger({
    String tag = '',
    LogLevel logLevel = LogLevel.info,
    bool includeTimestamp = true,
    bool includeLogLevel = true,
  }) : _tag = tag,
       _logLevel = logLevel,
       _includeTimestamp = includeTimestamp,
       _includeLogLevel = includeLogLevel,
       _timestampFormat = DateFormat('HH:mm:ss.SSS');

  @override
  void v(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.verbose,
      message,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void d(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.debug,
      message,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void i(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.info,
      message,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void w(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.warning,
      message,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void e(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.error,
      message,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void c(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.critical,
      message,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void p(String message, {Map<String, dynamic>? data, Duration? duration}) {
    final perfData = <String, dynamic>{...?data};
    if (duration != null) {
      perfData['duration_ms'] = duration.inMicroseconds / 1000;
    }
    log(LogLevel.performance, message, data: perfData);
  }

  @override
  void log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _logLevel.index) return;

    final buffer = StringBuffer();

    // Add timestamp if requested
    if (_includeTimestamp) {
      final timestamp = _timestampFormat.format(DateTime.now());
      buffer.write('[$timestamp] ');
    }

    // Add log level if requested
    if (_includeLogLevel) {
      final levelStr = _getLevelString(level);
      buffer.write('$levelStr ');
    }

    // Add tag if present
    if (_tag.isNotEmpty) {
      buffer.write('[$_tag] ');
    }

    // Add the message
    buffer.write(message);

    // Add data if present
    if (data != null && data.isNotEmpty) {
      buffer.write(' - ${_formatData(data)}');
    }

    // Print the log message
    debugPrint(buffer.toString());

    // Print error and stack trace if present
    if (error != null) {
      debugPrint('Error: $error');
      final trace = stackTrace ?? StackTrace.current;
      debugPrint('Stack trace:\n$trace');
    }
  }

  @override
  void setLogLevel(LogLevel level) {
    _logLevel = level;
  }

  @override
  LogLevel getLogLevel() {
    return _logLevel;
  }

  @override
  Logger child(String tag) {
    final newTag = _tag.isEmpty ? tag : '$_tag:$tag';
    return ConsoleLogger(
      tag: newTag,
      logLevel: _logLevel,
      includeTimestamp: _includeTimestamp,
      includeLogLevel: _includeLogLevel,
    );
  }

  /// Convert a log level to a colored string representation
  String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return '[VERB]';
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARN]';
      case LogLevel.error:
        return '[ERROR]';
      case LogLevel.critical:
        return '[CRIT]';
      case LogLevel.performance:
        return '[PERF]';
    }
  }

  /// Format data map for logging
  String _formatData(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join(', ');
  }
}
