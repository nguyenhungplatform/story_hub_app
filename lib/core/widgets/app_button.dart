import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onPressed, this.isLoading = false, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
        : Text(label);
    if (icon != null && !isLoading) {
      return FilledButton.icon(onPressed: onPressed, icon: Icon(icon, size: 20), label: child);
    }
    return FilledButton(onPressed: isLoading ? null : onPressed, child: child);
  }
}
