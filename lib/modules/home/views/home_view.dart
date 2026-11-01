import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:saferuas/utils/app_colors.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: Colors.white,
        child: SingleChildScrollView(
          // 120 = ruang untuk floating navbar di MainView
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildQuickFeatures(),
              const SizedBox(height: 24),
              _buildRecentReports(),
              const SizedBox(height: 24),
              _buildConditions(),
              const SizedBox(height: 24),
              _buildImpact(),
            ],
          ),
        ),
      ),
    );
  }
  // ===== Helper =====
  TextStyle _jakarta(
    double size,
    FontWeight weight,
    Color color, {
    double? height,
    double? spacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );
  }
  // Pengganti font Consolas dari Figma
  TextStyle _mono(double size, Color color) {
    return GoogleFonts.jetBrainsMono(fontSize: size, color: color, height: 1.5);
  }
  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
  Widget _sectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: _jakarta(17, FontWeight.w700, AppColors.slate900, spacing: -0.43),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
  Widget _pill({
    required Widget child,
    required Color color,
    Color? border,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    double radius = 999,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border != null ? Border.all(color: border) : null,
      ),
      child: child,
    );
  }
    Widget _buildHeader(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background gradient biru dengan lengkung bawah
        Container(
          height: topInset + 150,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            gradient: AppColors.homeHeaderGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(38)),
            boxShadow: [
              BoxShadow(color: Color(0x2D1F5BFF), blurRadius: 28, offset: Offset(0, 10)),
            ],
          ),
          child: Stack(
            children: [
              Positioned(right: -64, top: -64, child: _circle(224, Colors.white.withValues(alpha: 0.15))),
              Positioned(left: -40, top: topInset + 52, child: _circle(192, const Color(0x3367E8F9))),
            ],
          ),
        ),
        // Konten: top bar + kartu cuaca (kartu menumpuk di atas lengkungan)
        Padding(
          padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 0),
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 16),
              _buildWeatherCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    final white85 = Colors.white.withValues(alpha: 0.85);

    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: white85),
                  const SizedBox(width: 4),
                  Text('Lokasi saat ini', style: _jakarta(11, FontWeight.w500, white85, height: 1.5)),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: Obx(
                      () => Text(
                        controller.location.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _jakarta(14, FontWeight.w700, Colors.white, spacing: -0.35),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
        _buildNotificationButton(),
      ],
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.3),
              boxShadow: const [BoxShadow(color: Color(0x99FFFFFF), spreadRadius: 2)],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/avatar.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Colors.white,
                  child: Center(child: Icon(Icons.person, color: AppColors.homeBlue)),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF34D399),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
          Positioned(
            top: 9,
            right: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.yellowAccent,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.homeBlue, spreadRadius: 2)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    final white90 = Colors.white.withValues(alpha: 0.9);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.homeWeatherGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x75000000), blurRadius: 11.1, offset: Offset(0, 4), spreadRadius: -2),
          BoxShadow(color: Color(0x19000000), blurRadius: 25, offset: Offset(0, 20), spreadRadius: -5),
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -40, top: -23, child: _circle(144, Colors.white.withValues(alpha: 0.15))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: controller.temperature.value,
                                    style: _jakarta(24, FontWeight.w800, Colors.white, spacing: -0.8),
                                  ),
                                  const TextSpan(text: '  '),
                                  TextSpan(
                                    text: controller.weather.value,
                                    style: _jakarta(14, FontWeight.w700, AppColors.yellowAccent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Obx(
                            () => Text(
                              controller.weatherDesc.value,
                              style: GoogleFonts.inter(fontSize: 10, color: white90, height: 1.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => Row(
                              children: [
                                _weatherInfo(Icons.water_drop_outlined, const Color(0xFF67E8F9), controller.humidity.value),
                                const SizedBox(width: 12),
                                _weatherInfo(Icons.air_rounded, AppColors.yellowAccent, controller.wind.value),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildConditionBadge(),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 13, color: white90),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Penerangan Jalan (PJU) Optimal',
                        style: _jakarta(10, FontWeight.w400, white90),
                      ),
                    ),
                    _pill(
                      color: AppColors.emerald500,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_outlined, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Belum ada laporan',
                            style: _jakarta(10, FontWeight.w700, Colors.white, spacing: 0.25),
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
      ),
    );
  }

  Widget _weatherInfo(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 4),
        Text(text, style: _mono(10, Colors.white.withValues(alpha: 0.85))),
      ],
    );
  }

  Widget _buildConditionBadge() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.nights_stay_outlined, color: AppColors.yellowAccent, size: 34),
          const SizedBox(height: 4),
          Text('KONDISI BAIK', style: _jakarta(9, FontWeight.w700, Colors.white, spacing: -0.22)),
        ],
      ),
    );
  }
    Widget _buildQuickFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Fitur Cepat'),
        const SizedBox(height: 12),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: controller.quickFeatures.length,
            separatorBuilder: (_, _) => const SizedBox(width: 24),
            itemBuilder: (_, i) {
              final feature = controller.quickFeatures[i];
              return GestureDetector(
                onTap: () => controller.onFeatureTap(feature.label),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.slate100),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: feature.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(feature.icon, color: feature.color, size: 22),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feature.label,
                      style: _jakarta(11, FontWeight.w500, AppColors.slate700, height: 1.25),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
     Widget _buildRecentReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Laporan Terkini Anda',
          trailing: Obx(
            () => Text(
              '${controller.pendingValidation.value} Menunggu Validasi',
              style: _jakarta(12, FontWeight.w500, AppColors.slate500),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.recentReports.isEmpty) {
            return _buildEmptyState('Belum ada laporan terkini dari Anda.');
          }
          return SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: controller.recentReports.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) =>
                  _buildReportCard(controller.recentReports[i]),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReportCard(ReportItem report) {
    final fallbackIcon = Icon(report.icon, color: report.iconColor, size: 26);

    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.homeCardTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: report.thumbBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: report.image != null
                ? Image.asset(
                    report.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => fallbackIcon,
                  )
                : fallbackIcon,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _jakarta(
                      12, FontWeight.w700, AppColors.slate900, height: 1.33),
                ),
                const SizedBox(height: 2),
                Text(
                  report.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _jakarta(
                      10, FontWeight.w400, AppColors.slate500, height: 1.5),
                ),
                const SizedBox(height: 4),
                _pill(
                  color: report.statusBg,
                  border: report.statusBorder,
                  child: Text(
                    report.status,
                    style: _jakarta(
                        9, FontWeight.w600, report.statusColor, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
                color: AppColors.slate100, shape: BoxShape.circle),
            child: const Icon(Icons.sync_rounded,
                size: 18, color: AppColors.homeBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Kondisi Saat Ini',
          trailing: GestureDetector(
            onTap: controller.openMap,
            child: Text('Lihat Peta',
                style: _jakarta(12, FontWeight.w600, AppColors.homeBlue)),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.conditions.isEmpty) {
            return _buildEmptyState('Belum ada data kondisi ruas jalan.');
          }
          return SizedBox(
            height: 164,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: controller.conditions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) =>
                  _buildConditionCard(controller.conditions[i]),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildConditionCard(ConditionItem item) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.homeCardTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.homeCardBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _pill(
                color: item.badgeBg,
                radius: 6,
                child: Text(
                  item.badge,
                  style: _jakarta(9, FontWeight.w700, item.badgeColor,
                      height: 1.5, spacing: 0.45),
                ),
              ),
              const Spacer(),
              if (item.trailingIcon != null)
                Icon(item.trailingIcon, size: 14, color: item.trailingIconColor)
              else
                _circle(6, item.trailingIconColor),
              const SizedBox(width: 4),
              Text(item.trailingText,
                  style:
                      _jakarta(10.5, FontWeight.w600, item.trailingTextColor)),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.title,
              style: _jakarta(14, FontWeight.w700, AppColors.slate900,
                  height: 1.43)),
          const SizedBox(height: 2),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                _jakarta(11, FontWeight.w400, AppColors.slate600, height: 1.38),
          ),
          const Spacer(),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.footer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: item.footerMono
                      ? _mono(10, AppColors.slate500)
                      : _jakarta(10, FontWeight.w400, AppColors.slate500),
                ),
              ),
              _buildConditionAction(item),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditionAction(ConditionItem item) {
    final primary = item.primaryAction;
    final foreground = primary ? Colors.white : AppColors.slate800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary ? AppColors.homeBlue : AppColors.slate100,
        borderRadius: BorderRadius.circular(999),
        border: primary ? null : Border.all(color: AppColors.slate200),
        boxShadow: primary
            ? const [
                BoxShadow(
                    color: Color(0x3F1F5BFF),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: -1)
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.actionLabel,
            style: _jakarta(
                11, primary ? FontWeight.w700 : FontWeight.w600, foreground),
          ),
          const SizedBox(width: 4),
          Icon(
            primary
                ? Icons.arrow_forward_rounded
                : Icons.chevron_right_rounded,
            size: 13,
            color: foreground,
          ),
        ],
      ),
    );
  }

  Widget _buildImpact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Dampak Nyata Pengguna'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(
            () => Row(
              children: [
                for (var i = 0; i < controller.impactStats.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _buildStatCard(controller.impactStats[i])),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

    Widget _buildStatCard(ImpactStat stat) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.homeCardBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(stat.value,
              style: _jakarta(20, FontWeight.w800, stat.color, height: 1.4)),
          const SizedBox(height: 2),
          Text(stat.label,
              style: _jakarta(
                  11, FontWeight.w600, AppColors.slate700, height: 1.25)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.slate100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: _jakarta(12, FontWeight.w500, AppColors.slate500),
        ),
      ),
    );
  }
}