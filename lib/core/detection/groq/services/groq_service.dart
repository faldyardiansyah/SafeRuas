import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/groq_analysis_result.dart';

class GroqService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  /// Urutan model yang dicoba. Model dari .env (GROQ_MODEL) dicoba paling awal.
  /// Model Preview sering diganti Groq, jadi ada cadangan.
  static List<String> get _models {
    final fromEnv = (dotenv.env['GROQ_MODEL'] ?? '').trim();
    final list = <String>[
      if (fromEnv.isNotEmpty) fromEnv,
      'qwen/qwen3.8-27b',
      'qwen/qwen3.6-27b',
    ];
    return list.toSet().toList(); // hapus duplikat
  }

  static const String _prompt = '''
Kamu adalah asisten pelaporan fasilitas umum untuk aplikasi SafeRuas.
Fasilitas umum yang dicakup: lampu penerangan jalan (PJU), rambu lalu lintas,
lampu lalu lintas (traffic light), halte, marka/pembatas jalan, jembatan penyeberangan,
guardrail, dan sejenisnya. Kerusakan permukaan jalan (lubang/retak) BUKAN bagianmu.

Analisis foto dan balas HANYA dalam JSON dengan key:
- fasilitas_umum: true/false (false jika foto tidak menampilkan fasilitas umum)
- jenis_fasilitas: nama fasilitas, contoh "Lampu jalan (PJU)", "Rambu lalu lintas"
- kondisi: salah satu dari mati, rusak, roboh, miring, hilang, tertutup, normal
- tingkat_keparahan: ringan / sedang / berat
- deskripsi: 1-2 kalimat Bahasa Indonesia untuk isi laporan
- saran: 1 kalimat saran penanganan

Jangan menebak. Kalau kondisi tidak jelas terlihat di foto (misal lampu terlihat
tapi tidak tahu menyala atau tidak), tulis itu di deskripsi.
''';

  Future<GroqAnalysisResult> analyzeImage(Uint8List imageBytes) async {
    if (_apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY belum diatur di file .env.');
    }

    final base64Image = base64Encode(imageBytes);
    String lastError = 'Tidak ada model yang tersedia.';

    for (final model in _models) {
      final http.Response response;
      try {
        response = await http
            .post(
              Uri.parse(_endpoint),
              headers: {
                'Authorization': 'Bearer $_apiKey',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': model,
                'temperature': 0.2,
                'max_tokens': 2048,
                'response_format': {'type': 'json_object'},
                'messages': [
                  {
                    'role': 'user',
                    'content': [
                      {'type': 'text', 'text': _prompt},
                      {
                        'type': 'image_url',
                        'image_url': {
                          'url': 'data:image/jpeg;base64,$base64Image',
                        },
                      },
                    ],
                  },
                ],
              }),
            )
            .timeout(const Duration(seconds: 40));
      } on Exception catch (_) {
        throw Exception(
          'Tidak bisa terhubung ke server AI. Cek koneksi internet.',
        );
      }

      // Model tidak ada -> coba model berikutnya
      if (response.statusCode == 404 &&
          response.body.contains('model_not_found')) {
        lastError = 'Model $model tidak tersedia.';
        continue;
      }

      if (response.statusCode == 429) {
        throw Exception('Kuota AI sedang penuh. Coba lagi sebentar.');
      }
      if (response.statusCode == 401) {
        throw Exception('API key Groq tidak valid.');
      }
      if (response.statusCode != 200) {
        throw Exception('Groq error ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices'][0]['message']['content'] as String;

      return GroqAnalysisResult.fromJson(_extractJson(content));
    }

    throw Exception(
      '$lastError Cek daftar model terbaru di console.groq.com/docs/vision '
      'lalu isi GROQ_MODEL di file .env.',
    );
  }

  /// Jaga-jaga kalau model menambah teks/tag di luar JSON.
  Map<String, dynamic> _extractJson(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start == -1 || end <= start) {
      throw Exception('Balasan AI tidak berformat JSON.');
    }
    return jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
  }
}
