class ReportSubmitModel {
  final int id;
  final String judul;
  final String kategori;
  final String status;
  final String? foto;
  final String? alamat;
  final String? tanggal;

  const ReportSubmitModel({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.status,
    this.foto,
    this.alamat,
    this.tanggal,
  });

  factory ReportSubmitModel.fromJson(Map<String, dynamic> json) {
    return ReportSubmitModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      judul: json['judul']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      status: json['status']?.toString() ?? 'menunggu',
      foto: json['foto']?.toString(),
      alamat: json['alamat']?.toString(),
      tanggal: json['tanggal']?.toString(),
    );
  }
}
