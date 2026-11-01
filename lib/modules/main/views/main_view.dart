import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:saferuas/utils/app_colors.dart';
import 'package:saferuas/modules/home/views/home_view.dart';
import 'package:saferuas/modules/maps/views/maps_view.dart';

import '../controllers/main_controller.dart';


class MainView extends GetView<MainController> {
  const MainView({super.key});

  final List<Widget> pages = const [
    HomeView(),
    MapsView(),
    _PlaceholderPage(
      title: 'Riwayat',
      description: 'Lihat riwayat laporan kerusakan jalan.',
      icon: Icons.history_rounded,
    ),
    _PlaceholderPage(
      title: 'Profile',
      description: 'Kelola informasi akunmu.',
      icon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.surface,
        extendBody: true,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            IndexedStack(index: controller.currentIndex.value, children: pages),
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 14,
              child: _buildFloatingBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBar() {
    return SizedBox(
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _NavBarPainter(shadowColor: Colors.black),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  inactiveIcon: Icons.home_outlined,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.map_rounded,
                  inactiveIcon: Icons.map_outlined,
                  label: 'Maps',
                  index: 1,
                ),
                const SizedBox(width: 92),
                _buildNavItem(
                  icon: Icons.history_rounded,
                  inactiveIcon: Icons.history_rounded,
                  label: 'Riwayat',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  inactiveIcon: Icons.person_outline_rounded,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
          Positioned(
            top: -29,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: controller.openReport,
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.40),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData inactiveIcon,
    required String label,
    required int index,
  }) {
    final isActive = controller.currentIndex.value == index;

    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTab(index),
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isActive ? icon : inactiveIcon,
                  key: ValueKey(isActive),
                  size: 25,
                  color: isActive ? AppColors.primary : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive ? AppColors.primary : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  final Color shadowColor;

  const _NavBarPainter({required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    const r = 30.0;
    const depth = 40.0;
    const half = 46.0;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(cx - half - 22, 0)
      ..cubicTo(cx - half + 8, 0, cx - half + 6, depth, cx, depth)
      ..cubicTo(cx + half - 6, depth, cx + half - 8, 0, cx + half + 22, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..close();

    canvas.drawShadow(path, shadowColor.withValues(alpha: 0.25), 14, true);

    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _NavBarPainter old) => false;
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _PlaceholderPage({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 55, color: AppColors.primary),
            const SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
