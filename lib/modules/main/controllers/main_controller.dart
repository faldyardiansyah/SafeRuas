import 'package:get/get.dart';
import 'package:saferuas/routes/app_routes.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void openReport() {
    Get.toNamed(AppRoutes.reportCamera);
  }
}
