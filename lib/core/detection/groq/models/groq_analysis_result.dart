class GroqAnalysisResult {
  final bool isPublicFacility;
  final String facilityType;
  final String condition;
  final String severity;
  final String description;
  final String suggestion;

  GroqAnalysisResult({
    required this.isPublicFacility,
    required this.facilityType,
    required this.condition,
    required this.severity,
    required this.description,
    required this.suggestion,
  });

  factory GroqAnalysisResult.fromJson(Map<String, dynamic> json) {
    return GroqAnalysisResult(
      isPublicFacility: json['fasilitas_umum'] == true,
      facilityType: json['jenis_fasilitas']?.toString() ?? '-',
      condition: json['kondisi']?.toString() ?? '-',
      severity: json['tingkat_keparahan']?.toString() ?? '-',
      description: json['deskripsi']?.toString() ?? '-',
      suggestion: json['saran']?.toString() ?? '-',
    );
  }

  Map<String, dynamic> toJson() => {
        'fasilitas_umum': isPublicFacility,
        'jenis_fasilitas': facilityType,
        'kondisi': condition,
        'tingkat_keparahan': severity,
        'deskripsi': description,
        'saran': suggestion,
      };
}