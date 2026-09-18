import 'package:flutter/material.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => ListTile(title: Text(title), leading: const Icon(Icons.menu_book_outlined));
}