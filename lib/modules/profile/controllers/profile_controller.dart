import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:saferuas/utils/widgets/show_awesome_snackbar.dart';

class ProfileController extends GetxController {
  final name = 'Pengguna Saferuas'.obs;
  final email = 'pengguna@email.com'.obs;
  final phone = 'Belum ditambahkan'.obs;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    nameController.text = name.value;
  }

  void openEditProfile() {
    nameController.text = name.value;
    phoneController.text = phone.value == 'Belum ditambahkan'
        ? ''
        : phone.value;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Nomor telepon'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          FilledButton(onPressed: saveProfile, child: const Text('Simpan')),
        ],
      ),
    );
  }

  void saveProfile() {
    final newName = nameController.text.trim();
    final newPhone = phoneController.text.trim();

    if (newName.isEmpty) {
      showAwesomeSnackbar(
        title: 'Nama belum diisi',
        message: 'Silakan masukkan nama terlebih dahulu.',
        contentType: ContentType.warning,
      );
      return;
    }

    // Sementara hanya tersimpan di memori aplikasi.
    name.value = newName;
    phone.value = newPhone.isEmpty ? 'Belum ditambahkan' : newPhone;

    Get.back();

    showAwesomeSnackbar(
      title: 'Profil diperbarui',
      message: 'Perubahan sementara berhasil diterapkan.',
      contentType: ContentType.success,
    );
  }

  void openComingSoon(String feature) {
    showAwesomeSnackbar(
      title: feature,
      message: 'Fitur ini akan tersedia setelah tahap pengembangan berikutnya.',
      contentType: ContentType.help,
    );
  }

  void logout() {
    // TODO: Hubungkan ke API logout saat backend siap.
    // Ganti '/login' jika nama route login di proyekmu berbeda.
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
