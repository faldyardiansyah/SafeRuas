import 'package:get/get.dart';
import 'package:saferuas/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:saferuas/modules/onboarding/views/onboarding_view.dart';
import 'package:saferuas/modules/auth/controllers/login_controller.dart';
import 'package:saferuas/modules/auth/views/login_view.dart';
import 'package:saferuas/modules/auth/controllers/register_controller.dart';
import 'package:saferuas/modules/auth/views/register_view.dart';
import '../modules/splash/controllers/splash_controller.dart';
import '../modules/splash/views/splash_view.dart';
import 'package:saferuas/modules/main/views/main_view.dart';
import 'package:saferuas/modules/main/controllers/main_controller.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashController>(() => SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OnboardingController>(() => OnboardingController());
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RegisterController>(() => RegisterController());
      }),
    ),
    GetPage(
      name: '/main',
      page: () => MainView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MainController>(() => MainController());
      }),
    ),
  ];
}