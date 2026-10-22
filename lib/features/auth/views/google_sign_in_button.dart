import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

/// Dải "hoặc" + nút tiếp tục với Google, dùng chung cho màn đăng nhập và đăng ký.
class GoogleSignInSection extends StatelessWidget {
  const GoogleSignInSection({super.key, required this.controller});

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
