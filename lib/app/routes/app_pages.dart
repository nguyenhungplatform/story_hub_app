import 'package:get/get.dart';

import '../../features/auth/views/login_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../bindings/initial_binding.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.home, page: () => const HomeView(), binding: InitialBinding()),
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileView()),
  ];
}