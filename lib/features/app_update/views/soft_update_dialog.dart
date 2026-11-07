import 'package:flutter/material.dart';

import '../../../app/constants/app_strings.dart';
import '../../../data/models/app_config_model.dart';

/// Kết quả khi người dùng bấm nút của [SoftUpdateDialog]; `null` khi đóng bằng cách chạm ra ngoài / Back.
enum SoftUpdateAction { update, later }

class SoftUpdateDialog extends StatelessWidget {
  const SoftUpdateDialog({super.key, required this.info});

  final UpdateInfo info;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(info.title ?? AppStrings.updateDefaultTitle),
      content: info.message == null ? null : Text(info.message!),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(SoftUpdateAction.later),
          child: const Text(AppStrings.later),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(SoftUpdateAction.update),
          child: const Text(AppStrings.update),
        ),
      ],
    );
  }
}
