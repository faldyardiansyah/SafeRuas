import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saferuas/utils/app_colors.dart';

import '../controllers/report_camera_controller.dart';
import '../models/report_category.dart';

class ReportCameraView extends StatelessWidget {
  ReportCameraView({super.key});

  final ReportCameraController controller = Get.put(ReportCameraController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          final camera = controller.cameraController.value;
          final isFacility = controller.isFacility;

          if (controller.errorMessage.value.isNotEmpty &&
              !controller.isCameraReady.value) {
            return _buildError();
          }

          if (!controller.isCameraReady.value ||
              camera == null ||
              !camera.value.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return Stack(
            children: [
              Positioned.fill(child: CameraPreview(camera)),

              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.65),
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    _circleButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Get.back(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        isFacility
                            ? 'Laporkan Fasilitas Umum'
                            : 'Laporkan Kerusakan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _circleButton(
                      icon: controller.isFlashOn.value
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      onTap: controller.toggleFlash,
                      active: controller.isFlashOn.value,
                    ),
                  ],
                ),
              ),

              // Toggle kategori
              Positioned(
                top: 76,
                left: 24,
                right: 24,
                child: Row(
                  children: [
                    _categoryChip(
                      'Jalan Rusak',
                      Icons.add_road_rounded,
                      ReportCategory.jalanRusak,
                    ),
                    const SizedBox(width: 10),
                    _categoryChip(
                      'Fasilitas Umum',
                      Icons.lightbulb_outline_rounded,
                      ReportCategory.fasilitasUmum,
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 120,
                left: 24,
                right: 24,
                child: Column(
                  children: [
                    Text(
                      isFacility
                          ? 'Deteksi Fasilitas Umum'
                          : 'Deteksi Kerusakan Jalan',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isFacility
                          ? 'Arahkan kamera ke lampu jalan, rambu, atau fasilitas yang bermasalah'
                          : 'Arahkan kamera ke bagian jalan yang rusak',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Center(
                child: Container(
                  width: 280,
                  height: 350,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),

              Positioned(
                left: 24,
                right: 24,
                bottom: 125,
                child: _buildBrightnessStatus(),
              ),

              Positioned(
                left: 24,
                right: 24,
                bottom: 30,
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: controller.canShoot
                        ? controller.takePicture
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isTakingPicture.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Ambil Foto',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _categoryChip(String label, IconData icon, ReportCategory value) {
    final selected = controller.category.value == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setCategory(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Colors.white.withOpacity(0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrightnessStatus() {
    final ready = controller.isBrightnessReady.value;
    final dark = controller.isTooDark.value;
    final flash = controller.isFlashOn.value;
    final unavailable = controller.flashUnavailable.value;
    final facility = controller.isFacility;

    Color statusColor;
    IconData statusIcon;
    String message;

    if (!ready) {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_top_rounded;
      message = 'Memeriksa pencahayaan kamera...';
    } else if (facility && dark) {
      statusColor = Colors.orange;
      statusIcon = Icons.nights_stay_rounded;
      message =
          'Kondisi gelap. Foto fasilitas tetap bisa diambil. '
          'Nyalakan flash jika objek dekat.';
    } else if (!dark) {
      statusColor = AppColors.primary;
      statusIcon = Icons.check_circle_outline_rounded;
      message = 'Pencahayaan cukup. Kamu bisa mengambil foto.';
    } else if (unavailable) {
      statusColor = Colors.redAccent;
      statusIcon = Icons.warning_amber_rounded;
      message = 'Flash tidak tersedia. Cari tempat yang lebih terang.';
    } else if (flash) {
      statusColor = Colors.orange;
      statusIcon = Icons.flash_on_rounded;
      message = 'Flash sudah menyala. Menyesuaikan pencahayaan...';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.dark_mode_rounded;
      message = 'Kondisi gelap. Menyalakan flash otomatis...';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: AppColors.primary, size: 23),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.initializeCamera,
              child: const Text('Coba Lagi'),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Kembali',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
