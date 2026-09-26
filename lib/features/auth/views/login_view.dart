import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import 'auth_scaffold.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      formKey: controller.formKey,
      title: 'Đăng nhập',
      subtitle: 'Đồng bộ truyện yêu thích, theo dõi và nhận thông báo chương mới.',
      children: [
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
          hintText: 'Mật khẩu',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          textInputAction: TextInputAction.done,
          validator: Validators.password,
          onSubmitted: (_) => controller.login(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
            child: const Text('Quên mật khẩu?'),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => AppButton(label: 'Đăng nhập', isLoading: controller.isLoading.value, onPressed: controller.login)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Chưa có tài khoản?', style: TextStyle(color: AppColors.muted)),
            TextButton(onPressed: () => Get.toNamed(AppRoutes.register), child: const Text('Đăng ký ngay')),
          ],
        ),
      ],
    );
  }
}
