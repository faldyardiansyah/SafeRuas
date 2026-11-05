enum ReportCategory { jalanRusak, fasilitasUmum }

extension ReportCategoryX on ReportCategory {
  String get label =>
      this == ReportCategory.jalanRusak ? 'Jalan Rusak' : 'Fasilitas Umum';

  String get apiValue =>
      this == ReportCategory.jalanRusak ? 'jalan_rusak' : 'fasilitas_umum';
}