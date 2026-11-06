import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:saferuas/utils/widgets/show_awesome_snackbar.dart';
import 'package:saferuas/utils/widgets/saferuas_loading.dart';
import 'package:saferuas/routes/app_routes.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    if (!GetUtils.isEmail(value.trim())) {
      return 'Masukkan email yang valid';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }

    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }

    return null;
  }

  // Proses pendaftaran
  Future<void> register() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (isLoading.value) return;

    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    SaferuasLoading.show(
      message: 'Sedang menyiapkan akun Saferuas...',
    );

    try {
      // Simulasi proses pendaftaran
      await Future.delayed(const Duration(seconds: 2));

      SaferuasLoading.hide();

      showAwesomeSnackbar(
        title: 'Pendaftaran',
        message: 'Data berhasil divalidasi. API pendaftaran belum dihubungkan.',
        contentType: ContentType.warning,
      );
    } catch (e) {
      SaferuasLoading.hide();

      showAwesomeSnackbar(
        title: 'Pendaftaran gagal',
        message: 'Terjadi kesalahan. Silakan coba kembali.',
        contentType: ContentType.failure,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Kembali ke halaman login
  void goToLogin() {
    Get.offNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
