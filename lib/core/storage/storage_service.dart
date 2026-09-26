import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lưu trữ key-value cục bộ, giá trị phức tạp được mã hoá JSON.
class StorageService {
  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> write(String key, Object? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else {
      await _prefs.setString(key, jsonEncode(value));
    }
  }

  T? read<T>(String key) {
    final value = _prefs.get(key);
    return value is T ? value : null;
  }

  dynamic readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  Future<void> remove(String key) async => _prefs.remove(key);
}

abstract final class StorageKeys {
  static const token = 'access_token';
  static const user = 'current_user';
  static const library = 'library_entries';
  static const searchHistory = 'search_history';
  static const readerSettings = 'reader_settings';
  static const notifyEnabled = 'notify_enabled';
  static const readingReminder = 'reading_reminder';
}
