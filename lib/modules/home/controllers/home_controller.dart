import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/app_colors.dart';
import '../../../utils/widgets/show_awesome_snackbar.dart';
import '../../main/controllers/main_controller.dart';
import '../../maps/controllers/maps_controller.dart';

typedef QuickFeature = ({String label, IconData icon, Color color, Color bg});

typedef ReportItem = ({
  String title,
  String subtitle,
  String status,
  Color statusColor,
  Color statusBg,
  Color? statusBorder,
  String? image,
  IconData icon,
  Color iconColor,
  Color thumbBg,
});

typedef ConditionItem = ({
  String badge,
  Color badgeColor,
  Color badgeBg,
  IconData? trailingIcon,
  Color trailingIconColor,
  String trailingText,
  Color trailingTextColor,
  String title,
  String description,
  String footer,
  bool footerMono,
  String actionLabel,
  bool primaryAction,
});

typedef ImpactStat = ({
  String value,
  String label,
  Color color,
});

class HomeController extends GetxController {
  final isLoading = false.obs;

  // Data Real-Time Lokasi & Cuaca
  final location = 'Mendeteksi lokasi...'.obs;
  final temperature = '--°C'.obs;
  final weather = 'Memuat...'.obs;
  final weatherDesc = 'Mengambil data cuaca & kondisi jalan...'.obs;
  final humidity = '--% Lembap'.obs;
  final wind = '-- km/j'.obs;
  final pendingValidation = 0.obs;

  // Menu Fitur Cepat
  final List<QuickFeature> quickFeatures = const [
    (
      label: 'Jalan Rusak',
      icon: Icons.report_problem_rounded,
      color: Color(0xFFE11D48),
      bg: Color(0xFFFFF1F2),
    ),
    (
      label: 'Lapor Fasilitas',
      icon: Icons.lightbulb_outline_rounded,
      color: Color(0xFFF59E0B),
      bg: Color(0xFFFFFBEB),
    ),
    (
      label: 'Rute Aman',
      icon: Icons.alt_route_rounded,
      color: Color(0xFF059669),
      bg: Color(0xFFECFDF5),
    )
  ];
  // Kosong tanpa data dummy
  final RxList<ReportItem> recentReports = <ReportItem>[].obs;
  final RxList<ConditionItem> conditions = <ConditionItem>[].obs;

  // Statistik mulai dari 0
  final RxList<ImpactStat> impactStats = <ImpactStat>[
    (
      value: '0',
      label: 'Laporan',
      color: AppColors.homeBlue
    ),
    (
      value: '0',
      label: 'Terverifikasi',
      color: AppColors.emerald600
    ),
    (
      value: '0',
      label: 'Diperbaiki',
      color: AppColors.amber500
    ),
  ].obs;

   @override
  void onInit() {
    super.onInit();

    // Jika MapsController sudah ada, langsung pantau koordinat GPS dari MapsController
    if (Get.isRegistered<MapsController>()) {
      final mapsCtrl = Get.find<MapsController>();

      // Jika di Maps sudah ada lokasi, langsung pakai
      if (mapsCtrl.currentLocation.value != null) {
        final loc = mapsCtrl.currentLocation.value!;
        _loadFromCoordinates(loc.latitude, loc.longitude);
      }

      // Setiap kali Maps berhasil menemukan lokasi baru, Home otomatis ikut update
      ever(mapsCtrl.currentLocation, (loc) {
        if (loc != null) {
          _loadFromCoordinates(loc.latitude, loc.longitude);
        }
      });
    } else {
      refreshHomeData();
    }
  }

  Future<void> _loadFromCoordinates(double lat, double lon) async {
    isLoading.value = true;
    try {
      await Future.wait([
        _fetchAddressFromCoordinates(lat, lon),
        _fetchRealtimeWeather(lat, lon),
      ]);
      _syncWithMapsReports();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHomeData() async {
    final position = await _determinePosition();
    if (position == null) {
      location.value = 'Izin lokasi belum aktif';
      return;
    }
    await _loadFromCoordinates(position.latitude, position.longitude);
  }

  Future<Position?> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<void> _fetchAddressFromCoordinates(double lat, double lon) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'format': 'jsonv2',
        'zoom': '18',
      });

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Saferuas/1.0 (Flutter application)',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final addr = data['address'] as Map<String, dynamic>? ?? {};

        final road = addr['road'] ??
            addr['suburb'] ??
            addr['village'] ??
            addr['neighbourhood'] ??
            'Lokasi Anda';
        final city = addr['city'] ??
            addr['county'] ??
            addr['town'] ??
            addr['state'] ??
            '';

        location.value = city.toString().isNotEmpty ? '$road, $city' : '$road';
      }
    } catch (_) {
      location.value =
          '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
    }
  }

  Future<void> _fetchRealtimeWeather(double lat, double lon) async {
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,is_day',
        'timezone': 'auto',
      });

      final response = await http.get(uri);
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>? ?? {};

      final temp = (current['temperature_2m'] as num?)?.round() ?? 0;
      final hum = (current['relative_humidity_2m'] as num?)?.round() ?? 0;
      final windSpeed = (current['wind_speed_10m'] as num?)?.round() ?? 0;
      final code = (current['weather_code'] as num?)?.toInt() ?? 0;
      final isDay = (current['is_day'] as num?)?.toInt() == 1;

      temperature.value = '$temp°C';
      humidity.value = '$hum% Lembap';
      wind.value = '$windSpeed km/j';

      final mapped = _mapWeatherCode(code, isDay);
      weather.value = mapped.label;
      weatherDesc.value = mapped.roadDesc;
    } catch (_) {
      weather.value = 'Tidak tersedia';
    }
  }

  void _syncWithMapsReports() {
    if (!Get.isRegistered<MapsController>()) return;
    final mapsCtrl = Get.find<MapsController>();
    final hazards = mapsCtrl.hazardReports;

    pendingValidation.value = hazards.length;
  }

  ({String label, String roadDesc}) _mapWeatherCode(int code, bool isDay) {
    final modeText =
        isDay ? 'Mode Siang Aktif' : 'Mode Malam Aktif (PJU Dihitung)';
    if (code == 0) {
      return (
        label: 'Cerah',
        roadDesc: 'Jalan Kering • $modeText',
      );
    } else if (code <= 3) {
      return (
        label: 'Cerah Berawan',
        roadDesc: 'Jarak Pandang Baik • $modeText',
      );
    } else if (code <= 48) {
      return (
        label: 'Berkabut',
        roadDesc: 'Jarak Pandang Terbatas • $modeText',
      );
    } else if (code <= 67) {
      return (
        label: 'Hujan',
        roadDesc: 'Waspada Genangan & Jalan Licin • $modeText',
      );
    } else {
      return (
        label: 'Hujan Deras',
        roadDesc: 'Risiko Genangan Tinggi • $modeText',
      );
    }
  }

  void openMap() {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().changeTab(1);
    }
  }

  void onFeatureTap(String label) {
    if (label == 'Rute Aman') {
      openMap();
      return;
    }

    // Semua fitur cepat yang belum dibuat menampilkan notifikasi ini
    showAwesomeSnackbar(
      title: label,
      message: 'Fitur $label belum tersedia.',
      contentType: ContentType.warning,
    );
  }
}