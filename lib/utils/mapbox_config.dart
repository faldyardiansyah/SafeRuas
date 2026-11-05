import 'package:flutter_dotenv/flutter_dotenv.dart';

// Konfigurasi Mapbox.
class MapboxConfig {
  static String get token => dotenv.env['MAPBOX_TOKEN'] ?? '';

  static bool get hasToken => token.isNotEmpty;

  // Style peta Saferuas.
  static const String dayStyle = 'streets-v12';
  static const String nightStyle = 'dark-v11';

  // Pengaturan suara navigasi.
  static const bool useMapboxVoice = true;

  // URL tile Mapbox 512 px.
  static String tileUrl(bool night) =>
      'https://api.mapbox.com/styles/v1/mapbox/'
      '${night ? nightStyle : dayStyle}'
      '/tiles/512/{z}/{x}/{y}?access_token=$token';
}