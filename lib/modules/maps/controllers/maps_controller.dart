import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapsController extends GetxController {
  final mapController = MapController();

  final isNightMode = false.obs;
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

  final hazardReports = <Map<String, dynamic>>[].obs;
  final routeRiskScores = <double>[].obs;
  final routeRiskLabels = <String>[].obs;
  final hasHazardData = false.obs;

  bool mapReady = false;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  void onMapReady() {
    mapReady = true;

    if (currentLocation.value != null) {
      mapController.move(currentLocation.value!, 15);
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoadingLocation.value = true;

      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        Get.snackbar(
          'Lokasi tidak aktif',
          'Aktifkan GPS perangkat untuk mendapatkan lokasi.',
        );
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Izin lokasi diperlukan',
          'Izinkan akses lokasi agar Saferuas dapat menunjukkan posisi kamu.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      currentLocation.value = location;

      if (mapReady) {
        mapController.move(location, 15);
      }

      if (destination.value != null) {
        await getRoutes();
      }
    } catch (e) {
      Get.snackbar(
        'Gagal mengambil lokasi',
        e.toString(),
      );
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> searchDestination(String query) async {
    if (query.trim().isEmpty) return;

    try {
      isSearching.value = true;
      searchResults.clear();

      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': query.trim(),
          'format': 'jsonv2',
          'limit': '5',
          'countrycodes': 'id',
        },
      );

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
        Get.snackbar(
          'Tidak ditemukan',
          'Lokasi yang dicari tidak ditemukan.',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Pencarian gagal',
        e.toString(),
      );
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> selectDestination(
    Map<String, dynamic> item,
  ) async {
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
      routeRiskScores.clear();
      routeRiskLabels.clear();

      final coordinates =
          '${origin.longitude},${origin.latitude};'
          '${target.longitude},${target.latitude}';

      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '$coordinates'
        '?alternatives=true'
        '&overview=full'
        '&geometries=geojson',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Tidak dapat mengambil rute.');
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 'Ok' ||
          (data['routes'] as List).isEmpty) {
        throw Exception('Rute perjalanan tidak ditemukan.');
      }

      final List routeData = data['routes'];

      for (final route in routeData) {
        final coordinates =
            route['geometry']['coordinates'] as List;

        final points = coordinates.map<LatLng>((coordinate) {
          return LatLng(
            (coordinate[1] as num).toDouble(),
            (coordinate[0] as num).toDouble(),
          );
        }).toList();

        routes.add(points);

        final distance =
            (route['distance'] as num).toDouble() / 1000;

        final duration =
            (route['duration'] as num).toDouble() / 60;

        routeDistances.add(
          '${distance.toStringAsFixed(1)} km',
        );

        routeDurations.add(
          '${duration.round()} menit',
        );
      }

      selectedRoute.value = 0;

      calculateRouteRisks();
      _fitSelectedRoute();
    } catch (e) {
      routes.clear();
      routeDistances.clear();
      routeDurations.clear();
      routeRiskScores.clear();
      routeRiskLabels.clear();

      Get.snackbar(
        'Rute gagal dimuat',
        e.toString(),
      );
    } finally {
      isLoadingRoute.value = false;
    }
  }

  void calculateRouteRisks() {
    routeRiskScores.clear();
    routeRiskLabels.clear();

    hasHazardData.value = hazardReports.isNotEmpty;

    if (routes.isEmpty) return;

    for (final route in routes) {
      double score = 0;

      if (hasHazardData.value) {
        for (final hazard in hazardReports) {
          final latitude = hazard['latitude'];
          final longitude = hazard['longitude'];

          if (latitude is! num || longitude is! num) {
            continue;
          }

          final hazardPoint = LatLng(
            latitude.toDouble(),
            longitude.toDouble(),
          );

          double nearestDistance = double.infinity;

          for (int i = 0; i < route.length - 1; i++) {
            final meters = _distanceToSegmentMeters(
              hazardPoint,
              route[i],
              route[i + 1],
            );

            if (meters < nearestDistance) {
              nearestDistance = meters;
            }
          }

          if (nearestDistance <= 30) {
            final type = hazard['type']?.toString() ?? '';
            final severity =
                hazard['severity']?.toString() ?? '';

            if (type == 'lubang' && severity == 'parah') {
              score += 5;
            } else if (type == 'lubang') {
              score += 3;
            } else if (type == 'jalan_rusak') {
              score += 3;
            } else if (type == 'lampu_mati') {
              score += isNightMode.value ? 5 : 2;
            } else {
              score += 1;
            }
          }
        }
      }

      routeRiskScores.add(score);

      if (!hasHazardData.value) {
        routeRiskLabels.add('Belum dinilai');
      } else if (score >= 8) {
        routeRiskLabels.add('Risiko tinggi');
      } else if (score >= 3) {
        routeRiskLabels.add('Risiko sedang');
      } else {
        routeRiskLabels.add('Risiko rendah');
      }
    }
  }

  double _distanceToSegmentMeters(
    LatLng point,
    LatLng start,
    LatLng end,
  ) {
    const metersPerDegree = 111320.0;

    final latitudeRadians =
        point.latitude * math.pi / 180;

    final longitudeScale =
        metersPerDegree * math.cos(latitudeRadians);

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

    final t = (
      (px - ax) * dx + (py - ay) * dy
    ) / lengthSquared;

    final clampedT = t.clamp(0.0, 1.0);

    final nearestX = ax + clampedT * dx;
    final nearestY = ay + clampedT * dy;

    final differenceX = px - nearestX;
    final differenceY = py - nearestY;

    return math.sqrt(
      differenceX * differenceX +
          differenceY * differenceY,
    );
  }

  Color getRouteColor(int index) {
    if (!hasHazardData.value ||
        index >= routeRiskScores.length) {
      return Colors.blueGrey;
    }

    final score = routeRiskScores[index];

    if (score >= 8) return Colors.red;
    if (score >= 3) return Colors.orange;

    return Colors.green;
  }

  void setHazardReports(
    List<Map<String, dynamic>> reports,
  ) {
    hazardReports.assignAll(reports);
    calculateRouteRisks();
  }

  void changeRoute(int index) {
    if (index < 0 || index >= routes.length) return;

    selectedRoute.value = index;
    _fitSelectedRoute();
  }

  void _fitSelectedRoute() {
    if (!mapReady || routes.isEmpty) return;

    final selectedPoints = routes[selectedRoute.value];

    mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: selectedPoints,
        padding: const EdgeInsets.fromLTRB(
          45,
          230,
          45,
          270,
        ),
      ),
    );
  }

  void zoomMap(double amount) {
    if (!mapReady) return;

    final camera = mapController.camera;

    final newZoom =
        (camera.zoom + amount).clamp(4.0, 19.0);

    mapController.move(
      camera.center,
      newZoom,
    );
  }

  void toggleMapMode() {
    isNightMode.toggle();
    calculateRouteRisks();
  }

  void clearDestination() {
    destination.value = null;
    destinationName.value = '';

    searchController.clear();
    searchResults.clear();

    routes.clear();
    routeDistances.clear();
    routeDurations.clear();
    routeRiskScores.clear();
    routeRiskLabels.clear();

    selectedRoute.value = 0;
    hasHazardData.value = hazardReports.isNotEmpty;

    if (currentLocation.value != null && mapReady) {
      mapController.move(
        currentLocation.value!,
        15,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}