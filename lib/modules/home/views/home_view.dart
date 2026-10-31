import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:saferuas/utils/app_colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void openRoadReport() {
    Get.toNamed(
      '/reportCamera',
      arguments: {
        'reportType': 'road',
        'aiProvider': 'yolo',
        'title': 'Kerusakan Jalan',
      },
    );
  }

  void openFacilityReport() {
    Get.toNamed(
      '/reportCamera',
      arguments: {
        'reportType': 'facility',
        'aiProvider': 'groq',
        'title': 'Fasilitas Umum',
      },
    );
  }

  void openMaps() => Get.toNamed('/maps');

  void openHistory() => Get.toNamed('/riwayat');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 125),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildGreeting(),
              const SizedBox(height: 27),
              _buildReportHeading(),
              const SizedBox(height: 15),
              _buildReportOptions(),
              const SizedBox(height: 28),
              _buildMapCard(),
              const SizedBox(height: 28),
              _buildActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.route_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SAFERUAS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Infrastruktur untuk semua',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.08);
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, selamat datang 👋',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Ruang publik yang baik,\nberawal dari kepedulian.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 25,
            height: 1.3,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Laporkan masalah infrastruktur di sekitarmu dan bantu ciptakan lingkungan yang lebih aman.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            height: 1.7,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.07);
  }

  Widget _buildReportHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buat laporan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih jenis masalah yang ingin kamu laporkan.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildReportOptions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildReportCard(
            title: 'Kerusakan Jalan',
            description: 'Lubang, retak, dan jalan rusak.',
            icon: Icons.add_road_rounded,
            color: AppColors.primaryDark,
            background: const Color(0xFFEAF6FD),
            onTap: openRoadReport,
            index: 0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildReportCard(
            title: 'Fasilitas Umum',
            description: 'Lampu jalan, drainase, trotoar, dan lainnya.',
            icon: Icons.location_city_outlined,
            color: AppColors.tealDark,
            background: const Color(0xFFEAF5F2),
            onTap: openFacilityReport,
            index: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color background,
    required VoidCallback onTap,
    required int index,
  }) {
    return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 190,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: color, size: 23),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(height: 12, color: AppColors.divider),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Buat laporan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded, color: color, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 200 + index * 100),
          duration: 450.ms,
        )
        .slideY(begin: 0.08, curve: Curves.easeOutCubic);
  }

  Widget _buildMapCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: openMaps,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JELAJAHI SEKITARMU',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'Lihat kondisi infrastruktur di peta.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Buka peta',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primaryDark,
                          size: 15,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: AppColors.primaryDark,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.06);
  }

  Widget _buildActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Aktivitas laporan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: openHistory,
              child: Text(
                'Lihat semua',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6FD),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: AppColors.primaryDark,
                  size: 26,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                'Belum ada aktivitas terbaru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Laporan yang kamu kirim akan ditampilkan di bagian ini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: openHistory,
                child: Text(
                  'Periksa riwayat laporan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.06);
  }
}
