import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:saferuas/utils/mapbox_config.dart';

class NavigationStep {
  final String instruction;
  final double distance;
  final LatLng location;
  final String maneuverType;
  final String modifier;

  NavigationStep({
    required this.instruction,
    required this.distance,
    required this.location,
    required this.maneuverType,
    required this.modifier,
  });
}

class _ParsedRoute {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationMinutes;
  final List<NavigationStep> steps;

  _ParsedRoute(
    this.points,
    this.distanceMeters,
    this.durationMinutes,
    this.steps,
  );
}

class _Proj {
  final double distance;
  final double t;

  const _Proj(this.distance, this.t);
}

class _RouteHazard {
  final String type;
  final double along;
  bool warned = false;

  _RouteHazard(this.type, this.along);
}

class MapsController extends GetxController {
  final mapController = MapController();

  final isNightMode = false.obs;
  final currentWibTime = ''.obs;

  final isLoadingLocation = false.obs;
  final isSearching = false.obs;
  final isLoadingRoute = false.obs;

  final currentLocation = Rxn<LatLng>();
  final destination = Rxn<LatLng>();

  final searchController = TextEditingController();
  final destinationName = ''.obs;

  final searchResults = <Map<String, dynamic>>[].obs;
  final routes = <List<LatLng>>[].obs;

  final selectedRoute = 0.obs;
  final routeDistances = <String>[].obs;
  final routeDurations = <String>[].obs;
  final _routeDurationMinutes = <double>[];

  final hazardReports = <Map<String, dynamic>>[].obs;
  final routeRiskScores = <double>[].obs;
  final routeRiskLabels = <String>[].obs;
  final hasHazardData = false.obs;

  final isNavigating = false.obs;
  final currentStepIndex = 0.obs;
  final navigationSteps = <NavigationStep>[].obs;
  final distanceToNextStep = 0.0.obs;
  final distanceToDestination = 0.0.obs;
  final remainingRoute = <LatLng>[].obs;
  final vehicleHeading = 0.0.obs;
  final remainingDuration = 0.0.obs;
  final gpsAccuracy = 0.0.obs;
  final isSpeakingEnabled = true.obs;
  final FlutterTts _tts = FlutterTts();

  // Tahap pengumuman terakhir per langkah: 1 jauh, 2 menengah, 3 dekat
  final Map<int, int> _announcedStage = {};

  double _routeTotalDistance = 0;
  double _routeTotalDuration = 0;
  int _progressPointIndex = 0;
  int _offRouteCount = 0;
  double _lastValidSpeed = 0;

  List<double> _cumDist = [];
  double _alongMeters = 0;
  List<int> _stepRouteIndex = [];
  final List<_RouteHazard> _routeHazards = [];
  DateTime _lastHazardSpeak = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastTurnSpeak = DateTime.fromMillisecondsSinceEpoch(0);

  DateTime _lastReroute = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isRerouting = false;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _clockTimer;

  final List<List<NavigationStep>> _routeNavigationSteps = [];

  bool mapReady = false;
  bool _isUpdatingProgress = false;

  String get timePeriod => isNightMode.value ? 'Malam hari' : 'Siang hari';

  NavigationStep? get currentNavigationStep {
    if (navigationSteps.isEmpty ||
        currentStepIndex.value >= navigationSteps.length) {
      return null;
    }

    return navigationSteps[currentStepIndex.value];
  }

  String get currentInstruction {
    return currentNavigationStep?.instruction ??
        'Lanjutkan perjalanan menuju tujuan';
  }

  String get nextStepDistanceText {
    return _formatDistance(distanceToNextStep.value);
  }

  String get destinationDistanceText =>
      _formatDistance(distanceToDestination.value);

  List<LatLng> get routeToDraw => remainingRoute;

  String get remainingTimeText {
    final minutes = remainingDuration.value.ceil();
    if (minutes <= 0) return '<1 menit';
    if (minutes < 60) return '$minutes menit';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours jam' : '$hours jam $rest menit';
  }

  @override
  void onInit() {
    super.onInit();

    updateWibTime();

    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => updateWibTime(),
    );

    _configureTts();
    getCurrentLocation();
  }

  void updateWibTime() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));

    currentWibTime.value =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')} WIB';

    final hour = now.hour;
    final night = hour >= 18 || hour < 6;

    if (isNightMode.value != night) {
      isNightMode.value = night;
      calculateRouteRisks();
    }
  }

  void onMapReady() {
    mapReady = true;

    if (!MapboxConfig.hasToken) {
      Get.snackbar(
        'Token Mapbox belum diisi',
        'Isi MAPBOX_TOKEN di file .env lalu jalankan ulang aplikasi.',
        duration: const Duration(seconds: 6),
      );
    }

    if (currentLocation.value != null) {
      mapController.move(currentLocation.value!, 15);
    }
    debugPrint('[MAPBOX] hasToken=${MapboxConfig.hasToken} '
    'len=${MapboxConfig.token.length} '
    'awal=${MapboxConfig.token.length > 8 ? MapboxConfig.token.substring(0, 8) : MapboxConfig.token}');
  }

  Future<bool> _checkLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      Get.snackbar(
        'Lokasi tidak aktif',
        'Aktifkan GPS perangkat terlebih dahulu.',
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Izin lokasi diperlukan',
        'Izinkan akses lokasi agar Saferuas dapat digunakan.',
      );
      return false;
    }

    return true;
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoadingLocation.value = true;

      final permitted = await _checkLocationPermission();
      if (!permitted) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final location = LatLng(position.latitude, position.longitude);
      currentLocation.value = location;

      if (mapReady) {
        mapController.move(location, 15);
      }

      if (destination.value != null && !isNavigating.value) {
        await getRoutes();
      }
    } catch (e) {
      Get.snackbar('Gagal mengambil lokasi', e.toString());
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> searchDestination(String query) async {
    if (query.trim().isEmpty) return;

    try {
      isSearching.value = true;
      searchResults.clear();

      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query.trim(),
        'format': 'jsonv2',
        'limit': '5',
        'countrycodes': 'id',
      });

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Saferuas/1.0 (Flutter application)',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Pencarian lokasi gagal.');
      }

      final List data = jsonDecode(response.body);

      searchResults.assignAll(
        data.map<Map<String, dynamic>>((item) {
          return {
            'name': item['display_name'] ?? 'Lokasi tujuan',
            'lat': double.parse(item['lat'].toString()),
            'lon': double.parse(item['lon'].toString()),
          };
        }).toList(),
      );

      if (searchResults.isEmpty) {
        Get.snackbar('Tidak ditemukan', 'Lokasi yang dicari tidak ditemukan.');
      }
    } catch (e) {
      Get.snackbar('Pencarian gagal', e.toString());
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> selectDestination(Map<String, dynamic> item) async {
    if (isNavigating.value) {
      stopNavigation();
    }

    destination.value = LatLng(
      (item['lat'] as num).toDouble(),
      (item['lon'] as num).toDouble(),
    );

    destinationName.value = item['name'].toString();
    searchController.text = item['name'].toString();

    searchResults.clear();

    await getRoutes();
  }

  Future<List<_ParsedRoute>> _requestRoutes(
    LatLng origin,
    LatLng target, {
    bool alternatives = true,
  }) async {
    if (!MapboxConfig.hasToken) {
      throw Exception(
        'Token Mapbox belum terpasang. Isi MAPBOX_TOKEN di file .env.',
      );
    }

    final coordinates =
        '${origin.longitude},${origin.latitude};'
        '${target.longitude},${target.latitude}';

    final uri = Uri.https(
      'api.mapbox.com',
      '/directions/v5/mapbox/driving/$coordinates',
      {
        'alternatives': alternatives ? 'true' : 'false',
        'geometries': 'geojson',
        'overview': 'full',
        'steps': 'true',
        'language': 'id',
        'access_token': MapboxConfig.token,
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 401) {
      throw Exception(
        'Token Mapbox ditolak (401). Periksa MAPBOX_TOKEN di .env.',
      );
    }
    if (response.statusCode != 200) {
      throw Exception('Tidak dapat mengambil rute (${response.statusCode}).');
    }

    final data = jsonDecode(response.body);

    if (data['code'] != 'Ok' || (data['routes'] as List).isEmpty) {
      throw Exception('Rute perjalanan tidak ditemukan.');
    }

    final result = <_ParsedRoute>[];

    for (final route in data['routes'] as List) {
      final coords = route['geometry']['coordinates'] as List;

      final points = coords.map<LatLng>((coordinate) {
        return LatLng(
          (coordinate[1] as num).toDouble(),
          (coordinate[0] as num).toDouble(),
        );
      }).toList();

      final distance = (route['distance'] as num).toDouble();
      final duration = (route['duration'] as num).toDouble() / 60;

      final steps = <NavigationStep>[];
      final legs = route['legs'] as List? ?? [];

      for (final leg in legs) {
        final legSteps = leg['steps'] as List? ?? [];

        for (final step in legSteps) {
          final maneuver = step['maneuver'] as Map<String, dynamic>?;
          if (maneuver == null) continue;

          final location = maneuver['location'] as List?;
          if (location == null || location.length < 2) continue;

          final type = (maneuver['type'] ?? '').toString();
          final modifier = (maneuver['modifier'] ?? '').toString();
          final name = (step['name'] ?? '').toString();
          final stepDistance = (step['distance'] as num?)?.toDouble() ?? 0;

          steps.add(
            NavigationStep(
              instruction: _createInstruction(type, modifier, name),
              distance: stepDistance,
              location: LatLng(
                (location[1] as num).toDouble(),
                (location[0] as num).toDouble(),
              ),
              maneuverType: type,
              modifier: modifier,
            ),
          );
        }
      }

      result.add(_ParsedRoute(points, distance, duration, steps));
    }

    return result;
  }

  void _applyParsedRoutes(List<_ParsedRoute> parsed) {
    routes.clear();
    routeDistances.clear();
    routeDurations.clear();
    _routeDurationMinutes.clear();
    _routeNavigationSteps.clear();

    for (final r in parsed) {
      routes.add(r.points);
      routeDistances.add('${(r.distanceMeters / 1000).toStringAsFixed(1)} km');
      routeDurations.add('${r.durationMinutes.round()} menit');
      _routeDurationMinutes.add(r.durationMinutes);
      _routeNavigationSteps.add(r.steps);
    }

    selectedRoute.value = 0;
  }

  Future<void> getRoutes() async {
    final origin = currentLocation.value;
    final target = destination.value;

    if (origin == null || target == null) {
      Get.snackbar(
        'Lokasi belum tersedia',
        'Pastikan lokasi asal dan tujuan sudah tersedia.',
      );
      return;
    }

    try {
      isLoadingRoute.value = true;

      routes.clear();
      routeDistances.clear();
      routeDurations.clear();
      _routeDurationMinutes.clear();
      routeRiskScores.clear();
      routeRiskLabels.clear();
      _routeNavigationSteps.clear();

      final parsed = await _requestRoutes(origin, target);

      _applyParsedRoutes(parsed);

      if (parsed.isNotEmpty) {
        _routeTotalDistance = parsed[0].distanceMeters;
        _routeTotalDuration = parsed[0].durationMinutes;
      }

      calculateRouteRisks();
      _fitSelectedRoute();
    } catch (e) {
      routes.clear();
      routeDistances.clear();
      routeDurations.clear();
      _routeDurationMinutes.clear();
      routeRiskScores.clear();
      routeRiskLabels.clear();
      _routeNavigationSteps.clear();

      Get.snackbar('Rute gagal dimuat', e.toString());
    } finally {
      isLoadingRoute.value = false;
    }
  }

  String _createInstruction(String type, String modifier, String roadName) {
    final road = roadName.trim().isEmpty ? 'jalan berikutnya' : roadName;

    switch (type) {
      case 'depart':
        return 'Mulai perjalanan menuju $road';

      case 'arrive':
        return 'Anda akan tiba di tujuan';

      case 'turn':
        return '${_turnText(modifier)} ke $road';

      case 'continue':
        return 'Terus lurus menuju $road';

      case 'new name':
        return 'Lanjutkan perjalanan menuju $road';

      case 'merge':
        return 'Bergabung ke $road';

      case 'on ramp':
        return 'Masuk ke jalur $road';

      case 'off ramp':
        return 'Keluar menuju $road';

      case 'fork':
        return '${_turnText(modifier)} di persimpangan menuju $road';

      case 'roundabout':
      case 'rotary':
        return 'Masuki bundaran menuju $road';

      case 'end of road':
        return 'Di ujung jalan, ${_turnText(modifier)}';

      case 'notification':
        return 'Perhatikan kondisi jalan di depan';

      default:
        return 'Lanjutkan perjalanan menuju $road';
    }
  }

  String _turnText(String modifier) {
    switch (modifier) {
      case 'left':
        return 'Belok kiri';
      case 'right':
        return 'Belok kanan';
      case 'slight left':
        return 'Belok sedikit ke kiri';
      case 'slight right':
        return 'Belok sedikit ke kanan';
      case 'sharp left':
        return 'Belok tajam ke kiri';
      case 'sharp right':
        return 'Belok tajam ke kanan';
      case 'uturn':
        return 'Putar balik';
      case 'straight':
        return 'Terus lurus';
      default:
        return 'Ikuti arah jalan';
    }
  }

  // HAZARD & SKOR RISIKO

  String _normalizeHazardType(Map<String, dynamic> hazard) {
    return (hazard['type'] ?? '')
        .toString()
        .toLowerCase()
        .trim()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
  }

  bool _isRoadDamage(String type) {
    const types = {
      'lubang',
      'pothole',
      'jalan_rusak',
      'kerusakan_jalan',
      'retak',
      'retak_jalan',
      'cracking',
      'alligator_cracking',
      'edge_cracking',
      'longitudinal_cracking',
      'transverse_cracking',
      'rutting',
      'alur',
      'genangan',
      'banjir',
    };

    return types.contains(type);
  }

  bool _isLightingProblem(String type) {
    const types = {
      'lampu_mati',
      'lampu_jalan_mati',
      'penerangan_mati',
      'minim_penerangan',
      'jalan_gelap',
      'kurang_penerangan',
    };

    return types.contains(type);
  }

  /// 'damage', 'lighting', atau null (dipakai view untuk menggambar pin hazard).
  String? hazardKind(Map<String, dynamic> hazard) {
    final type = _normalizeHazardType(hazard);
    if (_isRoadDamage(type)) return 'damage';
    if (_isLightingProblem(type)) return 'lighting';
    return null;
  }

  String _hazardLabel(String type) {
    if (type == 'lubang' || type == 'pothole') return 'lubang';
    if (type == 'genangan' || type == 'banjir') return 'genangan air';
    if (_isLightingProblem(type)) return 'jalan gelap';
    if (type.contains('retak') || type.contains('crack')) return 'jalan retak';
    return 'jalan rusak';
  }

  double _roadDamageWeight(Map<String, dynamic> hazard) {
    final type = _normalizeHazardType(hazard);

    final severity = (hazard['severity'] ?? '').toString().toLowerCase().trim();

    if (type == 'lubang' || type == 'pothole') {
      if (severity == 'parah' || severity == 'berat') return 5;
      if (severity == 'sedang') return 3;
      return 2;
    }

    if (type == 'jalan_rusak' || type == 'kerusakan_jalan') {
      if (severity == 'parah' || severity == 'berat') return 5;
      return 3;
    }

    if (type == 'genangan' || type == 'banjir') {
      return severity == 'parah' ? 5 : 3;
    }

    if (severity == 'parah' || severity == 'berat') return 3;

    return 1;
  }

  double _lightingWeight() {
    return isNightMode.value ? 5 : 0.5;
  }

  void calculateRouteRisks() {
    routeRiskScores.clear();
    routeRiskLabels.clear();

    final relevantReports = hazardReports.where((hazard) {
      final type = _normalizeHazardType(hazard);
      return _isRoadDamage(type) || _isLightingProblem(type);
    }).toList();

    hasHazardData.value = relevantReports.isNotEmpty;

    if (routes.isEmpty) return;

    const pad = 0.0005; // ~55 m

    for (final route in routes) {
      double roadScore = 0;
      double lightingScore = 0;

      if (route.isNotEmpty) {
        var minLat = route.first.latitude;
        var maxLat = route.first.latitude;
        var minLon = route.first.longitude;
        var maxLon = route.first.longitude;
        for (final p in route) {
          if (p.latitude < minLat) minLat = p.latitude;
          if (p.latitude > maxLat) maxLat = p.latitude;
          if (p.longitude < minLon) minLon = p.longitude;
          if (p.longitude > maxLon) maxLon = p.longitude;
        }

        for (final hazard in relevantReports) {
          final latitude = hazard['latitude'];
          final longitude = hazard['longitude'];

          if (latitude is! num || longitude is! num) continue;

          final lat = latitude.toDouble();
          final lon = longitude.toDouble();

          if (lat < minLat - pad ||
              lat > maxLat + pad ||
              lon < minLon - pad ||
              lon > maxLon + pad) {
            continue;
          }

          final hazardPoint = LatLng(lat, lon);

          double nearestDistance = double.infinity;

          for (int i = 0; i < route.length - 1; i++) {
            final distance = _distanceToSegmentMeters(
              hazardPoint,
              route[i],
              route[i + 1],
            );

            if (distance < nearestDistance) {
              nearestDistance = distance;
            }
          }

          if (route.length == 1) {
            nearestDistance = Geolocator.distanceBetween(
              hazardPoint.latitude,
              hazardPoint.longitude,
              route.first.latitude,
              route.first.longitude,
            );
          }

          if (nearestDistance > 30) continue;

          final type = _normalizeHazardType(hazard);

          if (_isRoadDamage(type)) {
            roadScore += _roadDamageWeight(hazard);
          } else if (_isLightingProblem(type)) {
            lightingScore += _lightingWeight();
          }
        }
      }

      double combinationScore = 0;

      if (roadScore > 0 && lightingScore > 0) {
        combinationScore = isNightMode.value ? 3 : 0.5;
      }

      final totalScore = roadScore + lightingScore + combinationScore;
      routeRiskScores.add(totalScore);

      if (totalScore == 0) {
        routeRiskLabels.add('Risiko rendah');
      } else if (isNightMode.value && totalScore >= 12) {
        routeRiskLabels.add('Risiko sangat tinggi');
      } else if (totalScore >= 8) {
        routeRiskLabels.add('Risiko tinggi');
      } else if (totalScore >= 3) {
        routeRiskLabels.add('Risiko sedang');
      } else {
        routeRiskLabels.add('Risiko rendah');
      }
    }
  }

  double _distanceToSegmentMeters(LatLng point, LatLng start, LatLng end) {
    return _project(point, start, end).distance;
  }

  /// Proyeksi titik ke segmen (aproksimasi bidang datar, cukup akurat untuk jarak pendek).
  /// distance = jarak titik ke segmen (meter), t = posisi proyeksi pada segmen (0..1).
  _Proj _project(LatLng point, LatLng start, LatLng end) {
    const metersPerDegree = 111320.0;

    final latitudeRadians = point.latitude * math.pi / 180;
    final longitudeScale = metersPerDegree * math.cos(latitudeRadians);

    final px = point.longitude * longitudeScale;
    final py = point.latitude * metersPerDegree;

    final ax = start.longitude * longitudeScale;
    final ay = start.latitude * metersPerDegree;

    final bx = end.longitude * longitudeScale;
    final by = end.latitude * metersPerDegree;

    final dx = bx - ax;
    final dy = by - ay;

    final lengthSquared = dx * dx + dy * dy;

    if (lengthSquared == 0) {
      final ex = px - ax;
      final ey = py - ay;
      return _Proj(math.sqrt(ex * ex + ey * ey), 0);
    }

    final t = (((px - ax) * dx + (py - ay) * dy) / lengthSquared)
        .clamp(0.0, 1.0)
        .toDouble();

    final nearestX = ax + t * dx;
    final nearestY = ay + t * dy;

    final differenceX = px - nearestX;
    final differenceY = py - nearestY;

    return _Proj(
      math.sqrt(differenceX * differenceX + differenceY * differenceY),
      t,
    );
  }

  Color getRouteColor(int index) {
    if (!hasHazardData.value || index >= routeRiskScores.length) {
      return Colors.blueGrey;
    }

    final score = routeRiskScores[index];

    if (isNightMode.value && score >= 12) {
      return Colors.red.shade900;
    }

    if (score >= 8) return Colors.red;
    if (score >= 3) return Colors.orange;

    return Colors.green;
  }

  void setHazardReports(List<Map<String, dynamic>> reports) {
    hazardReports.assignAll(reports);
    calculateRouteRisks();
    if (isNavigating.value) _buildRouteHazards();
  }

  void changeRoute(int index) {
    if (isNavigating.value) {
      Get.snackbar(
        'Navigasi sedang berjalan',
        'Selesaikan navigasi sebelum mengganti rute.',
      );
      return;
    }

    if (index < 0 || index >= routes.length) return;

    selectedRoute.value = index;
    _fitSelectedRoute();
  }

  // SUARA
  Future<void> _configureTts() async {
    try {
      await _tts.setLanguage('id-ID');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {
      // Ketersediaan suara Indonesia mengikuti mesin TTS di perangkat.
    }
  }

  Future<void> speak(String message) async {
    if (!isSpeakingEnabled.value || message.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(message);
    } catch (_) {}
  }

  // NAVIGASI
  void _buildCumulative(List<LatLng> route) {
    _cumDist = List<double>.filled(route.length, 0.0);
    for (var i = 1; i < route.length; i++) {
      _cumDist[i] =
          _cumDist[i - 1] +
          Geolocator.distanceBetween(
            route[i - 1].latitude,
            route[i - 1].longitude,
            route[i].latitude,
            route[i].longitude,
          );
    }
  }

  int _nearestVertexFrom(List<LatLng> route, LatLng p, int from) {
    var best = from;
    var bestDistance = double.infinity;
    for (var i = from; i < route.length; i++) {
      final d = Geolocator.distanceBetween(
        p.latitude,
        p.longitude,
        route[i].latitude,
        route[i].longitude,
      );
      if (d < bestDistance) {
        bestDistance = d;
        best = i;
      }
    }
    return best;
  }

  void _computeStepIndexes(List<LatLng> route) {
    _stepRouteIndex = [];
    var from = 0;
    for (final step in navigationSteps) {
      final idx = _nearestVertexFrom(route, step.location, from);
      _stepRouteIndex.add(idx);
      from = idx;
    }
  }

  void _buildRouteHazards() {
    _routeHazards.clear();

    if (routes.isEmpty || selectedRoute.value >= routes.length) return;
    final route = routes[selectedRoute.value];
    if (route.length < 2 || _cumDist.length != route.length) return;

    var minLat = route.first.latitude;
    var maxLat = route.first.latitude;
    var minLon = route.first.longitude;
    var maxLon = route.first.longitude;
    for (final p in route) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLon) minLon = p.longitude;
      if (p.longitude > maxLon) maxLon = p.longitude;
    }
    const pad = 0.0005;

    for (final hazard in hazardReports) {
      final type = _normalizeHazardType(hazard);
      if (!(_isRoadDamage(type) || _isLightingProblem(type))) continue;

      final latitude = hazard['latitude'];
      final longitude = hazard['longitude'];
      if (latitude is! num || longitude is! num) continue;

      final lat = latitude.toDouble();
      final lon = longitude.toDouble();
      if (lat < minLat - pad ||
          lat > maxLat + pad ||
          lon < minLon - pad ||
          lon > maxLon + pad) {
        continue;
      }

      final point = LatLng(lat, lon);
      var bestDistance = double.infinity;
      var bestIndex = 0;
      var bestT = 0.0;

      for (var i = 0; i < route.length - 1; i++) {
        final proj = _project(point, route[i], route[i + 1]);
        if (proj.distance < bestDistance) {
          bestDistance = proj.distance;
          bestIndex = i;
          bestT = proj.t;
        }
      }

      if (bestDistance > 25) continue;

      final along =
          _cumDist[bestIndex] +
          bestT * (_cumDist[bestIndex + 1] - _cumDist[bestIndex]);
      _routeHazards.add(_RouteHazard(type, along));
    }

    _routeHazards.sort((a, b) => a.along.compareTo(b.along));
  }

  /// Dipakai saat mulai navigasi dan saat reroute.
  void _prepareNavigationRoute() {
    final route = routes[selectedRoute.value];

    navigationSteps.assignAll(_routeNavigationSteps[selectedRoute.value]);
    currentStepIndex.value = 0;
    distanceToNextStep.value = 0;
    _announcedStage.clear();
    _progressPointIndex = 0;
    _alongMeters = 0;
    _offRouteCount = 0;

    _buildCumulative(route);
    _routeTotalDistance = _cumDist.isEmpty ? 0 : _cumDist.last;
    _routeTotalDuration = selectedRoute.value < _routeDurationMinutes.length
        ? _routeDurationMinutes[selectedRoute.value]
        : 0;
    remainingDuration.value = _routeTotalDuration;
    distanceToDestination.value = _routeTotalDistance;
    remainingRoute.assignAll(route);

    _computeStepIndexes(route);
    _buildRouteHazards();
  }

  Future<void> startNavigation() async {
    if (destination.value == null || routes.isEmpty) {
      Get.snackbar('Rute belum tersedia', 'Pilih tujuan terlebih dahulu.');
      return;
    }
    if (selectedRoute.value >= _routeNavigationSteps.length ||
        _routeNavigationSteps[selectedRoute.value].isEmpty) {
      Get.snackbar(
        'Instruksi belum tersedia',
        'Muat ulang rute sebelum navigasi.',
      );
      return;
    }
    if (!await _checkLocationPermission()) return;

    try {
      await _positionSubscription?.cancel();
      await _tts.stop();

      _lastValidSpeed = 0;
      _lastHazardSpeak = DateTime.fromMillisecondsSinceEpoch(0);
      _lastTurnSpeak = DateTime.fromMillisecondsSinceEpoch(0);
      _prepareNavigationRoute();
      isNavigating.value = true;

      final LocationSettings settings;
      if (defaultTargetPlatform == TargetPlatform.android) {
        settings = AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
          // Tanpa ini, update GPS bisa hanya tiap beberapa detik.
          intervalDuration: const Duration(seconds: 1),
          forceLocationManager: false,
        );
      } else {
        settings = const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        );
      }

      _positionSubscription =
          Geolocator.getPositionStream(locationSettings: settings).listen(
            _handleNavigationPosition,
            onError: (error) {
              Get.snackbar(
                'GPS bermasalah',
                'Gagal memperbarui lokasi: $error',
              );
              stopNavigation();
            },
          );
      final current = currentLocation.value;
      if (mapReady && current != null) mapController.move(current, 17);
      await speak('Navigasi dimulai. Ikuti petunjuk Saferuas.');
      Get.snackbar('Navigasi dimulai', 'GPS aktif. Ikuti petunjuk arah.');
    } catch (e) {
      isNavigating.value = false;
      Get.snackbar('Gagal memulai navigasi', e.toString());
    }
  }

  void _handleNavigationPosition(Position position) {
    if (!isNavigating.value) return;
    // Abaikan fix GPS yang sangat buruk agar marker tidak melompat jauh.
    if (position.accuracy > 50) return;

    final location = LatLng(position.latitude, position.longitude);
    currentLocation.value = location;
    gpsAccuracy.value = position.accuracy;

    if (position.heading >= 0 &&
        position.heading.isFinite &&
        (position.speed > 1.0 || position.heading != 0)) {
      vehicleHeading.value = position.heading;
    }

    if (position.speed.isFinite &&
        position.speed >= 0 &&
        position.accuracy <= 25) {
      _lastValidSpeed = position.speed;
    }

    if (mapReady) {
      try {
        mapController.move(
          location,
          mapController.camera.zoom < 16 ? 17 : mapController.camera.zoom,
        );
      } catch (_) {}
    }

    final target = destination.value;
    if (target == null) return;

    final onRoute = _updateRouteProgress(location);

    final remaining = math.max(0.0, _routeTotalDistance - _alongMeters);
    distanceToDestination.value = remaining;

    // Estimasi waktu konservatif minimal 25 km/jam (asumsi aplikasi, bukan data lalu lintas).
    if (_routeTotalDistance > 0 && _routeTotalDuration > 0) {
      final ratio = (remaining / _routeTotalDistance)
          .clamp(0.0, 1.0)
          .toDouble();
      final routeMinutes = _routeTotalDuration * ratio;
      const conservativeSpeedKmh = 25.0;
      final conservativeMinutes =
          (remaining / 1000) / conservativeSpeedKmh * 60;
      remainingDuration.value = math.max(routeMinutes, conservativeMinutes);
    }

    if (onRoute) {
      _updateNavigationProgress();
      _checkHazardWarnings();
    } else if (_offRouteCount >= 3) {
      _reroute(location);
    }

    final directDistance = Geolocator.distanceBetween(
      location.latitude,
      location.longitude,
      target.latitude,
      target.longitude,
    );

    final arrivedByRoute =
        _routeTotalDistance > 0 &&
        onRoute &&
        remaining <= 20 &&
        directDistance <= 60;
    final arrivedByGps = directDistance <= 18 && position.accuracy <= 20;

    if (arrivedByRoute || arrivedByGps) {
      finishNavigation();
    }
  }

  /// Mencocokkan posisi GPS ke segmen rute terdekat (bukan titik terdekat).
  bool _updateRouteProgress(LatLng location) {
    if (routes.isEmpty || selectedRoute.value >= routes.length) return true;
    final route = routes[selectedRoute.value];
    if (route.length < 2 || _cumDist.length != route.length) return true;

    var bestIndex = _progressPointIndex;
    var bestDistance = double.infinity;
    var bestT = 0.0;
    final end = math.min(route.length - 2, _progressPointIndex + 200);

    for (var i = _progressPointIndex; i <= end; i++) {
      final proj = _project(location, route[i], route[i + 1]);
      if (proj.distance < bestDistance) {
        bestDistance = proj.distance;
        bestIndex = i;
        bestT = proj.t;
      }
    }

    if (bestDistance <= 40) {
      _progressPointIndex = bestIndex;
      _alongMeters =
          _cumDist[bestIndex] +
          bestT * (_cumDist[bestIndex + 1] - _cumDist[bestIndex]);
      _offRouteCount = 0;
      remainingRoute.assignAll([location, ...route.sublist(bestIndex + 1)]);
      return true;
    }

    _offRouteCount++;
    return false;
  }

  Future<void> _reroute(LatLng from) async {
    final target = destination.value;
    if (target == null || _isRerouting) return;
    if (DateTime.now().difference(_lastReroute).inSeconds < 10) return;

    _isRerouting = true;
    _lastReroute = DateTime.now();

    try {
      speak('Mencari rute baru');
      final parsed = await _requestRoutes(from, target, alternatives: false);
      if (!isNavigating.value || parsed.isEmpty) return;

      _applyParsedRoutes(parsed);
      _prepareNavigationRoute();
      calculateRouteRisks();
      speak('Rute baru ditemukan. Ikuti petunjuk.');
    } catch (e) {
      Get.snackbar('Gagal mencari rute baru', e.toString());
    } finally {
      _isRerouting = false;
    }
  }

  void _updateNavigationProgress() {
    if (_isUpdatingProgress || navigationSteps.isEmpty) return;
    if (_stepRouteIndex.length != navigationSteps.length || _cumDist.isEmpty) {
      return;
    }

    _isUpdatingProgress = true;
    try {
      final last = navigationSteps.length - 1;

      while (true) {
        final k = currentStepIndex.value;
        if (k >= _stepRouteIndex.length) break;

        final toManeuver = _cumDist[_stepRouteIndex[k]] - _alongMeters;

        // Langkah dianggap selesai bila belokan sudah dekat atau terlewati.
        if (toManeuver <= 12 && k < last) {
          currentStepIndex.value = k + 1;
          continue;
        }

        distanceToNextStep.value = math.max(0.0, toManeuver);
        _announceStep(k, toManeuver);
        break;
      }
    } finally {
      _isUpdatingProgress = false;
    }
  }

  // Tiga tahap pengumuman, jaraknya melebar mengikuti kecepatan
  void _announceStep(int k, double remaining) {
    final step = navigationSteps[k];
    final speed = _lastValidSpeed;

    final farAt = math.max(400.0, speed * 30);
    final midAt = math.max(150.0, speed * 12);
    final nearAt = math.max(40.0, speed * 4);

    final int stage;
    if (remaining <= nearAt) {
      stage = 3;
    } else if (remaining <= midAt) {
      stage = 2;
    } else if (remaining <= farAt) {
      stage = 1;
    } else {
      return;
    }

    if (stage <= (_announcedStage[k] ?? 0)) return;
    _announcedStage[k] = stage;
    _lastTurnSpeak = DateTime.now();

    speak(
      stage == 3
          ? _nearText(step)
          : 'Dalam ${_spokenDistance(remaining)}, '
                '${_lowerFirst(step.instruction)}',
    );
  }

  String _nearText(NavigationStep step) {
    if (step.maneuverType == 'arrive') return 'Tujuan Anda sudah dekat';

    const turning = {'turn', 'fork', 'end of road'};
    if (turning.contains(step.maneuverType) && step.modifier.isNotEmpty) {
      return '${_turnText(step.modifier)} sekarang';
    }
    return step.instruction;
  }

  String _spokenDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} kilometer';
    }
    final unit = meters >= 200 ? 50 : 10;
    final rounded = math.max(10, (meters / unit).round() * unit);
    return '$rounded meter';
  }

  String _lowerFirst(String text) =>
      text.isEmpty ? text : text[0].toLowerCase() + text.substring(1);

  void _checkHazardWarnings() {
    if (_routeHazards.isEmpty) return;

    final warnDistance = math.max(120.0, _lastValidSpeed * 8);

    for (final h in _routeHazards) {
      if (h.warned) continue;

      final ahead = h.along - _alongMeters;

      if (ahead < -20) {
        h.warned = true;
        continue;
      }
      // Daftar terurut, jadi sisanya pasti lebih jauh lagi.
      if (ahead > warnDistance) break;
      if (ahead < 0) continue;

      if (_isLightingProblem(h.type) && !isNightMode.value) {
        h.warned = true;
        continue;
      }

      // Tahan peringatan supaya tidak memotong pengumuman belokan
      final now = DateTime.now();
      if (now.difference(_lastHazardSpeak).inSeconds < 6) break;
      if (now.difference(_lastTurnSpeak).inSeconds < 5) break;
      if (distanceToNextStep.value < 100) break;

      h.warned = true;
      _lastHazardSpeak = now;

      final label = _hazardLabel(h.type);
      final meters = (ahead / 10).round() * 10;
      speak(
        meters <= 20
            ? 'Hati-hati, ada $label tepat di depan'
            : 'Hati-hati, ada $label sekitar $meters meter di depan',
      );
      break;
    }
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.round()} m';
  }

  void stopNavigation() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _tts.stop();
    isNavigating.value = false;
    navigationSteps.clear();
    remainingRoute.clear();
    _routeHazards.clear();
    _announcedStage.clear();
    currentStepIndex.value = 0;
    distanceToNextStep.value = 0;
    if (currentLocation.value != null && mapReady) {
      mapController.move(currentLocation.value!, 15);
    }
  }

  void finishNavigation() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _tts.stop();
    isNavigating.value = false;
    navigationSteps.clear();
    remainingRoute.clear();
    _routeHazards.clear();
    _announcedStage.clear();
    currentStepIndex.value = 0;
    speak('Anda telah tiba di tujuan.');
    Get.snackbar(
      'Kamu sudah sampai!',
      'Perjalanan menuju ${destinationName.value} selesai.',
      duration: const Duration(seconds: 4),
    );
  }

  void _fitSelectedRoute() {
    if (!mapReady || routes.isEmpty) return;

    final selectedPoints = routes[selectedRoute.value];

    mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: selectedPoints,
        padding: const EdgeInsets.fromLTRB(45, 230, 45, 270),
      ),
    );
  }

  void zoomMap(double amount) {
    if (!mapReady) return;

    final camera = mapController.camera;
    final newZoom = (camera.zoom + amount).clamp(4.0, 19.0);

    mapController.move(camera.center, newZoom);
  }

  void clearDestination() {
    if (isNavigating.value) {
      stopNavigation();
    }

    destination.value = null;
    destinationName.value = '';

    searchController.clear();
    searchResults.clear();

    routes.clear();
    routeDistances.clear();
    routeDurations.clear();
    _routeDurationMinutes.clear();
    routeRiskScores.clear();
    routeRiskLabels.clear();
    _routeNavigationSteps.clear();

    selectedRoute.value = 0;

    hasHazardData.value = hazardReports.any((hazard) {
      final type = _normalizeHazardType(hazard);
      return _isRoadDamage(type) || _isLightingProblem(type);
    });

    if (currentLocation.value != null && mapReady) {
      mapController.move(currentLocation.value!, 15);
    }
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    _positionSubscription?.cancel();
    _tts.stop();
    searchController.dispose();
    super.onClose();
  }
}
