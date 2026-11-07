import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class LinkLauncher {
  /// Mở một trang web bằng trình duyệt ngoài.
  static Future<void> openUrl(String url) async {
    final ok = await _launch(Uri.parse(url));
    if (!ok) _toast('Không mở được liên kết', url);
  }

  /// Mở ứng dụng mail để gửi tới [email]. Nếu máy không có ứng dụng mail,
  /// sao chép địa chỉ vào bộ nhớ tạm.
  static Future<void> sendEmail(String email, {String? subject}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: subject == null ? null : 'subject=${Uri.encodeComponent(subject)}',
    );
    final ok = await _launch(uri);
    if (!ok) {
      await Clipboard.setData(ClipboardData(text: email));
      _toast('Đã sao chép email', email);
    }
  }

  static Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static void _toast(String title, String message) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
  }
}
