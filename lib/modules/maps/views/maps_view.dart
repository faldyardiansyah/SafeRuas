import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'package:saferuas/utils/app_colors.dart';

import '../controllers/maps_controller.dart';

class MapsView extends GetView<MapsController> {
  const MapsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          Positioned.fill(child: Obx(() => _buildMap())),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: Obx(
              () => controller.isNavigating.value
                  ? _buildNavigationHeader()
                  : _buildSearchPanel(),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 275 + bottomSafeArea,
            child: _buildMapControls(),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 100 + bottomSafeArea,
            child: _buildBottomPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: controller.mapController,
      options: MapOptions(
        initialCenter: const LatLng(-6.3265, 108.3200),
        initialZoom: 13,
        minZoom: 4,
        maxZoom: 19,
        onMapReady: controller.onMapReady,
        interactionOptions: const InteractionOptions(
          flags:
              InteractiveFlag.drag |
              InteractiveFlag.pinchMove |
              InteractiveFlag.pinchZoom |
              InteractiveFlag.doubleTapZoom |
              InteractiveFlag.scrollWheelZoom |
              InteractiveFlag.flingAnimation,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.saferuas.app',
        ),
        PolylineLayer(
          polylines: [
            if (controller.isNavigating.value &&
                controller.routeToDraw.length > 1)
              Polyline(
                points: controller.routeToDraw,
                strokeWidth: 7,
                color: AppColors.primaryDark,
              ),
            if (!controller.isNavigating.value)
              for (int i = 0; i < controller.routes.length; i++)
                Polyline(
                  points: controller.routes[i],
                  strokeWidth: controller.selectedRoute.value == i ? 7 : 5,
                  color: controller.getRouteColor(i),
                ),
          ],
        ),
        MarkerLayer(
          markers: [
            if (controller.currentLocation.value != null)
              Marker(
                point: controller.currentLocation.value!,
                width: 48,
                height: 48,
                child: controller.isNavigating.value
                    ? Transform.rotate(
                        angle: controller.vehicleHeading.value * math.pi / 180,
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: AppColors.error,
                          size: 43,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: .18),
                        ),
                        child: Center(
                          child: Container(
                            width: 17,
                            height: 17,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ),
              ),
            if (controller.destination.value != null)
              Marker(
                point: controller.destination.value!,
                width: 42,
                height: 48,
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.dangerRed,
                  size: 42,
                ),
              ),
          ],
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors', onTap: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SAFERUAS MAPS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Navigasi berdasarkan kondisi jalan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildWibClock(),
            ],
          ),
          const SizedBox(height: 8),
          _buildLocationInput(),
          Padding(
            padding: const EdgeInsets.only(left: 17),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 12,
                width: 1.5,
                color: AppColors.divider,
              ),
            ),
          ),
          TextField(
            controller: controller.searchController,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: AppColors.dangerRed,
                size: 21,
              ),
              hintText: 'Mau ke mana?',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
              suffixIcon: Obx(
                () => controller.destination.value != null
                    ? IconButton(
                        onPressed: controller.clearDestination,
                        icon: const Icon(Icons.close_rounded),
                      )
                    : IconButton(
                        onPressed: () {
                          controller.searchDestination(
                            controller.searchController.text,
                          );
                        },
                        icon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primaryDark,
                        ),
                      ),
              ),
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
            onSubmitted: controller.searchDestination,
          ),
          Obx(() {
            if (controller.isSearching.value) {
              return const Padding(
                padding: EdgeInsets.all(10),
                child: LinearProgressIndicator(),
              );
            }

            if (controller.searchResults.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              constraints: const BoxConstraints(maxHeight: 150),
              margin: const EdgeInsets.only(top: 8),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: controller.searchResults.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = controller.searchResults[index];

                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.place_outlined,
                      color: AppColors.primaryDark,
                    ),
                    title: Text(
                      item['name'].toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    onTap: () {
                      controller.selectDestination(item);
                    },
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWibClock() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              controller.currentWibTime.value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  controller.isNightMode.value
                      ? Icons.nightlight_round
                      : Icons.wb_sunny_rounded,
                  size: 11,
                  color: controller.isNightMode.value
                      ? AppColors.primaryDark
                      : AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  controller.timePeriod,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput() {
    return InkWell(
      onTap: controller.getCurrentLocation,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          const Icon(
            Icons.my_location_rounded,
            color: AppColors.primaryDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOKASI ANDA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                  ),
                ),
                Obx(
                  () => Text(
                    controller.currentLocation.value == null
                        ? 'Lokasi saat ini'
                        : 'Lokasi berhasil ditemukan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.isLoadingLocation.value
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.my_location_rounded,
                    color: AppColors.textMuted,
                    size: 17,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationHeader() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.13),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.navigation_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.currentInstruction,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dalam ${controller.nextStepDistanceText}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.navigation_outlined,
              color: AppColors.primaryDark,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Obx(
      () => Column(
        children: [
          _mapButton(
            icon: Icons.my_location_rounded,
            onTap: controller.isNavigating.value
                ? () {
                    final location = controller.currentLocation.value;
                    if (location != null) {
                      controller.mapController.move(location, 17);
                    }
                  }
                : controller.getCurrentLocation,
          ),
          const SizedBox(height: 9),
          _mapButton(
            icon: Icons.add_rounded,
            onTap: () => controller.zoomMap(1),
          ),
          const SizedBox(height: 7),
          _mapButton(
            icon: Icons.remove_rounded,
            onTap: () => controller.zoomMap(-1),
          ),
        ],
      ),
    );
  }

  Widget _mapButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 43,
          height: 43,
          child: Icon(icon, color: AppColors.textPrimary, size: 21),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Obx(() {
      if (controller.isNavigating.value) {
        return _buildActiveNavigationPanel();
      }

      final hasRoutes = controller.routes.isNotEmpty;

      return Container(
        constraints: const BoxConstraints(maxHeight: 225),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.13),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: AppColors.teal,
                    size: 20,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Pilihan perjalanan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    controller.isNightMode.value
                        ? 'Penilaian malam'
                        : 'Penilaian siang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                hasRoutes
                    ? 'Pilih rute perjalanan yang diinginkan.'
                    : 'Masukkan tujuan untuk melihat pilihan rute.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
              if (controller.isLoadingRoute.value) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(color: AppColors.primaryDark),
              ],
              if (hasRoutes) ...[
                const SizedBox(height: 7),
                for (int i = 0; i < controller.routes.length; i++)
                  _buildRouteOption(i),
                const SizedBox(height: 7),
                Text(
                  controller.hasHazardData.value
                      ? 'Risiko dihitung berdasarkan kerusakan jalan dan penerangan.'
                      : 'Belum ada data laporan bahaya yang terhubung.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    height: 1.3,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoadingRoute.value
                        ? null
                        : controller.startNavigation,
                    icon: const Icon(Icons.navigation_rounded),
                    label: const Text('Mulai Navigasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActiveNavigationPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded, color: AppColors.teal, size: 20),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Navigasi sedang berjalan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F7EF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'GPS AKTIF',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _navigationInfo(
                  'Jarak ke tujuan',
                  controller.destinationDistanceText,
                  Icons.location_on_outlined,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.divider),
              Expanded(
                child: _navigationInfo(
                  'Estimasi tiba',
                  controller.remainingTimeText,
                  Icons.schedule_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Suara petunjuk arah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Obx(
                () => Switch.adaptive(
                  value: controller.isSpeakingEnabled.value,
                  onChanged: (value) =>
                      controller.isSpeakingEnabled.value = value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.stopNavigation,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Selesai Navigasi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.dangerRed,
                side: const BorderSide(color: AppColors.dangerRed),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigationInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 20),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteOption(int index) {
    final isSelected = controller.selectedRoute.value == index;

    final riskLabel = index < controller.routeRiskLabels.length
        ? controller.routeRiskLabels[index]
        : 'Belum dinilai';

    return InkWell(
      onTap: () => controller.changeRoute(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF6FD) : const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primaryDark : AppColors.textMuted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    index == 0 ? 'Rute utama' : 'Rute alternatif ${index + 1}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${controller.routeDistances[index]} · ${controller.routeDurations[index]}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    controller.hasHazardData.value
                        ? riskLabel
                        : 'Belum ada data laporan bahaya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: controller.getRouteColor(index),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: controller.getRouteColor(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
