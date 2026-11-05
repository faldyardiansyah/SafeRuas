import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:saferuas/routes/app_routes.dart';

import '../models/report_category.dart';

class ReportCameraController extends GetxController {
  final Rxn<CameraController> cameraController = Rxn<CameraController>();

  final Rx<ReportCategory> category = ReportCategory.jalanRusak.obs;

  final RxBool isCameraReady = false.obs;
  final RxBool isTakingPicture = false.obs;
  final RxBool isFlashOn = false.obs;
  final RxBool isTooDark = true.obs;
  final RxBool isBrightnessReady = false.obs;
  final RxBool isAutoFlash = false.obs;
  final RxBool flashUnavailable = false.obs;

  final RxDouble brightness = 0.0.obs;
  final RxString errorMessage = ''.obs;

  bool _isCheckingFlash = false;
  int _flashCheckFrames = 0;

  bool _flashIsAuto = false;
  int _autoOffBrightFrames = 0;
  DateTime? _lastAutoOffAt;
  bool _autoOffLocked = false;

  static const double _darkThreshold = 50;
  static const double _brightThreshold = 70;
  static const int _requiredFlashFrames = 8;

  // Atur dua angka ini kalau flash terlalu lama mati atau sering nyala-mati
  static const double _autoOffThreshold = 130;
  static const int _autoOffRequiredFrames = 15;
  static const Duration _autoOffRetryWindow = Duration(seconds: 4);

  bool get isFacility => category.value == ReportCategory.fasilitasUmum;

  // Fasilitas umum boleh gelap karena lampu jalan mati difoto malam hari
  bool get canShoot {
    if (!isCameraReady.value || isTakingPicture.value) return false;
    if (isFacility) return true;
    return !isTooDark.value && isBrightnessReady.value;
  }

  void setCategory(ReportCategory value) {
    if (category.value == value) return;
    category.value = value;

    _autoOffLocked = false;
    _lastAutoOffAt = null;

    if (isFacility && _flashIsAuto && isFlashOn.value) {
      _disableAutoFlash();
    }
  }

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      errorMessage.value = '';
      isCameraReady.value = false;
      isBrightnessReady.value = false;
      isTooDark.value = true;
      flashUnavailable.value = false;

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('Kamera tidak ditemukan.');
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      cameraController.value = controller;

      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);

      isFlashOn.value = false;
      _flashIsAuto = false;
      isCameraReady.value = true;

      await controller.startImageStream(_checkBrightness);
    } catch (e) {
      errorMessage.value = 'Gagal membuka kamera: ${e.toString()}';
    }
  }

  void _checkBrightness(CameraImage image) {
    if (image.planes.isEmpty || isTakingPicture.value) {
      return;
    }

    final pixels = image.planes.first.bytes;

    if (pixels.isEmpty) return;

    int totalBrightness = 0;
    int sampledPixels = 0;

    const int sampleStep = 16;

    for (int i = 0; i < pixels.length; i += sampleStep) {
      totalBrightness += pixels[i];
      sampledPixels++;
    }

    if (sampledPixels == 0) return;

    final average = totalBrightness / sampledPixels;

    brightness.value = average / 255;

    if (isFacility) {
      isTooDark.value = average < _darkThreshold;
      isBrightnessReady.value = true;
      return;
    }

    if (average < _autoOffThreshold) {
      _autoOffBrightFrames = 0;
    }

    if (average < _darkThreshold) {
      isTooDark.value = true;
      isBrightnessReady.value = true;

      if (!isFlashOn.value && !_isCheckingFlash) {
        // Gelap lagi tak lama setelah flash dimatikan = terangnya dari flash,
        // kunci supaya flash tidak berkedip nyala-mati
        final last = _lastAutoOffAt;
        if (last != null &&
            DateTime.now().difference(last) < _autoOffRetryWindow) {
          _autoOffLocked = true;
        }
        _enableAutoFlash();
      }

      if (isFlashOn.value) {
        _flashCheckFrames++;

        if (_flashCheckFrames >= _requiredFlashFrames) {
          isTooDark.value = true;
        }
      }

      return;
    }

    if (average >= _brightThreshold) {
      if (isFlashOn.value && _flashCheckFrames < _requiredFlashFrames) {
        _flashCheckFrames++;
        return;
      }

      isTooDark.value = false;
      isBrightnessReady.value = true;
      flashUnavailable.value = false;
      isAutoFlash.value = false;

      if (_flashIsAuto &&
          isFlashOn.value &&
          !_autoOffLocked &&
          average >= _autoOffThreshold) {
        _autoOffBrightFrames++;

        if (_autoOffBrightFrames >= _autoOffRequiredFrames) {
          _disableAutoFlash();
        }
      }
    }
  }

  Future<void> _enableAutoFlash() async {
    if (_isCheckingFlash) return;

    _isCheckingFlash = true;

    try {
      final controller = cameraController.value;

      if (controller == null || !controller.value.isInitialized) {
        return;
      }

      await controller.setFlashMode(FlashMode.torch);

      isFlashOn.value = true;
      isAutoFlash.value = true;
      _flashIsAuto = true;
      _flashCheckFrames = 0;
      _autoOffBrightFrames = 0;
    } catch (e) {
      flashUnavailable.value = true;
      isTooDark.value = true;
    } finally {
      _isCheckingFlash = false;
    }
  }

  Future<void> _disableAutoFlash() async {
    if (_isCheckingFlash) return;

    _isCheckingFlash = true;

    try {
      final controller = cameraController.value;

      if (controller == null || !controller.value.isInitialized) {
        return;
      }

      await controller.setFlashMode(FlashMode.off);

      isFlashOn.value = false;
      isAutoFlash.value = false;
      _flashIsAuto = false;
      _flashCheckFrames = 0;
      _autoOffBrightFrames = 0;
      _lastAutoOffAt = DateTime.now();
    } catch (e) {
      // Gagal mematikan: biarkan flash tetap menyala
    } finally {
      _isCheckingFlash = false;
    }
  }

  // Tombol manual tidak ikut aturan flash otomatis
  Future<void> toggleFlash() async {
    final controller = cameraController.value;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    _flashIsAuto = false;
    _autoOffLocked = false;
    _lastAutoOffAt = null;
    _autoOffBrightFrames = 0;

    try {
      if (isFlashOn.value) {
        await controller.setFlashMode(FlashMode.off);

        isFlashOn.value = false;
        isAutoFlash.value = false;
        _flashCheckFrames = 0;
        isTooDark.value = true;
        isBrightnessReady.value = false;
      } else {
        await controller.setFlashMode(FlashMode.torch);

        isFlashOn.value = true;
        isAutoFlash.value = false;
        flashUnavailable.value = false;
        _flashCheckFrames = 0;
        isTooDark.value = true;
        isBrightnessReady.value = false;
      }
    } catch (e) {
      flashUnavailable.value = true;
      isTooDark.value = true;
    }
  }

  Future<void> takePicture() async {
    final controller = cameraController.value;

    if (controller == null || !controller.value.isInitialized || !canShoot) {
      return;
    }

    try {
      isTakingPicture.value = true;

      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }

      final image = await controller.takePicture();

      isTakingPicture.value = false;

      // Stream brightness dinyalakan lagi setelah user kembali dari form
      await Get.toNamed(
        AppRoutes.reportForm,
        arguments: {'path': image.path, 'category': category.value},
      );

      if (!isClosed &&
          controller.value.isInitialized &&
          !controller.value.isStreamingImages) {
        await controller.startImageStream(_checkBrightness);
      }
    } catch (e) {
      errorMessage.value = 'Gagal mengambil foto: ${e.toString()}';

      if (controller.value.isInitialized &&
          !controller.value.isStreamingImages) {
        await controller.startImageStream(_checkBrightness);
      }
    } finally {
      isTakingPicture.value = false;
    }
  }

  @override
  void onClose() {
    cameraController.value?.dispose();
    super.onClose();
  }
}