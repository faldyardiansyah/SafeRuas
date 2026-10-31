import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import 'package:saferuas/utils/app_colors.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  static const Color primary = AppColors.primary;
  static const Color heading = AppColors.textPrimary;
  static const Color muted = AppColors.textMuted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: true,
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Saferuas
              _buildHeader(),
              // Form login
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul halaman
                      Text(
                            'Selamat Datang Kembali',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: heading,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 7),

                      Text(
                        'Masuk untuk melanjutkan perjalanan aman bersama Saferuas.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          height: 1.5,
                          color: muted,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Email
                      _buildLabel('Email'),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: controller.emailController,
                        validator: controller.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: _inputTextStyle(),
                        decoration: _inputDecoration(
                          hint: 'Masukkan email anda',
                          icon: Icons.mail_outline_rounded,
                        ),
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 17),

                      // Kata sandi
                      _buildLabel('Kata sandi'),

                      const SizedBox(height: 8),

                      Obx(
                        () => TextFormField(
                          controller: controller.passwordController,
                          validator: controller.validatePassword,
                          obscureText: controller.isPasswordHidden.value,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => controller.login(),
                          style: _inputTextStyle(),
                          decoration:
                              _inputDecoration(
                                hint: 'Masukkan kata sandi',
                                icon: Icons.lock_outline_rounded,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed:
                                      controller.togglePasswordVisibility,
                                  icon: Icon(
                                    controller.isPasswordHidden.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: muted,
                                    size: 19,
                                  ),
                                ),
                              ),
                        ),
                      ).animate().fadeIn(delay: 150.ms),

                      const SizedBox(height: 13),

                      // Ingat akun dan lupa kata sandi
                      Row(
                        children: [
                          Obx(
                            () => SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: controller.rememberMe.value,
                                onChanged: controller.toggleRememberMe,
                                activeColor: primary,
                                side: const BorderSide(
                                  color: AppColors.divider,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Ingat saya',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: controller.forgotPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Lupa kata sandi?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Tombol masuk
                      SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ElevatedButton(
                                onPressed: controller.login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: AppColors.textWhite,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Masuk',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 23),

                      // Pilihan masuk lainnya
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: AppColors.divider),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Atau masuk dengan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: muted,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: AppColors.divider),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Masuk menggunakan Google
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: controller.loginWithGoogle,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            side: const BorderSide(color: AppColors.divider),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/google.png', width: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Google',
                                style: GoogleFonts.plusJakartaSans(
                                  color: heading,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Link pendaftaran
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun? ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: muted,
                              ),
                            ),
                            GestureDetector(
                              onTap: controller.goToRegister,
                              child: Text(
                                'Daftar sekarang',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Hiasan lingkaran kecil
          Positioned(
            right: -25,
            top: -35,
            child: _circle(85, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            left: -30,
            bottom: -40,
            child: _circle(75, Colors.white.withValues(alpha: 0.08)),
          ),

          // Nama dan slogan Saferuas
          Positioned(
            top: 25,
            left: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                      'Saferuas.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textWhite,
                        letterSpacing: -1,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 450.ms)
                    .slideX(begin: -0.1, end: 0),

                const SizedBox(height: 7),

                Text(
                  'Perjalanan nyaman,\nlebih aman bersama kami.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textWhite.withValues(alpha: 0.9),
                  ),
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
          ),

          // Animasi pengendara motor di kanan bawah
          Positioned(
            right: 5,
            bottom: 0,
            child: SizedBox(
              width: 185,
              height: 165,
              child: Lottie.asset(
                'assets/lotties/ride.json',
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
                repeat: true,
              ),
            ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.15, end: 0),
          ),
        ],
      ),
    );
  }

  // Lingkaran hiasan
  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // Label input
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: heading,
      ),
    );
  }

  // Gaya tulisan input
  TextStyle _inputTextStyle() {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: heading,
    );
  }

  // Tampilan kolom input
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        color: AppColors.textMuted,
      ),
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 19),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
    );
  }
}
