import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:saferuas/core/api_service.dart';
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

  Future<void> register() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (isLoading.value) return;
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    SaferuasLoading.show(message: 'Sedang menyiapkan akun Saferuas...');

    try {
      debugPrint('[REGISTER] kirim request...');
      final response = await ApiService.dio.post(
        '/register',
        data: {
          'name': namaController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
        },
      );
      debugPrint('[REGISTER] respon: ${response.statusCode}');

      // Simpan sesi. Kalau gagal, jangan batalkan pendaftaran.
      try {
        final box = GetStorage();
        await box.write('token', response.data['token']);
        await box.write('user', response.data['user']);
        debugPrint('[REGISTER] token tersimpan');
      } catch (e) {
        debugPrint('[REGISTER] gagal simpan sesi: $e');
      }

      SaferuasLoading.hide();
      debugPrint('[REGISTER] pindah ke /main');
      Get.offAllNamed('/main');
    } on DioException catch (e) {
      debugPrint(
        '[REGISTER] DioException: ${e.type} | ${e.response?.statusCode} | ${e.message}',
      );
      SaferuasLoading.hide();

      final isValidation = e.response?.statusCode == 422;

      showAwesomeSnackbar(
        title: isValidation ? 'Data belum sesuai' : 'Pendaftaran gagal',
        message: ApiService.errorMessage(
          e,
          fallback: 'Terjadi kesalahan. Silakan coba kembali.',
        ),
        contentType: isValidation ? ContentType.warning : ContentType.failure,
      );
    } catch (e) {
      debugPrint('[REGISTER] error: $e');
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
