import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/reader_settings_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/error_message.dart';
import '../../../data/repositories/library_repository.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../reader/views/widgets/reader_settings_sheet.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final storage = Get.find<StorageService>();
  final reader = Get.find<ReaderSettingsService>();

  late bool _notify = storage.read<bool>(StorageKeys.notifyEnabled) ?? true;
  late bool _reminder = storage.read<bool>(StorageKeys.readingReminder) ?? false;

  Future<void> _pick<T>(String title, List<T> values, String Function(T) label, Rx<T> target) async {
    final value = await Get.bottomSheet<T>(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: AppTextStyles.title),
            ),
            for (final v in values)
              ListTile(
                title: Text(label(v)),
                trailing: target.value == v ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                onTap: () => Get.back(result: v),
              ),
          ],
        ),
      ),
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    );
    if (value != null) target.value = value;
  }

  Future<void> _clearHistory() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xoá lịch sử đọc?'),
        content: const Text('Tiến độ đọc của mọi truyện sẽ bị xoá. Truyện yêu thích và theo dõi vẫn được giữ.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Huỷ')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Xoá', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await Get.find<LibraryRepository>().clearHistory();
      showMessage('Đã xoá lịch sử đọc');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _Header('Tùy chọn đọc'),
            _Group(
              children: [
                _Row(
                  leading: const Text('Aa', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  label: 'Cỡ chữ',
                  value: '${reader.fontSizeLabel} (${reader.fontSize.value.round()})',
                  onTap: showReaderSettings,
                ),
                _Row(
                  leading: const Icon(Icons.font_download_outlined, size: 22),
                  label: 'Kiểu chữ',
                  value: reader.font.value.label,
                  onTap: () => _pick('Kiểu chữ', ReaderFont.values, (f) => f.label, reader.font),
                ),
                _Row(
                  leading: const Icon(Icons.contrast_rounded, size: 22),
                  label: 'Chế độ nền',
                  value: reader.background.value.label,
                  onTap: () => _pick('Chế độ nền', ReaderBackground.values, (b) => b.label, reader.background),
                ),
                ListTile(
                  leading: const Icon(Icons.light_mode_outlined, size: 22, color: AppColors.ink),
                  title: const Text('Độ sáng', style: AppTextStyles.body),
                  trailing: SizedBox(
                    width: 170,
                    child: Slider(value: reader.brightness.value, min: 0.3, max: 1, onChanged: reader.brightness.call),
                  ),
                ),
              ],
            ),
            const _Header('Thông báo'),
            _Group(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_none_rounded, color: AppColors.ink),
                  title: const Text('Nhận thông báo', style: AppTextStyles.body),
                  subtitle: const Text('Chương mới của truyện đang theo dõi', style: AppTextStyles.tiny),
                  value: _notify,
                  onChanged: (v) {
                    setState(() => _notify = v);
                    storage.write(StorageKeys.notifyEnabled, v);
                    Get.find<NotificationsController>().refreshUnread();
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.alarm_rounded, color: AppColors.ink),
                  title: const Text('Nhắc nhở đọc truyện', style: AppTextStyles.body),
                  value: _reminder,
                  onChanged: (v) {
                    setState(() => _reminder = v);
                    storage.write(StorageKeys.readingReminder, v);
                  },
                ),
              ],
            ),
            const _Header('Khác'),
            _Group(
              children: [
                const _Row(leading: Icon(Icons.language_rounded, size: 22), label: 'Ngôn ngữ', value: 'Tiếng Việt'),
                _Row(
                  leading: const Icon(Icons.delete_sweep_outlined, size: 22),
                  label: 'Xoá lịch sử đọc',
                  onTap: _clearHistory,
                ),
                const _Row(
                  leading: Icon(Icons.info_outline_rounded, size: 22),
                  label: 'Phiên bản',
                  value: 'v${AppConstants.version}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
    child: Text(text, style: AppTextStyles.title),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias,
    child: Column(children: children),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.leading, required this.label, this.value, this.onTap});

  final Widget leading;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: IconTheme(
        data: const IconThemeData(color: AppColors.ink),
        child: SizedBox(width: 24, child: Center(child: leading)),
      ),
      title: Text(label, style: AppTextStyles.body),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) Text(value!, style: AppTextStyles.caption),
          if (onTap != null) const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
