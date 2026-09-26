import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../storage/storage_service.dart';

enum ReaderBackground {
  light('Nền sáng', AppColors.readerLight, AppColors.ink),
  sepia('Nền giấy', AppColors.readerSepia, Color(0xFF3B3226)),
  green('Nền xanh', AppColors.readerGreen, Color(0xFF26331F)),
  dark('Nền tối', AppColors.readerDark, Color(0xFFC9CDD6));

  const ReaderBackground(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}

enum ReaderFont {
  system('System', null),
  serif('Serif', 'serif'),
  mono('Monospace', 'monospace');

  const ReaderFont(this.label, this.family);

  final String label;
  final String? family;
}

class ReaderSettingsService extends GetxService {
  ReaderSettingsService(this._storage);

  final StorageService _storage;

  static const minFont = 14.0;
  static const maxFont = 28.0;

  final fontSize = 18.0.obs;
  final lineHeight = 1.7.obs;
  final background = ReaderBackground.sepia.obs;
  final font = ReaderFont.serif.obs;

  /// Độ sáng lớp phủ trong màn đọc (0.3 – 1.0), không đổi độ sáng hệ thống.
  final brightness = 1.0.obs;

  ReaderSettingsService init() {
    final raw = _storage.readJson(StorageKeys.readerSettings);
    if (raw is Map<String, dynamic>) {
      fontSize.value = (raw['fontSize'] as num?)?.toDouble() ?? fontSize.value;
      lineHeight.value = (raw['lineHeight'] as num?)?.toDouble() ?? lineHeight.value;
      brightness.value = (raw['brightness'] as num?)?.toDouble() ?? brightness.value;
      background.value = ReaderBackground.values.asNameMap()[raw['background']] ?? background.value;
      font.value = ReaderFont.values.asNameMap()[raw['font']] ?? font.value;
    }
    everAll([fontSize, lineHeight, background, font, brightness], (_) => _persist());
    return this;
  }

  String get fontSizeLabel => switch (fontSize.value) {
    < 16 => 'Small',
    < 20 => 'Medium',
    < 24 => 'Large',
    _ => 'Extra large',
  };

  void _persist() => _storage.write(StorageKeys.readerSettings, {
    'fontSize': fontSize.value,
    'lineHeight': lineHeight.value,
    'brightness': brightness.value,
    'background': background.value.name,
    'font': font.value.name,
  });
}
