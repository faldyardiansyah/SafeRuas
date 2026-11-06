import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;
import 'package:saferuas/utils/app_colors.dart';
import 'package:saferuas/utils/widgets/mega_mendung.dart';
import '../controllers/riwayat_controller.dart';

class RiwayatView extends GetView<RiwayatController> {
  const RiwayatView({super.key});

  TextStyle get jakarta => GoogleFonts.plusJakartaSans();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.slate100,
        body: Obx(() {
          final isLoading = controller.isLoading.value;
          return Skeletonizer(
            enabled: isLoading,
            effect: const ShimmerEffect(
              baseColor: AppColors.slate200,
              highlightColor: AppColors.slate100,
              duration: Duration(milliseconds: 1400),
            ),
            child: RefreshIndicator(
              onRefresh: controller.refreshReports,
              color: AppColors.homeBlue,
              backgroundColor: Colors.white,
              displacement: 40,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(bottom: 125),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildSummaryCard(),
                          ),
                          const SizedBox(height: 22),
                          _buildCategoryFilter(),
                          const SizedBox(height: 12),
                          _buildStatusFilter(),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildReportList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ===== Header =====
  Widget _buildHeader(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Skeleton.keep(
          child: Container(
            height: topInset + 150,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.homeBlue, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(38),
                bottomRight: Radius.circular(38),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: topInset - 34,
                  right: -135,
                  child: MegaMendung(
                    width: 345,
                    color: Colors.white.withValues(alpha: 0.24),
                  ),
                ),
                Positioned(
                  left: -160,
                  bottom: -15,
                  child: MegaMendung(
                    width: 310,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(22, topInset + 18, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Laporan',
                          style: jakarta.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Pantau status laporan jalan & fasilitas',
                          style: jakarta.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  // ===== Ringkasan status =====
  Widget _buildSummaryCard() {
    return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: _cardDecoration(),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Total laporan',
                      style: jakarta.copyWith(
                        color: AppColors.slate500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${controller.totalReports}',
                      style: jakarta.copyWith(
                        color: AppColors.slate900,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _summaryItem(ReportStatus.menunggu),
                    const SizedBox(width: 8),
                    _summaryItem(ReportStatus.diproses),
                    const SizedBox(width: 8),
                    _summaryItem(ReportStatus.diperbaiki),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 100.ms, duration: 500.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          delay: 100.ms,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _summaryItem(ReportStatus status) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: status.tint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              '${controller.countByStatus(status)}',
              style: jakarta.copyWith(
                color: status.color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              status == ReportStatus.menunggu ? 'Menunggu' : status.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: jakarta.copyWith(
                color: AppColors.slate600,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Filter =====
  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        final selected = controller.selectedCategory.value;
        return Row(
          children: ReportCategory.values.map((category) {
            final isActive = selected == category;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: category == ReportCategory.jalan ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => controller.selectCategory(category),
                  child: AnimatedContainer(
                    duration: 250.ms,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.homeBlue : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive
                            ? AppColors.homeBlue
                            : AppColors.homeCardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category.icon,
                          size: 17,
                          color: isActive ? Colors.white : category.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category.label,
                          style: jakarta.copyWith(
                            color: isActive ? Colors.white : AppColors.slate700,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildStatusFilter() {
    return SizedBox(
      height: 36,
      child: Obx(() {
        final selected = controller.selectedStatus.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.statusFilters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final status = controller.statusFilters[index];
            final isActive = selected == status;
            return GestureDetector(
              onTap: () => controller.selectStatus(status),
              child: AnimatedContainer(
                duration: 250.ms,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.slate900 : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isActive
                        ? AppColors.slate900
                        : AppColors.homeCardBorder,
                  ),
                ),
                child: Text(
                  controller.statusFilterLabel(status),
                  style: jakarta.copyWith(
                    color: isActive ? Colors.white : AppColors.slate600,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ===== Daftar laporan =====
  Widget _buildReportList() {
    return Obx(() {
      final items = controller.filteredReports;
      if (items.isEmpty) return _buildEmptyState();

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _buildReportCard(items[index])
            .animate()
            .fadeIn(delay: (60 * index).ms, duration: 400.ms)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
      );
    });
  }

  Widget _buildReportCard(ReportHistory report) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showReportDetail(report),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: _cardDecoration(radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconBox(report.category),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: jakarta.copyWith(
                            color: AppColors.slate900,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${report.category.label} • ${report.damageType}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: jakarta.copyWith(
                            color: AppColors.slate500,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusPill(report.status),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: AppColors.slate100),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppColors.slate400,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      controller.formatDate(report.createdAt),
                      style: jakarta.copyWith(
                        color: AppColors.slate500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.groups_rounded,
                    size: 15,
                    color: AppColors.slate400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${report.confirmations} konfirmasi',
                    style: jakarta.copyWith(
                      color: AppColors.slate500,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPill(ReportStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: status.tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: jakarta.copyWith(
              color: status.color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: _cardDecoration(radius: 20),
      child: Column(
        children: [
          Lottie.asset(
            'assets/lotties/Empty.json',
            width: 90,
            height: 90,
            fit: BoxFit.contain,
            repeat: true,
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada laporan',
            style: jakarta.copyWith(
              color: AppColors.slate900,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Laporan jalan rusak dan fasilitas yang kamu ajukan akan muncul di sini beserta statusnya.',
            textAlign: TextAlign.center,
            style: jakarta.copyWith(
              color: AppColors.slate500,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ===== Detail laporan =====
  void _showReportDetail(ReportHistory report) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.8),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _iconBox(report.category),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.location,
                          style: jakarta.copyWith(
                            color: AppColors.slate900,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID ${report.id}',
                          style: GoogleFonts.jetBrainsMono(
                            color: AppColors.slate400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusPill(report.status),
                ],
              ),
              const SizedBox(height: 16),
              _detailRow('Kategori', report.category.label),
              _detailRow('Jenis', report.damageType),
              _detailRow('Diajukan', controller.formatDate(report.createdAt)),
              _detailRow('Konfirmasi warga', '${report.confirmations} orang'),
              if (report.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  report.description,
                  style: jakarta.copyWith(
                    color: AppColors.slate600,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Perjalanan status',
                style: jakarta.copyWith(
                  color: AppColors.slate900,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (report.timeline.isEmpty)
                Text(
                  'Belum ada pembaruan status.',
                  style: jakarta.copyWith(
                    color: AppColors.slate500,
                    fontSize: 12,
                  ),
                )
              else
                ...List.generate(report.timeline.length, (index) {
                  return _timelineItem(
                    report.timeline[index],
                    isLast: index == report.timeline.length - 1,
                  );
                }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: jakarta.copyWith(
                color: AppColors.slate500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: jakarta.copyWith(
                color: AppColors.slate800,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(ReportTimeline item, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: item.status.tint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.status.icon,
                  size: 13,
                  color: item.status.color,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppColors.slate200)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.status.label,
                    style: jakarta.copyWith(
                      color: AppColors.slate900,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.formatDate(item.time),
                    style: jakarta.copyWith(
                      color: AppColors.slate400,
                      fontSize: 10.5,
                    ),
                  ),
                  if (item.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.note,
                      style: jakarta.copyWith(
                        color: AppColors.slate600,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Helper =====
  Widget _iconBox(ReportCategory category) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: category.tint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(category.icon, color: category.color, size: 22),
    );
  }

  BoxDecoration _cardDecoration({double radius = 24}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.homeCardBorder),
      boxShadow: [
        BoxShadow(
          color: AppColors.slate900.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
