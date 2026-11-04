import 'dart:io';

import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class ReportFormController extends GetxController {
  final Rxn<File> selectedImage = Rxn<File>();

  final RxBool isLoadingLocation = true.obs;
  final Rxn<Position> currentPosition = Rxn<Position>();
  final RxString locationError = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Menerima arguments yang dikirim bisa berupa String (path) atau XFile (jaga-jaga)
    final dynamic argument = Get.arguments;

    if (argument != null) {
      if (argument is String) {
        selectedImage.value = File(argument);
      } else if (argument is XFile) {
        selectedImage.value = File(argument.path);
      }
    }

    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoadingLocation.value = true;
      locationError.value = '';

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        locationError.value = 'GPS belum diaktifkan.';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        locationError.value = 'Izin lokasi belum diberikan.';
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        locationError.value =
            'Izin lokasi ditolak permanen. Aktifkan melalui pengaturan HP.';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      currentPosition.value = position;
    } catch (e) {
      locationError.value = 'Gagal mendapatkan lokasi.';
    } finally {
      isLoadingLocation.value = false;
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }
}
