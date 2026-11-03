
import 'package:camera/camera.dart';
import 'package:get/get.dart';

class ReportCameraController extends GetxController {
  final Rxn<CameraController> cameraController =
      Rxn<CameraController>();

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

  static const double _darkThreshold = 50;
  static const double _brightThreshold = 70;
  static const int _requiredFlashFrames = 8;

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
        (camera) =>
            camera.lensDirection == CameraLensDirection.back,
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
      isCameraReady.value = true;

      await controller.startImageStream(_checkBrightness);
    } catch (e) {
      errorMessage.value =
          'Gagal membuka kamera: ${e.toString()}';
    }
  }

  void _checkBrightness(CameraImage image) {
    if (image.planes.isEmpty ||
        isTakingPicture.value) {
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

    if (average < _darkThreshold) {
      isTooDark.value = true;
      isBrightnessReady.value = true;

      if (!isFlashOn.value && !_isCheckingFlash) {
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
      if (isFlashOn.value && _flashCheckFrames <
          _requiredFlashFrames) {
        _flashCheckFrames++;
        return;
      }

      isTooDark.value = false;
      isBrightnessReady.value = true;
      flashUnavailable.value = false;
      isAutoFlash.value = false;
    }
  }

  Future<void> _enableAutoFlash() async {
    if (_isCheckingFlash) return;

    _isCheckingFlash = true;

    try {
      final controller = cameraController.value;

      if (controller == null ||
          !controller.value.isInitialized) {
        return;
      }

      await controller.setFlashMode(FlashMode.torch);

      isFlashOn.value = true;
      isAutoFlash.value = true;
      _flashCheckFrames = 0;
    } catch (e) {
      flashUnavailable.value = true;
      isTooDark.value = true;
    } finally {
      _isCheckingFlash = false;
    }
  }

  Future<void> toggleFlash() async {
    final controller = cameraController.value;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }

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

    if (controller == null ||
        !controller.value.isInitialized ||
        isTakingPicture.value ||
        isTooDark.value ||
        !isBrightnessReady.value) {
      return;
    }

    try {
      isTakingPicture.value = true;

      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }

      final image = await controller.takePicture();

      Get.back<XFile>(result: image);
    } catch (e) {
      errorMessage.value =
          'Gagal mengambil foto: ${e.toString()}';

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
