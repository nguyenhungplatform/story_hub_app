import 'package:get/get.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/views/forgot_password_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/genre/controllers/genre_controller.dart';
import '../../features/genre/views/genre_view.dart';
import '../../features/notifications/views/notifications_view.dart';
import '../../features/profile/controllers/account_controller.dart';
import '../../features/profile/views/change_password_view.dart';
import '../../features/profile/views/edit_profile_view.dart';
import '../../features/reader/controllers/reader_controller.dart';
import '../../features/reader/views/reader_view.dart';
import '../../features/search/controllers/search_controller.dart';
import '../../features/search/views/search_view.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/shell/views/main_shell.dart';
import '../../features/story_detail/controllers/story_detail_controller.dart';
import '../../features/story_detail/views/story_detail_view.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.main, page: () => const MainShell()),
    GetPage(
      name: AppRoutes.storyDetail,
      page: () => StoryDetailView(slug: Get.arguments as String),
      binding: BindingsBuilder(() {
        Get.put(StoryDetailController(Get.find(), Get.find(), Get.find(), Get.find()), tag: Get.arguments as String);
      }),
    ),
    GetPage(
      name: AppRoutes.reader,
      page: () => const ReaderView(),
      binding: BindingsBuilder(() {
        Get.put(ReaderController(Get.find(), Get.find(), Get.find()));
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      binding: BindingsBuilder(() {
        Get.put(StorySearchController(Get.find(), Get.find(), Get.find()));
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.genre,
      page: () => const GenreView(),
      binding: BindingsBuilder(() {
        Get.put(GenreController(Get.find()));
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.put(AuthController(Get.find(), Get.find()));
      }),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.put(AuthController(Get.find(), Get.find()), tag: 'register');
      }),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: BindingsBuilder(() {
        Get.put(AuthController(Get.find(), Get.find()), tag: 'forgot');
      }),
    ),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationsView()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsView()),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: BindingsBuilder(() {
        Get.put(AccountController(Get.find(), Get.find()));
      }),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
      binding: BindingsBuilder(() {
        Get.put(AccountController(Get.find(), Get.find()));
      }),
    ),
  ];
}
