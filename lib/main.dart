import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/bindings/initial_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const StoryHubApp());
}
