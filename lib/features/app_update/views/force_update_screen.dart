import 'package:flutter/material.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../data/models/app_config_model.dart';

/// Màn bắt buộc cập nhật: phủ toàn app, không có nút đóng, chặn Back và vuốt-back của iOS.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key, required this.info, required this.onUpdate});

  final UpdateInfo info;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(AppConstants.logo, width: 96, height: 96),
                ),
                const SizedBox(height: 28),
                Text(
                  info.title ?? AppStrings.updateDefaultTitle,
                  style: AppTextStyles.headline,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  info.message ?? AppStrings.updateDefaultMessage,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                FilledButton(
                  onPressed: onUpdate,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  child: const Text(AppStrings.updateNow),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
