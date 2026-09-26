import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/error_message.dart';
import '../../../data/providers/auth_provider.dart';

/// Sửa thông tin cá nhân và đổi mật khẩu.
class AccountController extends GetxController {
  AccountController(this._auth, this._provider);

  final AuthService _auth;
  final AuthProvider _provider;

  final formKey = GlobalKey<FormState>();
  late final name = TextEditingController(text: _auth.user.value?.name ?? '');
  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    name.dispose();
    currentPassword.dispose();
    newPassword.dispose();
    super.onClose();
  }

  Future<void> saveProfile() => _run(() async {
    await _auth.updateProfile(name: name.text.trim());
    Get.back();
    showMessage('Thông tin đã được cập nhật.');
  });

  Future<void> changePassword() => _run(() async {
    final message = await _provider.changePassword(currentPassword.text, newPassword.text);
    Get.back();
    showMessage(message ?? 'Mật khẩu đã được thay đổi thành công.');
  });

  Future<void> _run(Future<void> Function() action) async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await action();
    } catch (e) {
      showError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
