import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import 'auth_scaffold.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  String get tag => 'register';

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      formKey: controller.formKey,
      title: 'Tạo tài khoản',
      subtitle: 'Chỉ mất vài giây để bắt đầu hành trình đọc truyện của bạn.',
      children: [
        AppTextField(
          controller: controller.name,
          hintText: 'Tên hiển thị',
          icon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          validator: (v) => (v?.trim().length ?? 0) > 100 ? 'Tên tối đa 100 ký tự' : Validators.required(v),
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: controller.email,
          hintText: 'Email',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: Validators.email,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: controller.password,
          hintText: 'Mật khẩu (tối thiểu 6 ký tự)',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          validator: Validators.password,
          onSubmitted: (_) => controller.register(),
        ),
        const SizedBox(height: 24),
        Obx(() => AppButton(label: 'Đăng ký', isLoading: controller.isLoading.value, onPressed: controller.register)),
      ],
    );
  }
}
