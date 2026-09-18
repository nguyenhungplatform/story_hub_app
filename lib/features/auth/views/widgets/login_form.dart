import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) => const Column(children: [TextField(), SizedBox(height: 12), TextField(obscureText: true)]);
}