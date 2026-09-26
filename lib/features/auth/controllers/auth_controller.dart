import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/error_message.dart';
import '../../../data/providers/auth_provider.dart';
import '../../notifications/controllers/notifications_controller.dart';

class AuthController extends GetxController {
  AuthController(this._auth, this._provider);

  final AuthService _auth;
  final AuthProvider _provider;

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await _auth.login(email.text.trim(), password.text);
      Get.find<NotificationsController>().refreshUnread();
      Get.back(result: true);
      showMessage('Chào mừng ${_auth.user.value?.displayName ?? ''} quay trở lại!');
    } catch (e) {
      showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await _provider.register(name.text.trim(), email.text.trim(), password.text);
      await _auth.login(email.text.trim(), password.text);
      // Đóng màn đăng ký và màn đăng nhập phía sau.
      Get.until((route) => route.settings.name != AppRoutes.register && route.settings.name != AppRoutes.login);
      showMessage('Đăng ký thành công!');
    } catch (e) {
      showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final message = await _provider.forgotPassword(email.text.trim());
      Get.back();
      showMessage(message ?? 'Vui lòng kiểm tra email để đặt lại mật khẩu.');
    } catch (e) {
      showError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
