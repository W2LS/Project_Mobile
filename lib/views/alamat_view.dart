import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../controller/alamat_controller.dart';

class AlamatView extends StatelessWidget {
  const AlamatView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller sudah di-put permanen di main.dart, jadi Get.find() aman di sini.
    final AlamatController controller = Get.find<AlamatController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat Saya (Network Provider)'),
        backgroundColor: const Color(0xFF42A5F5),
        actions: [
          Obx(() => IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.isLoading.isTrue ? null : controller.fetchCurrentLocation,
            tooltip: 'Refresh Lokasi',
          )),
        ],
      ),

      body: Obx(() {
        final Position? currentPos = controller.currentPosition.value;
        final LatLng mapCenter = currentPos != null
            ? LatLng(currentPos.latitude, currentPos.longitude)
            : const LatLng(-6.2088, 106.8456);

        // --- Handling State: Loading, Error, or Success ---
        if (controller.isLoading.isTrue) {
          return const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Mendapatkan lokasi via Network Provider...')],
          ));
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(controller.errorMessage.value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: controller.openAppSettings,
                      child: const Text('Buka Pengaturan Aplikasi')
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: controller.mapController, // Menggunakan MapController yang sudah diinisialisasi
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 15.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.your.modul2_demo_revisi',
                  ),
                  MarkerLayer(
                    markers: [
                      if (currentPos != null)
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(currentPos.latitude, currentPos.longitude),
                          child: const Icon(Icons.location_on, color: Colors.blue, size: 40.0),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            _buildLocationInfoCard(currentPos),
          ],
        );
      }),
    );
  }

  Widget _buildLocationInfoCard(Position? pos) {
    if (pos == null) {
      return const Padding(padding: EdgeInsets.all(16.0), child: Text('Posisi belum tersedia.', style: TextStyle(color: Colors.grey)));
    }
    final String timestamp = DateFormat('dd-MM-yyyy HH:mm:ss').format(pos.timestamp!);
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detail Posisi (Network Provider)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            const Divider(),
            _buildDataRow('Latitude:', '${pos.latitude.toStringAsFixed(6)}'),
            _buildDataRow('Longitude:', '${pos.longitude.toStringAsFixed(6)}'),
            _buildDataRow('Akurasi (m):', '${pos.accuracy.toStringAsFixed(2)} m'),
            _buildDataRow('Timestamp:', timestamp),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}