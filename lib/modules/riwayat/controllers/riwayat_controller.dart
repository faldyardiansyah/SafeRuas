import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saferuas/utils/app_colors.dart';

/// Kategori laporan yang bisa diajukan pengguna.
enum ReportCategory { jalan, fasilitas }

/// Status laporan mengikuti alur verifikasi komunitas JagaJalan.
enum ReportStatus { menunggu, diproses, diperbaiki, ditolak }

extension ReportCategoryX on ReportCategory {
  String get label => this == ReportCategory.jalan ? 'Jalan Rusak' : 'Fasilitas';

  IconData get icon => this == ReportCategory.jalan
      ? Icons.warning_rounded
      : Icons.lightbulb_outline_rounded;

  Color get color =>
      this == ReportCategory.jalan ? AppColors.dangerRed : AppColors.amber500;

  Color get tint => this == ReportCategory.jalan
      ? const Color(0xFFFFF1F2)
      : const Color(0xFFFFFBEB);
}

extension ReportStatusX on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.menunggu:
        return 'Menunggu Validasi';
      case ReportStatus.diproses:
        return 'Diproses';
      case ReportStatus.diperbaiki:
        return 'Diperbaiki';
      case ReportStatus.ditolak:
        return 'Ditolak';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportStatus.menunggu:
        return Icons.hourglass_top_rounded;
      case ReportStatus.diproses:
        return Icons.autorenew_rounded;
      case ReportStatus.diperbaiki:
        return Icons.check_circle_rounded;
      case ReportStatus.ditolak:
        return Icons.cancel_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ReportStatus.menunggu:
        return AppColors.slate500;
      case ReportStatus.diproses:
        return AppColors.homeBlue;
      case ReportStatus.diperbaiki:
        return AppColors.emerald600;
      case ReportStatus.ditolak:
        return AppColors.dangerRed;
    }
  }

  Color get tint {
    switch (this) {
      case ReportStatus.menunggu:
        return AppColors.slate100;
      case ReportStatus.diproses:
        return const Color(0xFFEAF0FF);
      case ReportStatus.diperbaiki:
        return AppColors.emerald50;
      case ReportStatus.ditolak:
        return const Color(0xFFFFF1F2);
    }
  }
}

/// Satu langkah perubahan status pada laporan.
class ReportTimeline {
  final ReportStatus status;
  final DateTime time;
  final String note;

  const ReportTimeline({
    required this.status,
    required this.time,
    required this.note,
  });
}

class ReportHistory {
  final String id;
  final String location;
  final String damageType;
  final String description;
  final ReportCategory category;
  final ReportStatus status;
  final DateTime createdAt;
  final int confirmations;
  final List<ReportTimeline> timeline;

  const ReportHistory({
    required this.id,
    required this.location,
    required this.damageType,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.confirmations = 0,
    this.timeline = const [],
  });
}

class RiwayatController extends GetxController {
  final isLoading = false.obs;

  /// Sengaja kosong; diisi dari API/backend saat sudah tersedia.
  final reports = <ReportHistory>[].obs;

  /// null = semua status.
  final selectedStatus = Rxn<ReportStatus>();

  /// null = semua kategori.
  final selectedCategory = Rxn<ReportCategory>();

  final statusFilters = const <ReportStatus?>[
    null,
    ReportStatus.menunggu,
    ReportStatus.diproses,
    ReportStatus.diperbaiki,
    ReportStatus.ditolak,
  ];

  List<ReportHistory> get filteredReports {
    final status = selectedStatus.value;
    final category = selectedCategory.value;

    final result = reports.where((report) {
      final matchStatus = status == null || report.status == status;
      final matchCategory = category == null || report.category == category;
      return matchStatus && matchCategory;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return result;
  }

  int countByStatus(ReportStatus status) =>
      reports.where((report) => report.status == status).length;

  int get totalReports => reports.length;

  @override
  void onInit() {
    super.onInit();
    fetchReports();
  }

  Future<void> fetchReports() async {
    isLoading.value = true;
    try {
      // TODO: Ganti dengan pemanggilan API riwayat laporan pengguna.
      await Future.delayed(const Duration(milliseconds: 600));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshReports() => fetchReports();

  void selectStatus(ReportStatus? status) => selectedStatus.value = status;

  void selectCategory(ReportCategory? category) {
    selectedCategory.value =
        selectedCategory.value == category ? null : category;
  }

  String statusFilterLabel(ReportStatus? status) =>
      status == null ? 'Semua' : status.label;

  String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year} • $hour:$minute';
  }
}

