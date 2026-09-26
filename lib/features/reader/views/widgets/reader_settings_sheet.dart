import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/reader_settings_service.dart';

void showReaderSettings() => Get.bottomSheet(
  const ReaderSettingsSheet(),
  backgroundColor: AppColors.paper,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
);

class ReaderSettingsSheet extends StatelessWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Get.find<ReaderSettingsService>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Cỡ chữ', style: AppTextStyles.subtitle),
              Row(
                children: [
                  const Text('A', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Slider(
                      value: s.fontSize.value,
                      min: ReaderSettingsService.minFont,
                      max: ReaderSettingsService.maxFont,
                      divisions: 14,
                      label: s.fontSize.value.round().toString(),
                      onChanged: s.fontSize.call,
                    ),
                  ),
                  const Text('A', style: TextStyle(fontSize: 24)),
                ],
              ),
              const Text('Giãn dòng', style: AppTextStyles.subtitle),
              Slider(value: s.lineHeight.value, min: 1.3, max: 2.2, divisions: 9, onChanged: s.lineHeight.call),
              const Text('Kiểu chữ', style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final font in ReaderFont.values)
                    ChoiceChip(
                      label: Text(font.label, style: TextStyle(fontFamily: font.family)),
                      selected: s.font.value == font,
                      onSelected: (_) => s.font.value = font,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Màu nền', style: AppTextStyles.subtitle),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final bg in ReaderBackground.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => s.background.value = bg,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: bg.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: s.background.value == bg ? AppColors.primary : AppColors.line,
                              width: s.background.value == bg ? 2.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'A',
                              style: TextStyle(color: bg.foreground, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
