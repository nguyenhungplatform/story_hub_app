import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/cover_image.dart';
import '../controllers/account_controller.dart';

class EditProfileView extends GetView<AccountController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthService>().user.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin cá nhân')),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: UserAvatar(url: user?.avatar, name: user?.displayName ?? '', size: 88),
            ),
            const SizedBox(height: 8),
            Center(child: Text(user?.email ?? '', style: AppTextStyles.caption)),
            const SizedBox(height: 28),
            AppTextField(
              controller: controller.name,
              label: 'Tên hiển thị',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v?.trim().length ?? 0) > 100 ? 'Tên tối đa 100 ký tự' : Validators.required(v),
            ),
            const SizedBox(height: 24),
            Obx(
              () => AppButton(
                label: 'Lưu thay đổi',
                isLoading: controller.isLoading.value,
                onPressed: controller.saveProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
