
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final RxInt currentStep = 0.obs;
  final RxDouble progress = 0.0.obs;
  final RxString loadingMessage =
      'Menyiapkan aplikasi'.obs;

  final List<String> loadingSteps = [
    'Menyiapkan aplikasi',
    'Memeriksa koneksi',
    'Menyiapkan peta',
  ];

  @override
  void onInit() {
    super.onInit();
    startLoadingAnimation();
  }

  Future<void> startLoadingAnimation() async {
    for (int i = 0; i < loadingSteps.length; i++) {
      currentStep.value = i;
      loadingMessage.value = loadingSteps[i];
      progress.value = (i + 1) / loadingSteps.length;

      await Future.delayed(
        const Duration(milliseconds: 1800),
      );
    }

    if (isClosed) return;
    Get.offAllNamed(AppRoutes.onboarding);
  }
}
