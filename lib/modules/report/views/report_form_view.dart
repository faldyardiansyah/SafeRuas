import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';

import '../../../utils/app_colors.dart';
import '../controllers/report_form_controller.dart';

class ReportFormView extends StatelessWidget {
  ReportFormView({super.key});

  final ReportFormController controller = Get.put(ReportFormController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate100,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.slate800,
            size: 20,
          ),
        ),
        title: Text(
          'Buat Laporan',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.slate800,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto Kerusakan Jalan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ketuk foto untuk masuk ke tampilan zoom & rotasi penuh.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),

            // Tampilan Foto + Kotak Deteksi YOLO (Bisa Diklik Masuk ke PhotoView)
            Obx(() {
              final File? image = controller.selectedImage.value;
              final annotated = controller.annotatedImageBytes.value;
              final isDetecting = controller.isDetecting.value;

              if (image == null) {
                return Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Foto belum tersedia',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  // Area Foto yang Bisa Diklik untuk Membuka PhotoView Layar Penuh
                  GestureDetector(
                    onTap: () => _openPhotoViewer(context, image, annotated),
                    child: Hero(
                      tag: 'report_photo_hero',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 240,
                          child: annotated != null
                              ? Image.memory(annotated, fit: BoxFit.cover)
                              : Image.file(image, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),

                  // Chip Petunjuk di Kiri Bawah Foto
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () => _openPhotoViewer(context, image, annotated),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.slate900.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.fullscreen_rounded,
                              color: AppColors.textWhite,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Buka Foto',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textWhite,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Overlay Loading saat AI Memindai
                  if (isDetecting)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.slate900.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'AI sedang mendeteksi kerusakan jalan...',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textWhite,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Tombol Hapus Foto
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: controller.removeImage,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                      ),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.dangerRed,
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 16),

            // Card Hasil Deteksi AI
            Obx(() {
              final isDetecting = controller.isDetecting.value;
              final detections = controller.detections;
              final error = controller.detectionError.value;

              if (isDetecting) return const SizedBox.shrink();

              // Card Error Deteksi
              if (error.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.dangerRed.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.dangerRed,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          error,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.dangerRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: controller.runDetection,
                        child: Text(
                          'Coba Lagi',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Card Daftar Kerusakan Terdeteksi
              if (detections.isNotEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.homeCardTint.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.homeChipTint),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.analytics_rounded,
                            color: AppColors.homeBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Terdeteksi ${detections.length} Titik Kerusakan:',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.slate900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: detections.map((d) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.homeChipTint),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 15,
                                  color: AppColors.amber500,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${d.displayName} (${d.confidencePercent})',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }

              // Card Kondisi Jalan Aman
              if (controller.selectedImage.value != null) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.emerald50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.emerald500.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.emerald600,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Kondisi jalan tampak aman / tidak terdeteksi kerusakan.',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.emerald700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            }),

            const SizedBox(height: 24),

            // Bagian Lokasi Laporan
            Text(
              'Lokasi Laporan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Lokasi diambil otomatis dari GPS perangkat Anda.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),

            // Card Koordinat GPS
            Obx(() {
              final position = controller.currentPosition.value;
              final isLoading = controller.isLoadingLocation.value;
              final errorMsg = controller.locationError.value;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.homeChipTint.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.homeBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Koordinat GPS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: controller.getCurrentLocation,
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: AppColors.homeBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (position != null) ...[
                      Text(
                        'Latitude',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        position.latitude.toStringAsFixed(6),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Longitude',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        position.longitude.toStringAsFixed(6),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Lokasi berhasil didapatkan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Text(
                        errorMsg.isNotEmpty
                            ? errorMsg
                            : 'Gagal mendeteksi lokasi.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Membuka Halaman Layar Penuh Menggunakan Package photo_view
  void _openPhotoViewer(
    BuildContext context,
    File imageFile,
    Uint8List? annotatedBytes,
  ) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Detail Foto Kerusakan',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: PhotoView(
          imageProvider: annotatedBytes != null
              ? MemoryImage(annotatedBytes)
              : FileImage(imageFile) as ImageProvider,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3.5,
          heroAttributes: const PhotoViewHeroAttributes(
            tag: 'report_photo_hero',
          ),
          enableRotation: true,
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ),
      transition: Transition.fadeIn,
    );
  }
}
