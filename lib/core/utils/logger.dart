import 'dart:developer' as developer;

abstract final class AppLogger {
  static void info(String message) => developer.log(message, name: 'StoryHub');
}