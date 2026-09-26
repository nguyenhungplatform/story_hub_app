import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, required this.subtitle, required this.children, this.formKey});

  final String title;
  final String subtitle;
  final List<Widget> children;
  final GlobalKey<FormState>? formKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(backgroundColor: AppColors.paper),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6FA8FF), AppColors.primary]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.cloud_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              Text(title, style: AppTextStyles.display),
              const SizedBox(height: 8),
              Text(subtitle, style: AppTextStyles.body.copyWith(color: AppColors.muted)),
              const SizedBox(height: 28),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
