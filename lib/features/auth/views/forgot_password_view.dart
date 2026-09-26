import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import 'auth_scaffold.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  String get tag => 'forgot';

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      formKey: controller.formKey,
      title: 'Quên mật khẩu',
      subtitle: 'Nhập email đã đăng ký, chúng tôi sẽ gửi link đặt lại mật khẩu (hiệu lực 1 giờ).',
      children: [
        AppTextField(
          controller: controller.email,
          hintText: 'Email',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          onSubmitted: (_) => controller.forgotPassword(),
        ),
        const SizedBox(height: 24),
        Obx(
          () => AppButton(
            label: 'Gửi link đặt lại',
            isLoading: controller.isLoading.value,
            onPressed: controller.forgotPassword,
          ),
        ),
      ],
    );
  }
}
