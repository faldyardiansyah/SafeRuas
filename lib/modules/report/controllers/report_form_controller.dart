import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/detection/models/detection_result.dart';
import '../../../core/detection/services/detection_service.dart';
import '../../../core/detection/deepseek/services/deepseek_service.dart';
import '../../../core/detection/deepseek/models/deepseek_analysis_result.dart';
import '../models/report_category.dart';

class ReportFormController extends GetxController {
  final Rxn<File> selectedImage = Rxn<File>();

  // Kategori laporan
  final Rx<ReportCategory> category = ReportCategory.jalanRusak.obs;

  // Lokasi GPS
  final RxBool isLoadingLocation = true.obs;
  final Rxn<Position> currentPosition = Rxn<Position>();
  final RxString locationError = ''.obs;

  // YOLO (jalan rusak)
  final DetectionService _detectionService = DetectionService();
  final RxBool isDetecting = false.obs;
  final RxList<DetectionResult> detections = <DetectionResult>[].obs;
  final Rxn<Uint8List> annotatedImageBytes = Rxn<Uint8List>();
  final RxString detectionError = ''.obs;

  // Groq (fasilitas umum)
  final GroqService _groqService = GroqService();
  final RxBool isAnalyzingGroq = false.obs;
  final Rxn<GroqAnalysisResult> groqResult = Rxn<GroqAnalysisResult>();
  final RxString groqError = ''.obs;

  bool get isProcessing => category.value == ReportCategory.jalanRusak
      ? isDetecting.value
      : isAnalyzingGroq.value;

  @override
  void onInit() {
    super.onInit();

    final dynamic argument = Get.arguments;

    if (argument is Map) {
      final path = argument['path'];
      if (path is String) selectedImage.value = File(path);
      final cat = argument['category'];
      if (cat is ReportCategory) category.value = cat;
    } else if (argument is String) {
      selectedImage.value = File(argument);
    } else if (argument is XFile) {
      selectedImage.value = File(argument.path);
    }

    getCurrentLocation();

    if (selectedImage.value != null) {
      runAnalysis();
    }
  }

  // ===== Kategori =====
  Future<void> runAnalysis() async {
    if (category.value == ReportCategory.jalanRusak) {
      await runDetection();
    } else {
      await runGroqAnalysis();
    }
  }

  void setCategory(ReportCategory value) {
    if (category.value == value) return;
    category.value = value;

    detections.clear();
    annotatedImageBytes.value = null;
    detectionError.value = '';
    groqResult.value = null;
    groqError.value = '';

    if (selectedImage.value != null) runAnalysis();
  }

  // ===== YOLO =====
  Future<void> runDetection() async {
    final file = selectedImage.value;
    if (file == null || isDetecting.value) return;

    try {
      isDetecting.value = true;
      detectionError.value = '';
      detections.clear();
      annotatedImageBytes.value = null;

      await _detectionService.loadModel();

      final Uint8List bytes = await file.readAsBytes();
      final results = await _detectionService.detect(bytes);
      detections.value = results;

      if (results.isNotEmpty) {
        annotatedImageBytes.value =
            _detectionService.drawDetections(bytes, results);
      }
    } catch (e) {
      detectionError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isDetecting.value = false;
    }
  }

  // ===== Groq =====
  Future<void> runGroqAnalysis() async {
    final file = selectedImage.value;
    if (file == null || isAnalyzingGroq.value) return;

    try {
      isAnalyzingGroq.value = true;
      groqError.value = '';
      groqResult.value = null;

      final bytes = await _compressForUpload(file);
      final result = await _groqService.analyzeImage(bytes);

      // User bisa saja ganti kategori / hapus foto saat request berjalan.
      if (category.value == ReportCategory.fasilitasUmum &&
          selectedImage.value == file) {
        groqResult.value = result;
      }
    } catch (e) {
      groqError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isAnalyzingGroq.value = false;
    }
  }

  Future<Uint8List> _compressForUpload(File file) async {
    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 1280,
        minHeight: 1280,
        quality: 80,
        format: CompressFormat.jpeg,
      );
      if (compressed != null) return compressed;
    } catch (_) {}
    return file.readAsBytes();
  }

  // ===== Lokasi =====
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

      currentPosition.value = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
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
    groqResult.value = null;
    groqError.value = '';
  }

  @override
  void onClose() {
    _detectionService.dispose();
    super.onClose();
  }
}