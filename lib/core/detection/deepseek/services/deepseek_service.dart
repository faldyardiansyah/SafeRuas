import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../models/groq_analysis_result.dart';

class GroqService {
  /// Mengambil API Key DeepSeek dari .env (atau fallback ke GROQ_API_KEY jika masih pakai nama lama)
  static String get _apiKey =>
      (dotenv.env['DEEPSEEK_API_KEY'] ?? dotenv.env['GROQ_API_KEY'] ?? '')
          .trim();

  static String get _model {
    final fromEnv = (dotenv.env['DEEPSEEK_MODEL'] ?? '').trim();
    return fromEnv.isNotEmpty ? fromEnv : 'deepseek-chat';
  }

  static const String _endpoint = 'https://api.deepseek.com/chat/completions';

  static const String _systemPrompt = '''
Kamu adalah sistem AI analisis fasilitas jalan untuk aplikasi SafeRuas.
Tugasmu menganalisis laporan fasilitas umum jalan (seperti Lampu Penerangan Jalan Umum / PJU, rambu lalu lintas, traffic light, halte, marka/pembatas jalan, atau guardrail) berdasarkan data telemetri visual kamera pengguna.

Balas HANYA dalam format JSON valid dengan key berikut:
- fasilitas_umum: true/false (bernilai true jika objek/kondisi berkaitan dengan fasilitas jalan)
- jenis_fasilitas: nama fasilitas, contoh "Lampu Penerangan Jalan (PJU)", "Rambu Lalu Lintas", "Fasilitas Jalan Umum"
- kondisi: salah satu dari "mati", "rusak", "roboh", "miring", "hilang", "tertutup", "normal"
- tingkat_keparahan: "ringan" / "sedang" / "berat"
- deskripsi: 1-2 kalimat Bahasa Indonesia yang menjelaskan kondisi fasilitas berdasarkan data visual foto
- saran: 1 kalimat saran tindak lanjut untuk petugas terkait
''';

  Future<GroqAnalysisResult> analyzeImage(Uint8List imageBytes) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'DEEPSEEK_API_KEY belum diatur di file .env. Silakan isi terlebih dahulu.',
      );
    }

    // 1. Ekstrak karakteristik visual dari foto (pencahayaan, titik lampu, warna)
    final telemetry = _extractVisualTelemetry(imageBytes);

    // 2. Kirim ke API DeepSeek
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
              'model': _model,
              'temperature': 0.2,
              'max_tokens': 1024,
              'response_format': {'type': 'json_object'},
              'messages': [
                {'role': 'system', 'content': _systemPrompt},
                {
                  'role': 'user',
                  'content':
                      'Pengguna memotret kondisi fasilitas jalan melalui kamera SafeRuas.\n'
                      'Data telemetri visual foto:\n$telemetry\n\n'
                      'Buat analisis laporan fasilitas umum jalan dalam format JSON sesuai instruksi.',
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 40));
    } on Exception catch (_) {
      throw Exception(
        'Tidak bisa terhubung ke server DeepSeek AI. Cek koneksi internet.',
      );
    }

    if (response.statusCode == 401) {
      throw Exception('API Key DeepSeek tidak valid. Cek kembali file .env.');
    }
    if (response.statusCode == 402) {
      throw Exception('Saldo / kuota akun DeepSeek Anda tidak mencukupi.');
    }
    if (response.statusCode == 429) {
      throw Exception('Server DeepSeek sedang sibuk. Coba lagi sebentar.');
    }
    if (response.statusCode != 200) {
      throw Exception(
        'DeepSeek error ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final content = data['choices'][0]['message']['content'] as String;

    return GroqAnalysisResult.fromJson(_extractJson(content));
  }

  /// Mengekstrak informasi pencahayaan, titik cahaya (lampu menyala/mati),
  /// serta dominasi warna dari foto untuk dikirim ke DeepSeek.
  String _extractVisualTelemetry(Uint8List imageBytes) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      return '- Status gambar: Foto fasilitas berhasil diambil kamera.';
    }

    double lumSum = 0;
    int brightSpots = 0;
    int darkPixels = 0;
    int total = 0;

    for (int y = 0; y < decoded.height; y += 16) {
      for (int x = 0; x < decoded.width; x += 16) {
        final p = decoded.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        final lum = 0.299 * r + 0.587 * g + 0.114 * b;

        lumSum += lum;
        if (lum > 220) brightSpots++; // Titik cahaya kuat (misal lampu menyala)
        if (lum < 45) darkPixels++; // Area gelap
        total++;
      }
    }

    final avgLum = total == 0 ? 0.0 : lumSum / total;
    final brightRatio = total == 0 ? 0.0 : (brightSpots / total) * 100;
    final darkRatio = total == 0 ? 0.0 : (darkPixels / total) * 100;

    final String timeCondition;
    if (avgLum < 55) {
      timeCondition =
          'Malam hari / Kondisi gelap (kemungkinan besar pelaporan Lampu PJU mati sehingga jalan gelap)';
    } else if (avgLum < 120) {
      timeCondition = 'Sore / Mendung / Pencahayaan sedang';
    } else {
      timeCondition =
          'Siang hari / Terang (pelaporan kerusakan fisik fasilitas seperti rambu/tiang/marka)';
    }

    final String lightSourceNote = brightRatio < 1.5 && avgLum < 60
        ? 'Tidak terdeteksi pancaran cahaya lampu aktif (indikasi kuat Lampu PJU padam/mati).'
        : 'Terdeteksi titik cahaya sekitar ${brightRatio.toStringAsFixed(1)}% dari area foto.';

    return '''
- Resolusi Foto: ${decoded.width}x${decoded.height} piksel
- Rata-rata Kecerahan (Luminance): ${avgLum.toStringAsFixed(1)} / 255
- Persentase Area Gelap: ${darkRatio.toStringAsFixed(1)}%
- Estimasi Kondisi Lingkungan: $timeCondition
- Analisis Sumber Cahaya: $lightSourceNote
''';
  }

  /// Mengambil objek JSON murni dari balasan teks model
  Map<String, dynamic> _extractJson(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start == -1 || end <= start) {
      throw Exception('Balasan AI tidak berformat JSON.');
    }
    return jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
  }
}