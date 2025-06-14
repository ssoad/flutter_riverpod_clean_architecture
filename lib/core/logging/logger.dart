/// Severity levels for logging
enum LogLevel {
  /// Verbose logging for detailed debugging
  verbose,

  /// Debug logging for general debugging purposes
  debug,

  /// Informational messages about normal application flow
  info,

  /// Warning messages about potential issues
  warning,

  /// Error messages about issues that need attention
  error,

  /// Critical errors that may cause the app to fail
  critical,

  /// Messages about performance metrics
  performance,
}

/// Interface for logging operations
abstract class Logger {
  /// Log a message at the verbose level
  void v(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a message at the debug level
  void d(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a message at the info level
  void i(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a message at the warning level
  void w(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a message at the error level
  void e(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a message at the critical level
  void c(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Log a performance metric
  void p(String message, {Map<String, dynamic>? data, Duration? duration});

  /// Log a message with the specified level
  void log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Set the minimum log level
  void setLogLevel(LogLevel level);

  /// Get the current log level
  LogLevel getLogLevel();

  /// Create a child logger with a specific tag
  Logger child(String tag);
}
