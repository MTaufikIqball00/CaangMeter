import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jabar_caang/data/models/rasio_desa_model.dart';
import 'package:jabar_caang/data/repositories/monitoring_repository.dart';
import 'package:jabar_caang/features/admin/repository/admin_repository.dart';
import 'package:jabar_caang/data/repositories/aduan_repository.dart';
import 'package:jabar_caang/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class AduanMapWidget extends StatefulWidget {
  const AduanMapWidget({super.key});

  @override
  State<AduanMapWidget> createState() => _AduanMapWidgetState();
}

class _AduanMapWidgetState extends State<AduanMapWidget> {
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final isAdmin = authViewModel.isAdmin;

    final aduanFuture = isAdmin
      ? AdminRepository().getAllAduanFuture()
      : AduanRepository().getAduanFuture();

    final desaFuture = MonitoringRepository().getDummyRasioData();

    setState(() {
      _dataFuture = Future.wait([aduanFuture, desaFuture]);
    });
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'diproses':
        return Colors.yellow;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Gagal memuat data: ${snapshot.error}'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                )
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Tidak ada data.'));
        }

        final aduanDocs = snapshot.data![0] as List<DocumentSnapshot>;
        final desaList = snapshot.data![1] as List<RasioDesaModel>;
        final isAdmin = context.watch<AuthViewModel>().isAdmin;

        final villageMarkers = desaList.map((desa) {
          return Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(desa.latitude, desa.longitude),
            child: Tooltip(
              message: 'Desa: ${desa.namaDesa}',
              child: Icon(Icons.location_on, color: Colors.purple, size: 30),
            ),
          );
        }).toList();

        final aduanMarkers = aduanDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return null;
          final lokasi = data['lokasi'] as GeoPoint?;
          if (lokasi == null) return null;
          final status = data['status'] as String? ?? 'baru';
          final color = isAdmin ? _getColorForStatus(status) : Colors.blue;

          return Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(lokasi.latitude, lokasi.longitude),
            child: Tooltip(
              message: "Status: $status",
              child: Icon(Icons.location_pin, color: color, size: 40),
            ),
          );
        }).whereType<Marker>().toList();

        return Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(-6.9175, 107.6191),
                initialZoom: 9.2,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [...villageMarkers, ...aduanMarkers],
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: FloatingActionButton(
                onPressed: _loadData,
                backgroundColor: Colors.white,
                mini: true,
                child: const Icon(Icons.refresh, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}

