import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/account_controller.dart';

class ChangePasswordView extends GetView<AccountController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đổi mật khẩu')),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(
              controller: controller.currentPassword,
              label: 'Mật khẩu hiện tại',
              icon: Icons.lock_outline_rounded,
              obscure: true,
              validator: Validators.password,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: controller.newPassword,
              label: 'Mật khẩu mới',
              icon: Icons.lock_reset_rounded,
              obscure: true,
              validator: Validators.password,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Nhập lại mật khẩu mới',
              icon: Icons.lock_reset_rounded,
              obscure: true,
              validator: (v) => v != controller.newPassword.text ? 'Mật khẩu nhập lại không khớp' : null,
            ),
            const SizedBox(height: 24),
            Obx(
              () => AppButton(
                label: 'Cập nhật mật khẩu',
                isLoading: controller.isLoading.value,
                onPressed: controller.changePassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
