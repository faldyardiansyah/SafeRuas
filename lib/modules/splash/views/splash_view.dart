import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.onboardingGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Cahaya background dengan animasi
              Positioned(
                top: 100,
                left: -70,
                child: _glowCircle(180, 0.10)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: 0.55, end: 1, duration: 2200.ms)
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1.08, 1.08),
                      duration: 2200.ms,
                    ),
              ),

              Positioned(
                right: -90,
                bottom: 150,
                child: _glowCircle(220, 0.12)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: 0.45, end: 1, duration: 2800.ms)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.12, 1.12),
                      duration: 2800.ms,
                    ),
              ),

              // Identitas aplikasi
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo muncul dengan efek membesar
                      Container(
                            width: 112,
                            height: 112,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withValues(
                                    alpha: 0.20,
                                  ),
                                  blurRadius: 35,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.jpeg',
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
                          .fadeIn(duration: 700.ms)
                          .scale(
                            begin: const Offset(0.55, 0.55),
                            end: const Offset(1, 1),
                            duration: 900.ms,
                            curve: Curves.easeOutBack,
                          )
                          .shimmer(
                            delay: 900.ms,
                            duration: 1400.ms,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),

                      const SizedBox(height: 25),

                      // Judul muncul setelah logo
                      const Text(
                            'SafeRuas',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              color: AppColors.textPrimary,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 700.ms)
                          .slideY(
                            begin: 0.35,
                            end: 0,
                            delay: 300.ms,
                            duration: 700.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 9),

                      // Tagline tampil secara bertahap
                      const Text(
                            'Navigasi cerdas untuk perjalanan\n'
                            'yang lebih aman dan nyaman.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 550.ms, duration: 800.ms)
                          .slideY(
                            begin: 0.25,
                            end: 0,
                            delay: 550.ms,
                            duration: 800.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 20),

                      // Aksen identitas dengan efek melebar
                      Container(
                            width: 34,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.teal,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 500.ms)
                          .scaleX(
                            begin: 0,
                            end: 1,
                            delay: 800.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                ),
              ),

              // Loading di bagian bawah layar
              Positioned(
                left: 22,
                right: 22,
                bottom: 24,
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                                Icons.sync_rounded,
                                size: 16,
                                color: AppColors.tealDark,
                              )
                              .animate(onPlay: (c) => c.repeat())
                              .rotate(duration: 1200.ms, curve: Curves.linear),

                          const SizedBox(width: 8),

                          Expanded(
                            child: AnimatedSwitcher(
                              duration: 300.ms,
                              child:
                                  Text(
                                        controller.loadingMessage.value,
                                        key: ValueKey(
                                          controller.loadingMessage.value,
                                        ),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      )
                                      .animate(
                                        key: ValueKey(
                                          controller.loadingMessage.value,
                                        ),
                                      )
                                      .fadeIn(duration: 300.ms)
                                      .slideX(
                                        begin: 0.08,
                                        end: 0,
                                        duration: 300.ms,
                                      ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            '${controller.currentStep.value + 1}'
                            '/${controller.loadingSteps.length}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.tealDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Progress bar animasi
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
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 5,
                              backgroundColor: AppColors.progressTrack,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.progressValue,
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 900.ms, duration: 600.ms),

                      const SizedBox(height: 10),

                      const Text(
                        'SafeRuas • Smart Road Intelligence',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 0.2,
                          color: AppColors.textSecondary,
                        ),
                      ).animate().fadeIn(delay: 1100.ms, duration: 700.ms),
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

  Widget _glowCircle(double size, double opacity) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
