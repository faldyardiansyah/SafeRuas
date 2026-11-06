
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../app_colors.dart';

class SaferuasLoading {
  SaferuasLoading._();

  static void show({
    String message = 'Menyiapkan perjalanan aman...',
  }) {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      _LoadingOverlay(message: message),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      useSafeArea: false,
    );
  }

  static void hide() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}

class _LoadingOverlay extends StatelessWidget {
  final String message;

  const _LoadingOverlay({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 9,
                sigmaY: 9,
              ),
              child: Container(
                color: const Color(0xFF102A43).withValues(alpha: 0.48),
              ),
            ),
          ),

          // Loading content
          Center(
            child: Container(
              width: 270,
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 30,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    blurRadius: 35,
                    spreadRadius: 2,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo dengan animasi
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 112,
                          height: 112,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                          ),
                        ),

                        Image.asset(
                          'assets/images/logo.png',
                          width: 82,
                          height: 82,
                          fit: BoxFit.contain,
                        )
                            .animate(
                              onPlay: (controller) => controller.repeat(
                                reverse: true,
                              ),
                            )
                            .scale(
                              begin: const Offset(0.92, 0.92),
                              end: const Offset(1.05, 1.05),
                              duration: 900.ms,
                            )
                            .fadeIn(duration: 400.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 23),

                  Text(
                    'Saferuas.',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Garis loading animasi
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'MOHON TUNGGU SEBENTAR',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(
                  begin: const Offset(0.88, 0.88),
                  end: const Offset(1, 1),
                  duration: 350.ms,
                  curve: Curves.easeOutBack,
                ),
          ),
        ],
      ),
    );
  }
}
