import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.label,
    this.icon,
    this.obscure = false,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? label;
  final IconData? icon;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.label,
        prefixIcon: widget.icon == null ? null : Icon(widget.icon, color: AppColors.muted, size: 20),
        suffixIcon: widget.obscure
            ? IconButton(
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                color: AppColors.muted,
              )
            : null,
      ),
    );
  }
}
