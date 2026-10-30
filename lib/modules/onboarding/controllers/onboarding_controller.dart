import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();

  final RxInt currentPage = 0.obs;

  final List<Map<String, String>> pages = [
    {
      'eyebrow': 'PAHAMI KONDISI JALAN',
      'title': 'Perjalanan aman\nberawal dari sini.',
      'description':
          'Kenali lubang, retakan, dan jalan gelap melalui '
          'deteksi AI serta informasi dari warga.',
      'animation': 'assets/lotties/maps.json',
      'label1': 'Deteksi AI',
      'label2': 'Info bahaya',
    },
    {
      'eyebrow': 'NAVIGASI LEBIH BIJAK',
      'title': 'Pilih rute yang\nlebih aman.',
      'description':
          'Bandingkan rute berdasarkan kondisi jalan dan '
          'titik bahaya untuk membantu menentukan perjalanan.',
      'animation': 'assets/lotties/onboarding1.json',
      'label1': 'Rute aman',
      'label2': 'Peta interaktif',
    },
    {
      'eyebrow': 'BERSAMA PEDULI JALAN',
      'title': 'Laporkan. Pantau.\nBantu perbaikan.',
      'description':
          'Kirim laporan kerusakan, konfirmasi kondisi jalan, '
          'dan pantau perkembangannya sampai selesai.',
      'animation': 'assets/lotties/road_maintenance.json',
      'label1': 'Lapor jalan',
      'label2': 'Pantau status',
    },
  ];

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Get.offAllNamed('/login');
    }
  }

  void skipOnboarding() {
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
