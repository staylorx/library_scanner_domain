import 'dart:developer' as developer;

// TODO: add log level filtering so that in production less verbose logs are shown
class DevLogger {
  static final Map<String, DevLogger> _instances = {};

  final String loggerName;

  DevLogger._(this.loggerName);

  factory DevLogger(String loggerName) {
    return _instances.putIfAbsent(loggerName, () => DevLogger._(loggerName));
  }

  void debug(String message) {
    final formattedMessage = loggerName.isNotEmpty
        ? '[$loggerName] $message'
        : message;
    developer.log(formattedMessage, name: 'DEBUG', level: 700);
  }

  void info(String message) {
    final formattedMessage = loggerName.isNotEmpty
        ? '[$loggerName] $message'
        : message;
    developer.log(formattedMessage, name: 'INFO', level: 800);
  }

  void warning(String message) {
    final formattedMessage = loggerName.isNotEmpty
        ? '[$loggerName] $message'
        : message;
    developer.log(formattedMessage, name: 'WARNING', level: 900);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    final formattedMessage = loggerName.isNotEmpty
        ? '[$loggerName] $message'
        : message;
    developer.log(
      formattedMessage,
      name: 'ERROR',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
