import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_colors.dart';

class SaferuasLoading {
  SaferuasLoading._();

  static void show({String message = 'Menyiapkan perjalanan aman...'}) {
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

class _LoadingOverlay extends StatefulWidget {
  final String message;

  const _LoadingOverlay({required this.message});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController pulseController;
  late AnimationController rotateController;

  late Animation<double> scaleAnimation;
  late Animation<double> glowAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi pulse logo
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    scaleAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    glowAnimation = Tween<double>(begin: 0.12, end: 0.30).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    // Animasi lingkaran berputar
    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    pulseController.dispose();
    rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: const Color(0xFF102A43).withValues(alpha: 0.42),
              ),
            ),
          ),

          // Efek cahaya di belakang logo
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow effect
                      AnimatedBuilder(
                        animation: glowAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 115,
                            height: 115,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: glowAnimation.value,
                                  ),
                                  blurRadius: 45,
                                  spreadRadius: 12,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Lingkaran luar
                      RotationTransition(
                        turns: rotateController,
                        child: SizedBox(
                          width: 145,
                          height: 145,
                          child: CustomPaint(
                            painter: _LoadingRingPainter(
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ),

                      // Lingkaran dalam
                      SizedBox(
                        width: 119,
                        height: 119,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),

                      // Logo pulse
                      AnimatedBuilder(
                        animation: scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: scaleAnimation.value,
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 88,
                          height: 88,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // Nama aplikasi
                const Text(
                  'Saferuas.',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 9),

                // Pesan loading
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    widget.message,
                    key: ValueKey(widget.message),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom lingkaran loading dekoratif
class _LoadingRingPainter extends CustomPainter {
  final Color color;

  const _LoadingRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(2), -0.8, 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant _LoadingRingPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}