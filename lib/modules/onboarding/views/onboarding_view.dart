import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/app_colors.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.onboardingChipBorder),
                    ),
                    child: const Icon(
                      Icons.alt_route_rounded,
                      color: AppColors.onboardingPrimary,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SafeRuas',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.onboardingHeading,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: controller.skipOnboarding,
                    child: Text(
                      'Lewati',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.onboardingMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Konten setiap halaman
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.pages.length,
                onPageChanged: (index) {
                  controller.currentPage.value = index;
                },
                itemBuilder: (context, index) {
                  final page = controller.pages[index];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 1. Ilustrasi Lottie
                                Container(
                                  height: constraints.maxHeight * 0.40,
                                  constraints: const BoxConstraints(
                                    minHeight: 180,
                                    maxHeight: 320,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: AppColors.mapBorder,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(27),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: -35,
                                          top: -35,
                                          child: Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: AppColors.backgroundLight
                                                  .withValues(alpha: 0.65),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: -40,
                                          bottom: -50,
                                          child: Container(
                                            width: 130,
                                            height: 130,
                                            decoration: BoxDecoration(
                                              color: AppColors.mapBackground,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Lottie.asset(
                                              page['animation']!,
                                              key: ValueKey(page['animation']),
                                              fit: BoxFit.contain,
                                              repeat: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 26),

                                // 2. Label kategori
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundLight,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      page['eyebrow']!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        letterSpacing: 1.0,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.onboardingPrimary,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // 3. Judul utama
                                Text(
                                  page['title']!,
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 29,
                                    height: 1.2,
                                    letterSpacing: -0.8,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onboardingHeading,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // 4. Deskripsi
                                Text(
                                  page['description']!,
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    height: 1.7,
                                    color: AppColors.onboardingMuted,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // 5. Fitur halaman
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _FeatureChip(label: page['label1']!),
                                    _FeatureChip(label: page['label2']!),
                                    if (page['label3'] != null)
                                      _FeatureChip(label: page['label3']!),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Indikator halaman
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(controller.pages.length, (index) {
                    final active = controller.currentPage.value == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 25 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.info
                            : AppColors.onboardingIndicatorInactive,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Tombol utama
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: Obx(() {
                  final isLastPage =
                      controller.currentPage.value ==
                      controller.pages.length - 1;

                  return ElevatedButton(
                    onPressed: controller.nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: AppColors.textWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastPage ? 'Mulai Sekarang' : 'Lanjutkan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded, size: 19),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;

  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.onboardingChipBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 15,
            color: AppColors.teal,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onboardingSecondaryText,
            ),
          ),
        ],
      ),
    );
  }
}