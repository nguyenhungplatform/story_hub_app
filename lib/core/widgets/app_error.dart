import 'package:flutter/material.dart';

class AppError extends StatelessWidget {
  const AppError({super.key, this.message = 'Đã có lỗi xảy ra'});

  final String message;

  @override
  Widget build(BuildContext context) => Center(child: Text(message));
}