import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// BARU: Import library yang benar
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Untuk object LatLng
// -- -
import 'package:jabar_caang/features/admin/viewmodel/admin_monitoring_viewmodel.dart';
import 'package:provider/provider.dart';

class AdminMonitoringPage extends StatelessWidget {
  const AdminMonitoringPage({super.key});

  Color _getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'baru':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      case 'baru':
        return 'Baru';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminMonitoringViewModel(),
      child: Consumer<AdminMonitoringViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => vm.refreshData(),
            child: Column(
              children: [
                _buildFilterChips(context, vm),
                // Debug info
                if (vm.filteredAduan.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.grey[100],
                    child: Text(
                      'Menampilkan ${vm.filteredAduan.length} aduan dengan status: ${vm.selectedStatusFilter}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                // Peta Interaktif menggunakan FlutterMap
                Expanded(
                  flex: 3,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(-6.9175, 107.6191),
                      initialZoom: 9.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: vm.filteredAduan.map((aduanDoc) {
                          final aduanData = aduanDoc.data() as Map<String, dynamic>;
                          final GeoPoint? lokasi = aduanData['lokasi'];

                          if (lokasi == null) {
                            return null;
                          }

                          final status = aduanData['status'] ?? 'baru';
                          final displayStatus = _getDisplayStatus(status);

                          return Marker(
                            width: 30.0,
                            height: 30.0,
                            point: LatLng(lokasi.latitude, lokasi.longitude),
                            child: Tooltip(
                              message: 'Status: $displayStatus\nDesa: ${aduanData['desa']}\nPelapor: ${aduanData['nama']}',
                              child: Icon(
                                Icons.location_on,
                                color: _getColorForStatus(status),
                                size: 30.0,
                              ),
                            ),
                          );
                        }).where((marker) => marker != null).cast<Marker>().toList(),
                      ),
                    ],
                  ),
                ),
                // Daftar Aduan yang sudah terfilter
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Aduan dengan status: ${vm.selectedStatusFilter}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: vm.filteredAduan.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada aduan dengan status "${vm.selectedStatusFilter}"',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                            : ListView.builder(
                          itemCount: vm.filteredAduan.length,
                          itemBuilder: (context, index) {
                            final aduanData = vm.filteredAduan[index]
                                .data() as Map<String, dynamic>;
                            final status = aduanData['status'] ?? 'baru';
                            final displayStatus = _getDisplayStatus(status);

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getColorForStatus(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: Text(
                                  'Ket: ${aduanData['keterangan']}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Pelapor: ${aduanData['nama']}'),
                                    Text('Desa: ${aduanData['desa']}'),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getColorForStatus(status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    displayStatus,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, AdminMonitoringViewModel vm) {
    final filters = ['Semua', 'Baru', 'Diproses', 'Selesai', 'Ditolak'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = vm.selectedStatusFilter == filter;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    vm.changeStatusFilter(filter);
                  }
                },
                selectedColor: Theme.of(context).primaryColor,
                checkmarkColor: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}