import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:saferuas/modules/profile/controllers/profile_controller.dart';

import 'package:saferuas/utils/app_colors.dart';


class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  TextStyle get jakarta => GoogleFonts.plusJakartaSans();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.slate100,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 125),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 25),
                      _buildSectionTitle(
                        'INFORMASI AKUN',
                        'Informasi pribadi kamu',
                      ),
                      const SizedBox(height: 12),
                      _buildAccountCard(),
                      const SizedBox(height: 25),
                      _buildSectionTitle(
                        'PENGATURAN',
                        'Kelola akun dan aplikasi',
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsCard(),
                      const SizedBox(height: 25),
                      _buildSectionTitle(
                        'INFORMASI LAINNYA',
                        'Kami siap membantu kamu',
                      ),
                      const SizedBox(height: 12),
                      _buildHelpCard(),
                      const SizedBox(height: 25),
                      _buildLogoutButton(),
                      const SizedBox(height: 25),
                      _buildFooter(),
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
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.homeBlue, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(38),
              bottomRight: Radius.circular(38),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: -65,
                right: -35,
                child: _circle(190, Colors.white.withValues(alpha: 0.08)),
              ),
              Positioned(
                top: 100,
                right: 85,
                child: _circle(75, Colors.white.withValues(alpha: 0.07)),
              ),
              Positioned(
                bottom: -75,
                left: -35,
                child: _circle(160, Colors.white.withValues(alpha: 0.06)),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
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
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'SAFERUAS',
                            style: jakarta.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.17),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'AKUN SAYA',
                              style: jakarta.copyWith(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      Text(
                        'Profil Pengguna',
                        style: jakarta.copyWith(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Kelola informasi dan akun Saferuas kamu.',
                        style: jakarta.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(
          begin: -0.08,
          end: 0,
          duration: 550.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildProfileCard() {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.homeCardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.slate900.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.homeBlue.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/avatar.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: AppColors.homeCardTint,
                            child: Icon(
                              Icons.person_rounded,
                              size: 38,
                              color: AppColors.homeBlue,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.name.value,
                            key: ValueKey(controller.name.value),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: jakarta.copyWith(
                              color: AppColors.slate900,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ).animate().fadeIn(duration: 250.ms),
                        ),
                        const SizedBox(height: 5),
                        Obx(
                          () => Text(
                            controller.email.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: jakarta.copyWith(
                              color: AppColors.slate500,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.homeBlue.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                color: AppColors.homeBlue,
                                size: 12,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'PENGGUNA',
                                style: jakarta.copyWith(
                                  color: AppColors.homeBlue,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: AppColors.homeCardTint,
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(13),
                      onTap: controller.openEditProfile,
                      child: Padding(
                        padding: const EdgeInsets.all(11),
                        child: Icon(
                          Icons.edit_rounded,
                          color: AppColors.homeBlue,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Divider(color: AppColors.slate100, height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.phone_rounded,
                    size: 16,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Obx(
                      () => Text(
                        controller.phone.value,
                        style: jakarta.copyWith(
                          color: AppColors.slate600,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Edit profil',
                    style: jakarta.copyWith(
                      color: AppColors.homeBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 150.ms, duration: 500.ms)
        .slideY(
          begin: 0.12,
          end: 0,
          delay: 150.ms,
          duration: 550.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: jakarta.copyWith(
            color: AppColors.slate500,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: jakarta.copyWith(
            color: AppColors.slate900,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard() {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              Obx(
                () => _buildInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Nama lengkap',
                  value: controller.name.value,
                ),
              ),
              _divider(),
              Obx(
                () => _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Alamat email',
                  value: controller.email.value,
                ),
              ),
              _divider(),
              Obx(
                () => _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Nomor telepon',
                  value: controller.phone.value,
                  isLast: true,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 450.ms)
        .slideY(begin: 0.08, end: 0, delay: 300.ms, duration: 500.ms);
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          _iconBox(icon),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: jakarta.copyWith(
                    color: AppColors.slate500,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: jakarta.copyWith(
                    color: AppColors.slate900,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.shield_outlined,
                title: 'Keamanan akun',
                subtitle: 'Pengaturan keamanan akun',
                onTap: () => controller.openComingSoon('Keamanan akun'),
              ),
              _divider(),
              _buildMenuItem(
                icon: Icons.tune_rounded,
                title: 'Pengaturan aplikasi',
                subtitle: 'Atur preferensi aplikasi',
                onTap: () => controller.openComingSoon('Pengaturan aplikasi'),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 450.ms)
        .slideY(begin: 0.08, end: 0, delay: 400.ms, duration: 500.ms);
  }

  Widget _buildHelpCard() {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.support_agent_rounded,
                title: 'Pusat bantuan',
                subtitle: 'Temukan bantuan penggunaan aplikasi',
                onTap: () => controller.openComingSoon('Pusat bantuan'),
              ),
              _divider(),
              _buildMenuItem(
                icon: Icons.info_outline_rounded,
                title: 'Tentang Saferuas',
                subtitle: 'Informasi mengenai aplikasi',
                onTap: () => controller.openComingSoon('Tentang Saferuas'),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 500.ms, duration: 450.ms)
        .slideY(begin: 0.08, end: 0, delay: 500.ms, duration: 500.ms);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              _iconBox(icon),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: jakarta.copyWith(
                        color: AppColors.slate900,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: jakarta.copyWith(
                        color: AppColors.slate500,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.slate400,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _showLogoutDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.red.withValues(alpha: 0.13)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'Keluar dari akun',
                    style: jakarta.copyWith(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 600.ms, duration: 450.ms)
        .slideY(begin: 0.08, end: 0, delay: 600.ms, duration: 500.ms);
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 26,
                ),
              ),
              const SizedBox(height: 17),
              Text(
                'Keluar dari akun?',
                style: jakarta.copyWith(
                  color: AppColors.slate900,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah kamu yakin ingin keluar dari aplikasi Saferuas?',
                textAlign: TextAlign.center,
                style: jakarta.copyWith(
                  color: AppColors.slate500,
                  fontSize: 11,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.slate600,
                        side: BorderSide(color: AppColors.slate200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: Text(
                        'Batal',
                        style: jakarta.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: controller.logout,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: Text(
                        'Keluar',
                        style: jakarta.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      transitionCurve: Curves.easeOutBack,
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_rounded, color: AppColors.homeBlue, size: 14),
            const SizedBox(width: 6),
            Text(
              'SAFERUAS',
              style: jakarta.copyWith(
                color: AppColors.slate500,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Mewujudkan perjalanan yang lebih aman.',
          style: jakarta.copyWith(
            color: AppColors.slate400,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms, duration: 500.ms);
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 41,
      height: 41,
      decoration: BoxDecoration(
        color: AppColors.homeCardTint,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: AppColors.homeBlue, size: 19),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.slate100,
      indent: 54,
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: AppColors.homeCardBorder),
      boxShadow: [
        BoxShadow(
          color: AppColors.slate900.withValues(alpha: 0.035),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
