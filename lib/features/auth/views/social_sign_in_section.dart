import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

/// Dải "hoặc" + các nút đăng nhập Apple (chỉ iOS) và Google, dùng chung cho màn đăng nhập và đăng ký.
class SocialSignInSection extends StatelessWidget {
  const SocialSignInSection({super.key, required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('hoặc', style: TextStyle(color: AppColors.muted)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.supportsAppleSignIn) ...[
          Obx(() => _AppleButton(loading: controller.isAppleLoading.value, onPressed: controller.loginWithApple)),
          const SizedBox(height: 12),
        ],
        Obx(() {
          final loading = controller.isGoogleLoading.value;
          return OutlinedButton(
            onPressed: loading ? null : controller.loginWithGoogle,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'G',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF4285F4)),
                      ),
                      SizedBox(width: 12),
                      Text('Tiếp tục với Google'),
                    ],
                  ),
          );
        }),
      ],
    );
  }
}

/// Nút theo hướng dẫn giao diện của Apple: nền đen, logo Apple trắng.
class _AppleButton extends StatelessWidget {
  const _AppleButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.black87,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apple, size: 24),
                SizedBox(width: 10),
                Text('Tiếp tục với Apple', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
    );
  }
}
