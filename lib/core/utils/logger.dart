import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = 'RaqimApp';

  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? _tag,
        level: 500, // Debug level
      );
    }
  }

  static void info(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800, // Info level
    );
  }

  static void warning(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900, // Warning level
    );
  }

  static void error(String message, [String? tag, Object? error]) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000, // Error level
      error: error,
    );
  }
}