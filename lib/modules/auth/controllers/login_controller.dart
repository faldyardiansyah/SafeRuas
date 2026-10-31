import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../../../../utils/widgets/show_awesome_snackbar.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final isPasswordHidden = true.obs;
  final rememberMe = true.obs;
  final isLoading = false.obs;

  // Mengatur visibilitas password
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Mengatur checkbox remember me
  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  // Validasi email
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final input = value.trim();

    final isEmail = GetUtils.isEmail(input);

    if (!isEmail) {
      return 'Masukkan email harus benar';
    }

    return null;
  }

  // Validasi password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  // Proses login
  Future<void> login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!formKey.currentState!.validate()) return;

    Get.offAllNamed('/main');
  }

  // Lupa password
  void forgotPassword() {
    showAwesomeSnackbar(
      title: 'Lupa Password',
      message: 'Fitur pemulihan password belum tersedia.',
      contentType: ContentType.help,
    );
  }

  // Login menggunakan Google
  void loginWithGoogle() {
    showAwesomeSnackbar(
      title: 'Google Login',
      message: 'Integrasi autentikasi Google belum tersedia.',
      contentType: ContentType.warning,
    );
  }

  // untuk menuju halaman register
  void goToRegister() {
    Get.toNamed('/register');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
