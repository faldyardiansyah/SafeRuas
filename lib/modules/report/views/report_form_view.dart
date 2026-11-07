import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/widgets/mega_mendung.dart';
import '../controllers/report_form_controller.dart';
import '../models/report_category.dart';

class ReportFormView extends StatelessWidget {
  ReportFormView({super.key});

  final ReportFormController controller = Get.put(ReportFormController());

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.slate100,
        bottomNavigationBar: _buildSubmitBar(),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('01', 'Foto'),
                    const SizedBox(height: 12),
                    _buildPhoto(context),
                    const SizedBox(height: 14),
                    Obx(() {
                      if (controller.category.value ==
                          ReportCategory.fasilitasUmum) {
                        return _buildGroqCard();
                      }
                      return _buildYoloCard();
                    }),
                    const SizedBox(height: 32),
                    _sectionTitle('02', 'Detail Laporan'),
                    const SizedBox(height: 4),
                    Text(
                      'Terisi otomatis dari hasil AI, silakan ubah bila perlu.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _fieldLabel('Judul'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: controller.judulController,
                      hint: 'Contoh: Jalan berlubang di depan pasar',
                      maxLength: 150,
                      maxLines: 1,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    _fieldLabel('Deskripsi'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: controller.deskripsiController,
                      hint: 'Jelaskan kondisi yang Anda temukan',
                      maxLength: 1000,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 32),
                    _sectionTitle('03', 'Lokasi'),
                    const SizedBox(height: 12),
                    _buildLocationCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        width: double.infinity,
        color: AppColors.homeBlue,
        child: Stack(
          children: [
            Positioned(right: -36, top: -18, child: MegaMendung(width: 230)),
            Positioned(
              left: -52,
              bottom: -34,
              child: MegaMendung(
                width: 160,
                flip: true,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, top + 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buat Laporan',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bantu Indramayu lebih aman untuk semua',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _segment(
                            'Jalan Rusak',
                            Icons.add_road_rounded,
                            ReportCategory.jalanRusak,
                          ),
                          _segment(
                            'Fasilitas Umum',
                            Icons.lightbulb_outline_rounded,
                            ReportCategory.fasilitasUmum,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment(String label, IconData icon, ReportCategory value) {
    final selected = controller.category.value == value;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.setCategory(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? AppColors.homeBlue : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.homeBlue : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String number, String title) {
    return Row(
      children: [
        Text(
          number,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.homeBlue,
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 14, height: 2, color: AppColors.homeChipTint),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoto(BuildContext context) {
    return Obx(() {
      final File? image = controller.selectedImage.value;
      final annotated = controller.annotatedImageBytes.value;
      final isProcessing = controller.isProcessing;
      final isRoad = controller.category.value == ReportCategory.jalanRusak;

      if (image == null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -24,
                  bottom: -16,
                  child: MegaMendung(
                    width: 200,
                    color: AppColors.homeBlue.withValues(alpha: 0.14),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_camera_outlined,
                        size: 36,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Foto belum tersedia',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: () => _openPhotoViewer(context, image, annotated),
        child: Hero(
          tag: 'report_photo_hero',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: 240,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  annotated != null
                      ? Image.memory(annotated, fit: BoxFit.cover)
                      : Image.file(image, fit: BoxFit.cover),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.slate900.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.zoom_out_map_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ketuk untuk zoom',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: controller.removeImage,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.dangerRed,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (isProcessing)
                    Container(
                      color: AppColors.slate900.withValues(alpha: 0.62),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            isRoad
                                ? 'Mendeteksi kerusakan jalan...'
                                : 'Menganalisis fasilitas...',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _aiCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slate200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: AppColors.homeBlue),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 14,
                            color: AppColors.homeBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'HASIL ANALISIS AI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.homeBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      child,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYoloCard() {
    final isDetecting = controller.isDetecting.value;
    final detections = controller.detections;
    final error = controller.detectionError.value;

    if (isDetecting) return const SizedBox.shrink();

    if (error.isNotEmpty) {
      return _errorCard(error, controller.runDetection);
    }

    if (detections.isNotEmpty) {
      return _aiCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terdeteksi ${detections.length} titik kerusakan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: detections.map((d) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.amber500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        d.displayName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        d.confidencePercent,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.slate500,
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

    if (controller.selectedImage.value != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.emerald50,
          borderRadius: BorderRadius.circular(16),
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
                'Kondisi jalan tampak aman, tidak terdeteksi kerusakan.',
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
  }

  Widget _buildGroqCard() {
    if (controller.isAnalyzingGroq.value) return const SizedBox.shrink();

    final error = controller.groqError.value;
    final result = controller.groqResult.value;

    if (error.isNotEmpty) {
      return _errorCard(error, controller.runGroqAnalysis);
    }

    if (result == null) return const SizedBox.shrink();

    if (!result.isPublicFacility) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Text(
          'Foto tidak menampilkan fasilitas umum. Coba ambil ulang atau ganti kategori.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            height: 1.5,
            color: AppColors.slate700,
          ),
        ),
      );
    }

    return _aiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.facilityType,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip('Kondisi', result.condition),
              _infoChip('Tingkat', result.severity),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.55,
              color: AppColors.slate800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Saran: ${result.suggestion}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              height: 1.5,
              color: AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.slate500,
              ),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.dangerRed.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.dangerRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.dangerRed,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
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

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.slate800,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    required int maxLines,
    TextInputAction? textInputAction,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextField(
      controller: controller,
      maxLength: maxLength,
      minLines: maxLines == 1 ? 1 : 3,
      maxLines: maxLines,
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.sentences,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        height: 1.4,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: AppColors.textMuted,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: border(AppColors.slate200),
        focusedBorder: border(AppColors.homeBlue, 1.5),
        border: border(AppColors.slate200),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Obx(() {
      final position = controller.currentPosition.value;
      final isLoading = controller.isLoadingLocation.value;
      final errorMsg = controller.locationError.value;
      final alamat = controller.alamatLokasi.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.homeChipTint.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.homeBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.homeBlue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Mencari lokasi Anda...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : position == null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        errorMsg.isNotEmpty
                            ? errorMsg
                            : 'Gagal mendeteksi lokasi.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.error,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alamat ?? 'Alamat belum tersedia',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: alamat != null
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${position.latitude.toStringAsFixed(6)}, '
                          '${position.longitude.toStringAsFixed(6)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Lokasi didapatkan dari GPS',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            IconButton(
              tooltip: 'Perbarui lokasi',
              onPressed: controller.getCurrentLocation,
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.homeBlue,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSubmitBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.slate200)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Obx(() {
            final busy =
                controller.isProcessing || controller.isSubmitting.value;
            final submitting = controller.isSubmitting.value;

            return SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: busy ? null : controller.submitReport,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.homeBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.slate200,
                  disabledForegroundColor: AppColors.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.isProcessing
                                ? 'Menunggu analisis AI...'
                                : 'Kirim Laporan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (!controller.isProcessing) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ],
                      ),
              ),
            );
          }),
        ),
      ),
    );
  }

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
            'Detail Foto',
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
