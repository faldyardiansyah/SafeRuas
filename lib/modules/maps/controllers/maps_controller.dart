import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

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

  // Navigasi aktif
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
  final Set<int> _spokenApproachSteps = <int>{};
  double _routeTotalDistance = 0;
  double _routeTotalDuration = 0;
  int _progressPointIndex = 0;
  int _offRouteCount = 0;
  double _lastValidSpeed = 0;
  DateTime _lastSpeedUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  LatLng? _lastRawGpsLocation;

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

    if (currentLocation.value != null) {
      mapController.move(currentLocation.value!, 15);
    }
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

      final coordinates =
          '${origin.longitude},${origin.latitude};'
          '${target.longitude},${target.latitude}';

      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '$coordinates'
        '?alternatives=true'
        '&overview=full'
        '&geometries=geojson'
        '&steps=true',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Tidak dapat mengambil rute.');
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 'Ok' || (data['routes'] as List).isEmpty) {
        throw Exception('Rute perjalanan tidak ditemukan.');
      }

      final List routeData = data['routes'];

      for (final route in routeData) {
        final coordinates = route['geometry']['coordinates'] as List;

        final points = coordinates.map<LatLng>((coordinate) {
          return LatLng(
            (coordinate[1] as num).toDouble(),
            (coordinate[0] as num).toDouble(),
          );
        }).toList();

        routes.add(points);

        final distance = (route['distance'] as num).toDouble() / 1000;
        final duration = (route['duration'] as num).toDouble() / 60;

        routeDistances.add('${distance.toStringAsFixed(1)} km');
        routeDurations.add('${duration.round()} menit');
        _routeDurationMinutes.add(duration);

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

        _routeNavigationSteps.add(steps);
      }

      selectedRoute.value = 0;
      if (routeData.isNotEmpty) {
        _routeTotalDistance = (routeData[0]['distance'] as num).toDouble();
        _routeTotalDuration = (routeData[0]['duration'] as num).toDouble() / 60;
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

    for (final route in routes) {
      double roadScore = 0;
      double lightingScore = 0;

      for (final hazard in relevantReports) {
        final latitude = hazard['latitude'];
        final longitude = hazard['longitude'];

        if (latitude is! num || longitude is! num) continue;

        final hazardPoint = LatLng(latitude.toDouble(), longitude.toDouble());

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
      return Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        start.latitude,
        start.longitude,
      );
    }

    final t = ((px - ax) * dx + (py - ay) * dy) / lengthSquared;
    final clampedT = t.clamp(0.0, 1.0);

    final nearestX = ax + clampedT * dx;
    final nearestY = ay + clampedT * dy;

    final differenceX = px - nearestX;
    final differenceY = py - nearestY;

    return math.sqrt(differenceX * differenceX + differenceY * differenceY);
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
      navigationSteps.assignAll(_routeNavigationSteps[selectedRoute.value]);
      currentStepIndex.value = 0;
      distanceToNextStep.value = 0;
      _spokenApproachSteps.clear();
      _progressPointIndex = 0;
      _lastValidSpeed = 0;
      _lastRawGpsLocation = null;
      _offRouteCount = 0;
      remainingRoute.assignAll(routes[selectedRoute.value]);
      _routeTotalDistance = _polylineLength(routes[selectedRoute.value]);
      _routeTotalDuration = selectedRoute.value < _routeDurationMinutes.length
          ? _routeDurationMinutes[selectedRoute.value]
          : 0;
      remainingDuration.value = _routeTotalDuration;
      isNavigating.value = true;

      final settings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        forceLocationManager: false,
      );
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
    // Ikuti setiap fix GPS yang valid; move() tidak menunggu animasi kamera.
    if (mapReady) {
      try {
        mapController.move(
          location,
          mapController.camera.zoom < 16 ? 17 : mapController.camera.zoom,
        );
      } catch (_) {}
    }
    if (position.speed.isFinite &&
        position.speed >= 0 &&
        position.accuracy <= 25) {
      _lastValidSpeed = position.speed;
      _lastSpeedUpdate = DateTime.now();
    }
    final target = destination.value;
    if (target == null) return;
    final directDistance = Geolocator.distanceBetween(
      location.latitude,
      location.longitude,
      target.latitude,
      target.longitude,
    );
    _updateRemainingRoute(location);
    final routeDistance = _polylineLength(remainingRoute);
    distanceToDestination.value = routeDistance > 0
        ? routeDistance
        : directDistance;
    // ETA dasar mengikuti durasi OSRM sesuai proporsi rute yang tersisa.
    // Untuk navigasi motor di jalan lokal, gunakan estimasi konservatif
    // minimal 25 km/jam agar ETA tidak terlalu optimistis. Ini asumsi
    // aplikasi, bukan data lalu lintas realtime.
    if (_routeTotalDistance > 0 && _routeTotalDuration > 0) {
      final remainingRatio = (distanceToDestination.value / _routeTotalDistance)
          .clamp(0.0, 1.0);
      final osrmMinutes = _routeTotalDuration * remainingRatio;
      const conservativeSpeedKmh = 25.0;
      final conservativeMinutes =
          (distanceToDestination.value / 1000) / conservativeSpeedKmh * 60;
      remainingDuration.value = math.max(osrmMinutes, conservativeMinutes);
    }
    _updateNavigationProgress(location);
    // Radius tiba dibuat lebih ketat; tetap mensyaratkan fix GPS yang layak.
    if (directDistance <= 18 && position.accuracy <= 20) {
      finishNavigation();
    }
  }

  void _updateRemainingRoute(LatLng location) {
    if (routes.isEmpty || selectedRoute.value >= routes.length) return;
    final route = routes[selectedRoute.value];
    if (route.length < 2) return;
    var bestIndex = _progressPointIndex.clamp(0, route.length - 1);
    var bestDistance = double.infinity;
    final end = math.min(route.length - 1, _progressPointIndex + 120);
    for (var i = _progressPointIndex; i <= end; i++) {
      final d = Geolocator.distanceBetween(
        location.latitude,
        location.longitude,
        route[i].latitude,
        route[i].longitude,
      );
      if (d < bestDistance) {
        bestDistance = d;
        bestIndex = i;
      }
    }
    if (bestDistance <= 45 && bestIndex >= _progressPointIndex) {
      // Hanya majukan progres ketika GPS cukup dekat dengan geometri rute.
      _progressPointIndex = bestIndex;
      final tail = route.skip(bestIndex + 1).toList();
      remainingRoute.assignAll([location, ...tail]);
      _offRouteCount = 0;
    } else {
      // Jangan menggeser titik progres saat GPS meleset; hindari garis rute terpotong.
      _offRouteCount++;
      remainingRoute.assignAll([
        route[_progressPointIndex],
        ...route.skip(_progressPointIndex + 1),
      ]);
    }
  }

  double _polylineLength(List<LatLng> points) {
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return total;
  }

  void _updateNavigationProgress(LatLng location) {
    if (_isUpdatingProgress || navigationSteps.isEmpty) return;
    _isUpdatingProgress = true;
    try {
      while (currentStepIndex.value < navigationSteps.length) {
        final index = currentStepIndex.value;
        final step = navigationSteps[index];
        final distance = Geolocator.distanceBetween(
          location.latitude,
          location.longitude,
          step.location.latitude,
          step.location.longitude,
        );
        distanceToNextStep.value = distance;
        if (distance <= 100 && !_spokenApproachSteps.contains(index)) {
          _spokenApproachSteps.add(index);
          speak(
            distance > 35
                ? 'Dalam sekitar ${distance.round()} meter, ${step.instruction}'
                : step.instruction,
          );
        }
        if (distance <= 22 && index < navigationSteps.length - 1) {
          currentStepIndex.value++;
          continue;
        }
        break;
      }
    } finally {
      _isUpdatingProgress = false;
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
