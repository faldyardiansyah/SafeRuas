import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/detection/models/detection_result.dart';
import '../../../core/detection/services/detection_service.dart';

class ReportFormController extends GetxController {
  final Rxn<File> selectedImage = Rxn<File>();

  // State Lokasi GPS
  final RxBool isLoadingLocation = true.obs;
  final Rxn<Position> currentPosition = Rxn<Position>();
  final RxString locationError = ''.obs;

  // Service & State Deteksi YOLO
  final DetectionService _detectionService = DetectionService();
  final RxBool isDetecting = false.obs;
  final RxList<DetectionResult> detections = <DetectionResult>[].obs;
  final Rxn<Uint8List> annotatedImageBytes = Rxn<Uint8List>();
  final RxString detectionError = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final dynamic argument = Get.arguments;

    if (argument != null) {
      if (argument is String) {
        selectedImage.value = File(argument);
      } else if (argument is XFile) {
        selectedImage.value = File(argument.path);
      }
    }

    getCurrentLocation();

    // Jalankan deteksi otomatis begitu foto tersedia
    if (selectedImage.value != null) {
      runDetection();
    }
  }

  /// Menjalankan pemindaian AI YOLO pada foto yang diambil
  Future<void> runDetection() async {
    final file = selectedImage.value;
    if (file == null) return;

    try {
      isDetecting.value = true;
      detectionError.value = '';
      detections.clear();
      annotatedImageBytes.value = null;

      // 1. Muat model jika belum dimuat
      await _detectionService.loadModel();

      // 2. Baca file gambar menjadi bytes
      final Uint8List bytes = await file.readAsBytes();

      // 3. Jalankan deteksi
      final results = await _detectionService.detect(bytes);
      detections.value = results;

      // 4. Jika ada kerusakan yang terdeteksi, gambar bounding box merah
      if (results.isNotEmpty) {
        final annotated = _detectionService.drawDetections(bytes, results);
        annotatedImageBytes.value = annotated;
      }
    } catch (e) {
      detectionError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isDetecting.value = false;
    }
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
    detections.clear();
    annotatedImageBytes.value = null;
    detectionError.value = '';
  }

  @override
  void onClose() {
    _detectionService.dispose();
    super.onClose();
  }
}