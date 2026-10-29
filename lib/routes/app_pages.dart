import 'package:get/get.dart';
import 'package:saferuas/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:saferuas/modules/onboarding/views/onboarding_view.dart';

import '../modules/splash/controllers/splash_controller.dart';
import '../modules/splash/views/splash_view.dart';
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
  ];
}
