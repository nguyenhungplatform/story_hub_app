import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, this.name = 'Bạn đọc Story Hub'});

  final String name;

  @override
  Widget build(BuildContext context) => ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(name));
}