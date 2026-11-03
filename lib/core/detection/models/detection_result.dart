class  DetectionResult {
  final int classId;
  final String className;
  final String displayName;
  final double confidence;
  final double x1, y1, x2, y2;

  DetectionResult({
    required this.classId,
    required this.className,
    required this.displayName,
    required this.confidence,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

    // buat ganti ke persen 
    String get confidencePercent => '${(confidence * 100).round()}%';
}

// ini buat daftar kelas yang bisa dideteksi
const List<String> kYoloClassNames = [
  'alligator cracking',
  'edge cracking',
  'longitudinal cracking',
  'patching',
  'pothole',
  'rutting',
  'transverse cracking',
];

// buat tanslate daftar kelasnya ke Indonesia
const Map<String, String> kClassDisplayNames = {
  'alligator cracking': 'Retak Buaya',
  'edge cracking': 'Retak Tepi',
  'longitudinal cracking': 'Retak Memanjang',
  'patching': 'Tambalan',
  'pothole': 'Lubang Jalan',
  'rutting': 'Jalan Bergelombang',
  'transverse cracking': 'Retak Melintang',
};