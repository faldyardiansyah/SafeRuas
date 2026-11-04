import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/widgets/mega_mendung.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2296F3),
              Color(0xFF4AC4FA),
              Color(0xFFBCEBFF),
              Color(0xFFE8F7FF),
            ],
            stops: [0.0, 0.32, 0.68, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              
              //AMBIENT GLOW ORBS (KEDALAMAN LATAR MODERN)
              
              Positioned(
                top: 40,
                left: -60,
                child: _glowCircle(220, 0.16)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: 0.45, end: 0.95, duration: 2400.ms)
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1.10, 1.10),
                      duration: 2800.ms,
                      curve: Curves.easeInOutSine,
                    ),
              ),

              Positioned(
                right: -70,
                top: 180,
                child: _glowCircle(260, 0.14)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: 0.40, end: 0.85, duration: 2800.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.12, 1.12),
                      duration: 3400.ms,
                      curve: Curves.easeInOutSine,
                    ),
              ),

              Positioned(
                left: -80,
                bottom: 120,
                child: _glowCircle(240, 0.18)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: 0.50, end: 1.0, duration: 2600.ms)
                    .scale(
                      begin: const Offset(0.90, 0.90),
                      end: const Offset(1.08, 1.08),
                      duration: 3200.ms,
                      curve: Curves.easeInOutSine,
                    ),
              ),

              // BATIK MEGA MENDUNG DI 4 SUDUT (BERANIMASI)
              // Sudut Atas Kiri
              Positioned(
                left: -50,
                top: -45,
                child: MegaMendung(
                  width: 280,
                  color: Colors.white.withValues(alpha: 0.28),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 1200.ms)
                    .scale(
                      begin: const Offset(0.96, 0.96),
                      end: const Offset(1.06, 1.06),
                      duration: 3200.ms,
                      curve: Curves.easeInOutSine,
                    )
                    .move(
                      begin: const Offset(-4, -4),
                      end: const Offset(4, 4),
                      duration: 3800.ms,
                      curve: Curves.easeInOutSine,
                    ),
              ),

              // Sudut Atas Kanan
              Positioned(
                right: -50,
                top: -45,
                child: MegaMendung(
                  width: 280,
                  flip: true,
                  color: Colors.white.withValues(alpha: 0.28),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 1280.ms)
                    .scale(
                      begin: const Offset(0.96, 0.96),
                      end: const Offset(1.06, 1.06),
                      duration: 3400.ms,
                      curve: Curves.easeInOutSine,
                    )
                    .move(
                      begin: const Offset(4, -4),
                      end: const Offset(-4, 4),
                      duration: 4000.ms,
                      curve: Curves.easeInOutSine,
                    ),
              ),

              // Sudut Bawah Kiri (Dibalik Vertikal dengan Transform.flip)
              Positioned(
                left: -60,
                bottom: -45,
                child: Transform.flip(
                  flipY: true,
                  child: MegaMendung(
                    width: 280,
                    color: Colors.white.withValues(alpha: 0.24),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 1400.ms)
                    .scale(
                      begin: const Offset(0.98, 0.98),
                      end: const Offset(1.08, 1.08),
                      duration: 3600.ms,
                      curve: Curves.easeInOutSine,
                    )
                    .move(
                      begin: const Offset(-4, 4),
                      end: const Offset(4, -4),
                      duration: 4200.ms,
                      curve: Curves.easeInOutSine,
                    ),
              ),

              // Sudut Bawah Kanan (Dibalik Horizontal & Vertikal)
              Positioned(
                right: -60,
                bottom: -45,
                child: Transform.flip(
                  flipY: true,
                  child: MegaMendung(
                    width: 280,
                    flip: true,
                    color: Colors.white.withValues(alpha: 0.24),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 1500.ms)
                    .scale(
                      begin: const Offset(0.98, 0.98),
                      end: const Offset(1.08, 1.08),
                      duration: 3800.ms,
                      curve: Curves.easeInOutSine,
                    )
                    .move(
                      begin: const Offset(4, 4),
                      end: const Offset(-4, -4),
                      duration: 4400.ms,
                      curve: Curves.easeInOutSine,
                    ),
              ),
         
              // KONTEN TENGAH (LOGO, CHIP, TITLE, SUBTITLE)    
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo dengan Gelombang Radar Sensor & Shimmer
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Gelombang Radar Luar
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                            ),
                          )
                              .animate(onPlay: (c) => c.repeat())
                              .scale(
                                begin: const Offset(0.85, 0.85),
                                end: const Offset(1.35, 1.35),
                                duration: 2600.ms,
                                curve: Curves.easeOut,
                              )
                              .fadeOut(
                                duration: 2600.ms,
                                curve: Curves.easeOut,
                              ),

                          // Gelombang Radar Dalam
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                                width: 1.5,
                              ),
                            ),
                          )
                              .animate(onPlay: (c) => c.repeat())
                              .scale(
                                begin: const Offset(0.90, 0.90),
                                end: const Offset(1.25, 1.25),
                                delay: 600.ms,
                                duration: 2600.ms,
                                curve: Curves.easeOut,
                              )
                              .fadeOut(
                                delay: 600.ms,
                                duration: 2600.ms,
                                curve: Curves.easeOut,
                              ),

                          // Card Logo Glassmorphic
                          Container(
                            width: 116,
                            height: 116,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x33078BCE),
                                  blurRadius: 36,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 14),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  blurRadius: 10,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.route_rounded,
                                  size: 52,
                                  color: AppColors.teal,
                                );
                              },
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 800.ms)
                              .scale(
                                begin: const Offset(0.65, 0.65),
                                end: const Offset(1, 1),
                                duration: 900.ms,
                                curve: Curves.easeOutBack,
                              )
                              .shimmer(
                                delay: 1000.ms,
                                duration: 1600.ms,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      // Pill Tag "SMART ROAD INTELLIGENCE"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x14078BCE),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.emerald500,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.emerald500,
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1.3, 1.3),
                                  duration: 900.ms,
                                ),
                            const SizedBox(width: 8),
                            Text(
                              'SMART ROAD INTELLIGENCE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: const Color(0xFF16766F),
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            delay: 200.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 12),

                      // Title SafeRuas
                      Text(
                        'SafeRuas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.2,
                          color: AppColors.textPrimary,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 350.ms, duration: 700.ms)
                          .slideY(
                            begin: 0.30,
                            end: 0,
                            delay: 350.ms,
                            duration: 700.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 8),

                      // Deskripsi Singkat
                      Text(
                        'Navigasi cerdas untuk perjalanan\nyang lebih aman dan nyaman.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 800.ms)
                          .slideY(
                            begin: 0.25,
                            end: 0,
                            delay: 500.ms,
                            duration: 800.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                ),
              ),

              // KARTU STATUS LOADING MODERN (BOTTOM)
              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: Obx(
                  () => Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.95),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x24078BCE),
                          blurRadius: 30,
                          spreadRadius: 1,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE4F5FD),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Center(
                                child: const Icon(
                                  Icons.sync_rounded,
                                  size: 19,
                                  color: AppColors.primaryDark,
                                )
                                    .animate(onPlay: (c) => c.repeat())
                                    .rotate(
                                      duration: 1280.ms,
                                      curve: Curves.linear,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedSwitcher(
                                    duration: 350.ms,
                                    transitionBuilder: (child, anim) =>
                                        FadeTransition(
                                          opacity: anim,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.25),
                                              end: Offset.zero,
                                            ).animate(anim),
                                            child: child,
                                          ),
                                        ),
                                    child: Text(
                                      controller.loadingMessage.value,
                                      key: ValueKey(
                                        controller.loadingMessage.value,
                                      ),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Memuat data sensor & navigasi...',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F7F5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${controller.currentStep.value + 1}/${controller.loadingSteps.length}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.tealDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: controller.progress.value,
                            ),
                            duration: 600.ms,
                            curve: Curves.easeInOutCubic,
                            builder: (context, value, child) {
                              return Stack(
                                children: [
                                  Container(
                                    height: 7,
                                    width: double.infinity,
                                    color: const Color(0xFFE1F0FA),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: value.clamp(0.0, 1.0),
                                    child: Container(
                                      height: 7,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF29B6F6),
                                            Color(0xFF168F80),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(30),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x66168F80),
                                            blurRadius: 6,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SafeRuas AI • Smart Road System',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${((controller.progress.value) * 100).toInt()}%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.tealDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 700.ms)
                  .slideY(
                    begin: 0.20,
                    end: 0,
                    delay: 600.ms,
                    duration: 700.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glowCircle(double size, double opacity) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withValues(alpha: opacity),
              Colors.white.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}