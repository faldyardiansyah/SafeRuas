class HomeStats {
  final int total;
  final int terverifikasi;
  final int diperbaiki;
  final int menunggu;

  const HomeStats({
    this.total = 0,
    this.terverifikasi = 0,
    this.diperbaiki = 0,
    this.menunggu = 0,
  });

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      terverifikasi: (json['terverifikasi'] as num?)?.toInt() ?? 0,
      diperbaiki: (json['diperbaiki'] as num?)?.toInt() ?? 0,
      menunggu: (json['menunggu'] as num?)?.toInt() ?? 0,
    );
  }
}

class HomeReport {
  final int id;
  final String judul;
  final String? alamat;
  final String kategori;
  final String status;
  final String? foto;
  final String? tanggal;
  final double? jarakKm;

  const HomeReport({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.status,
    this.alamat,
    this.foto,
    this.tanggal,
    this.jarakKm,
  });

  bool get isJalanRusak => kategori == 'jalan_rusak';

  factory HomeReport.fromJson(Map<String, dynamic> json) {
    return HomeReport(
      id: (json['id'] as num?)?.toInt() ?? 0,
      judul: json['judul']?.toString() ?? '',
      alamat: json['alamat']?.toString(),
      kategori: json['kategori']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      foto: json['foto']?.toString(),
      tanggal: json['tanggal']?.toString(),
      jarakKm: (json['jarak_km'] as num?)?.toDouble(),
    );
  }
}

class HomeResponse {
  final HomeStats stats;
  final List<HomeReport> recentReports;
  final List<HomeReport> nearby;

  const HomeResponse({
    required this.stats,
    required this.recentReports,
    required this.nearby,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      stats: HomeStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
      recentReports: (json['recent_reports'] as List? ?? [])
          .map((e) => HomeReport.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      nearby: (json['nearby'] as List? ?? [])
          .map((e) => HomeReport.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
