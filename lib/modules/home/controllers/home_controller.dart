import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:saferuas/routes/app_routes.dart';

import '../../../core/api_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/widgets/show_awesome_snackbar.dart';
import '../../main/controllers/main_controller.dart';
import '../../maps/controllers/maps_controller.dart';
import '../models/home_model.dart';

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

typedef ImpactStat = ({String value, String label, Color color});

class HomeController extends GetxController {
  final isLoading = false.obs;
  final scrollController = ScrollController();
  final isHeaderCollapsed = false.obs;
  bool canPullToRefresh = false;

  // Data Real-Time Lokasi & Cuaca
  final location = 'Mendeteksi lokasi...'.obs;
  final temperature = '--°C'.obs;
  final weather = 'Memuat...'.obs;
  final weatherDesc = 'Mengambil data cuaca & kondisi jalan...'.obs;
  final humidity = '--% Lembap'.obs;
  final wind = '-- km/j'.obs;
  final pendingValidation = 0.obs;

  final nearbyCount = 0.obs;
  final nearbyFacilityCount = 0.obs;

  bool _isFetching = false;
  double? _lastLat;
  double? _lastLon;

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
    ),
  ];

  // Data dari Laravel
  final RxList<ReportItem> recentReports = <ReportItem>[].obs;
  final RxList<ConditionItem> conditions = <ConditionItem>[].obs;

  // Statistik dari Laravel
  final RxList<ImpactStat> impactStats = <ImpactStat>[
    (value: '0', label: 'Laporan', color: AppColors.homeBlue),
    (value: '0', label: 'Terverifikasi', color: AppColors.emerald600),
    (value: '0', label: 'Diperbaiki', color: AppColors.amber500),
  ].obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.isRegistered<MapsController>()) {
      final mapsCtrl = Get.find<MapsController>();

      // Gunakan lokasi yang sudah tersedia dari MapsController
      final currentLocation = mapsCtrl.currentLocation.value;

      if (currentLocation != null) {
        _loadFromCoordinates(
          currentLocation.latitude,
          currentLocation.longitude,
        );
      } else {
        refreshHomeData();
      }

      // Pantau perubahan lokasi GPS
      ever(mapsCtrl.currentLocation, (loc) {
        if (loc != null && _movedEnough(loc.latitude, loc.longitude)) {
          _loadFromCoordinates(loc.latitude, loc.longitude);
        }
      });
    } else {
      refreshHomeData();
    }
  }

  bool _movedEnough(double lat, double lon) {
    if (_isFetching) return false;
    final lastLat = _lastLat;
    final lastLon = _lastLon;
    if (lastLat == null || lastLon == null) return true;
    return Geolocator.distanceBetween(lastLat, lastLon, lat, lon) > 300;
  }

  // LOAD DATA HOME

  Future<void> _loadFromCoordinates(double lat, double lon) async {
    if (_isFetching) return;
    _isFetching = true;
    _lastLat = lat;
    _lastLon = lon;
    isLoading.value = true;

    try {
      await Future.wait([
        _fetchAddressFromCoordinates(lat, lon),
        _fetchRealtimeWeather(lat, lon),
      ]);

      // Ambil statistik dan laporan dari Laravel
      await _fetchBackendData(lat: lat, lon: lon);
    } catch (e) {
      debugPrint('[HOME] Gagal memuat data Home: $e');
    } finally {
      _isFetching = false;
      isLoading.value = false;
    }
  }

  Future<void> refreshHomeData() async {
    try {
      isLoading.value = true;

      final position = await _determinePosition();

      if (position == null) {
        location.value = 'Izin lokasi belum aktif';

        showAwesomeSnackbar(
          title: 'Lokasi tidak tersedia',
          message: 'Aktifkan GPS dan izin lokasi untuk memperbarui data.',
          contentType: ContentType.warning,
        );

        // Tetap ambil laporan dan statistik meskipun GPS tidak aktif
        await _fetchBackendData();
        return;
      }

      _isFetching = false;
      await _loadFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('[HOME] Gagal refresh Home: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // REQUEST KE LARAVEL API

  Future<void> _fetchBackendData({double? lat, double? lon}) async {
    try {
      final response = await ApiService.dio.get(
        '/home',
        queryParameters: {
          if (lat != null) 'lat': lat,
          if (lon != null) 'lon': lon,
        },
      );

      debugPrint('[HOME] HTTP Status: ${response.statusCode}');

      final home = HomeResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      // STATISTIK
      impactStats.value = [
        (
          value: '${home.stats.total}',
          label: 'Laporan',
          color: AppColors.homeBlue,
        ),
        (
          value: '${home.stats.terverifikasi}',
          label: 'Terverifikasi',
          color: AppColors.emerald600,
        ),
        (
          value: '${home.stats.diperbaiki}',
          label: 'Diperbaiki',
          color: AppColors.amber500,
        ),
      ];

      pendingValidation.value = home.stats.menunggu;

      // LAPORAN TERKINI
      recentReports.value = home.recentReports.map(_toReportItem).toList();

      // KONDISI SEKITAR
      conditions.value = home.nearby.map(_toConditionItem).toList();
      nearbyCount.value = home.nearby.length;
      nearbyFacilityCount.value = home.nearby
          .where((r) => !r.isJalanRusak)
          .length;

      debugPrint('[HOME] Data Laravel berhasil dimuat');
      debugPrint('[HOME] Total laporan: ${home.stats.total}');
      debugPrint('[HOME] Laporan terkini: ${home.recentReports.length}');
      debugPrint('[HOME] Kondisi sekitar: ${home.nearby.length}');
    } catch (e) {
      debugPrint('[HOME] Error mengambil data Laravel: $e');
    }
  }

  // KONVERSI DATA LAPORAN
  ({String label, Color color, Color bg}) _statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'diperbaiki':
        return (
          label: 'Selesai',
          color: const Color(0xFF059669),
          bg: const Color(0xFFECFDF5),
        );

      case 'terverifikasi':
        return (
          label: 'Terverifikasi',
          color: const Color(0xFF2563EB),
          bg: const Color(0xFFEFF6FF),
        );

      case 'diproses':
      case 'proses':
        return (
          label: 'Diproses',
          color: const Color(0xFFD97706),
          bg: const Color(0xFFFFFBEB),
        );

      case 'ditolak':
        return (
          label: 'Ditolak',
          color: const Color(0xFFDC2626),
          bg: const Color(0xFFFEF2F2),
        );

      default:
        return (
          label: 'Menunggu',
          color: const Color(0xFF64748B),
          bg: const Color(0xFFF1F5F9),
        );
    }
  }

  String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;

    try {
      final origin = Uri.parse(ApiService.dio.options.baseUrl).origin;
      if (path.startsWith('/')) return '$origin$path';
      return '$origin/storage/$path';
    } catch (_) {
      return null;
    }
  }

  ReportItem _toReportItem(HomeReport report) {
    final isRoad = report.isJalanRusak;
    final style = _statusStyle(report.status);

    return (
      title: report.judul,
      subtitle: '${report.alamat ?? '-'} • ${report.tanggal ?? ''}',
      status: style.label,
      statusColor: style.color,
      statusBg: style.bg,
      statusBorder: null,
      image: _resolveImageUrl(report.foto),
      icon: isRoad
          ? Icons.report_problem_rounded
          : Icons.lightbulb_outline_rounded,
      iconColor: isRoad ? const Color(0xFFE11D48) : const Color(0xFFF59E0B),
      thumbBg: isRoad ? const Color(0xFFFFF1F2) : const Color(0xFFFFFBEB),
    );
  }

  ConditionItem _toConditionItem(HomeReport report) {
    final isRoad = report.isJalanRusak;
    final style = _statusStyle(report.status);

    final jarak = report.jarakKm ?? 0;

    return (
      badge: isRoad ? 'JALAN RUSAK' : 'FASILITAS',
      badgeColor: isRoad ? const Color(0xFFE11D48) : const Color(0xFFF59E0B),
      badgeBg: isRoad ? const Color(0xFFFFF1F2) : const Color(0xFFFFFBEB),
      trailingIcon: Icons.near_me_rounded,
      trailingIconColor: const Color(0xFF64748B),
      trailingText: '${jarak.toStringAsFixed(2)} km',
      trailingTextColor: const Color(0xFF64748B),
      title: report.judul,
      description: report.alamat ?? 'Lokasi tidak diketahui',
      footer: style.label,
      footerMono: false,
      actionLabel: 'Lihat Peta',
      primaryAction: true,
    );
  }

  // ini untuk gps
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
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
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

        final road =
            addr['road'] ??
            addr['suburb'] ??
            addr['village'] ??
            addr['neighbourhood'] ??
            'Lokasi Anda';

        final city =
            addr['city'] ??
            addr['county'] ??
            addr['town'] ??
            addr['state'] ??
            '';

        location.value = city.toString().isNotEmpty ? '$road, $city' : '$road';
      }
    } catch (_) {
      location.value = '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
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

  ({String label, String roadDesc}) _mapWeatherCode(int code, bool isDay) {
    final modeText = isDay
        ? 'Mode Siang Aktif'
        : 'Mode Malam Aktif (PJU Dihitung)';

    if (code == 0) {
      return (label: 'Cerah', roadDesc: 'Jalan Kering • $modeText');
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

  // NAVIGASI
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

    if (label == 'Jalan Rusak') {
      Get.toNamed(
        AppRoutes.reportCamera,
        arguments: {
          'reportType': 'jalan_rusak',
          'title': 'Laporan Jalan Rusak',
        },
      );
      return;
    }

    if (label == 'Lapor Fasilitas') {
      Get.toNamed(
        AppRoutes.reportCamera,
        arguments: {
          'reportType': 'fasilitas',
          'title': 'Laporan Fasilitas Umum',
        },
      );
      return;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
