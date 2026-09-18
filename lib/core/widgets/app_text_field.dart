import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, this.controller, this.hintText});

  final TextEditingController? controller;
  final String? hintText;

  @override
  Widget build(BuildContext context) => TextField(controller: controller, decoration: InputDecoration(hintText: hintText));
}