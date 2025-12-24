/// Framework-agnostic logging utility for data layer
///
/// This allows the data layer to remain independent of Flutter framework
/// while still providing logging capabilities.
abstract class Logger {
  /// Log a debug message
  static void debug(String message) {
    // In production, this could be replaced with a proper logging service
    // ignore: avoid_print
    print('[DEBUG] $message');
  }

  /// Log an info message
  static void info(String message) {
    // ignore: avoid_print
    print('[INFO] $message');
  }

  /// Log a warning message
  static void warning(String message) {
    // ignore: avoid_print
    print('[WARNING] $message');
  }

  /// Log an error message
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    // ignore: avoid_print
    print('[ERROR] $message');
    if (error != null) {
      // ignore: avoid_print
      print('Error: $error');
    }
    if (stackTrace != null) {
      // ignore: avoid_print
      print('StackTrace: $stackTrace');
    }
  }
}
