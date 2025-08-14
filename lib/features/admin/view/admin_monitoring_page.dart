import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:jabar_caang/features/admin/viewmodel/admin_monitoring_viewmodel.dart';
import 'package:provider/provider.dart';

class AdminMonitoringPage extends StatefulWidget {
  const AdminMonitoringPage({super.key});

  @override
  State<AdminMonitoringPage> createState() => _AdminMonitoringPageState();
}

class _AdminMonitoringPageState extends State<AdminMonitoringPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Color _getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return const Color(0xFFFF6B6B);
      case 'selesai':
        return const Color(0xFF4ECDC4);
      case 'ditolak':
        return const Color(0xFFFA8072);
      case 'baru':
        return const Color(0xFF45B7D1);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  LinearGradient _getGradientForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'selesai':
        return const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF6FE6DD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'ditolak':
        return const LinearGradient(
          colors: [Color(0xFFFA8072), Color(0xFFFFB4A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'baru':
        return const LinearGradient(
          colors: [Color(0xFF45B7D1), Color(0xFF6CC5E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF95A5A6), Color(0xFFB8C4C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
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

  IconData _getIconForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Icons.hourglass_empty_rounded;
      case 'selesai':
        return Icons.check_circle_rounded;
      case 'ditolak':
        return Icons.cancel_rounded;
      case 'baru':
        return Icons.fiber_new_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminMonitoringViewModel(),
      child: Consumer<AdminMonitoringViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Memuat Data...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: FloatingActionButton(
              onPressed: () => vm.refreshData(),
              backgroundColor: const Color(0xFF667eea),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.refresh, color: Colors.white, size: 28),
              ),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                ),
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: RefreshIndicator(
                    onRefresh: () => vm.refreshData(),
                    backgroundColor: Colors.white,
                    color: const Color(0xFF667eea),
                    child: Column(
                      children: [
                        _buildModernHeader(context, vm),
                        _buildFilterChips(context, vm),
                        _buildStatsCards(context, vm),
                        _buildInteractiveMap(context, vm),
                        _buildModernAduanList(context, vm),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, AdminMonitoringViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitoring Dashboard',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Lacak aduan secara real-time',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, AdminMonitoringViewModel vm) {
    final stats = _calculateStats(vm.filteredAduan);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              stats['total'].toString(),
              Icons.inventory_2_rounded,
              const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
              index: 0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Baru',
              stats['baru'].toString(),
              Icons.fiber_new_rounded,
              const LinearGradient(colors: [Color(0xFF45B7D1), Color(0xFF6CC5E0)]),
              index: 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Selesai',
              stats['selesai'].toString(),
              Icons.check_circle_rounded,
              const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF6FE6DD)]),
              index: 2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Diproses',
              stats['diproses'].toString(),
              Icons.hourglass_empty_rounded,
              const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)]),
              index: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      IconData icon,
      LinearGradient gradient, {
        required int index,
      }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTap: () => Provider.of<AdminMonitoringViewModel>(context, listen: false)
            .changeStatusFilter(label == 'Total' ? 'Semua' : label),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, int> _calculateStats(List<QueryDocumentSnapshot<Object?>> aduan) {
    final stats = {
      'total': aduan.length,
      'baru': 0,
      'diproses': 0,
      'selesai': 0,
      'ditolak': 0,
    };

    for (final doc in aduan) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        final status = (data['status']?.toString().toLowerCase() ?? 'baru');
        if (stats.containsKey(status)) {
          stats[status] = stats[status]! + 1;
        }
      }
    }

    return stats;
  }

  Widget _buildFilterChips(BuildContext context, AdminMonitoringViewModel vm) {
    final filters = ['Semua', 'Baru', 'Diproses', 'Selesai', 'Ditolak'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: filters.map((filter) {
          final isSelected = vm.selectedStatusFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => vm.changeStatusFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  )
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : null,
                ),
                child: Text(
                  filter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInteractiveMap(BuildContext context, AdminMonitoringViewModel vm) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(-6.9175, 107.6191),
                initialZoom: 9.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: vm.filteredAduan.map((aduanDoc) {
                    final aduanData = aduanDoc.data() as Map<String, dynamic>?;
                    if (aduanData == null) return null;
                    final GeoPoint? lokasi = aduanData['lokasi'];
                    if (lokasi == null) return null;

                    final status = aduanData['status']?.toString() ?? 'baru';
                    final displayStatus = _getDisplayStatus(status);

                    return Marker(
                      width: 40.0,
                      height: 40.0,
                      point: LatLng(lokasi.latitude, lokasi.longitude),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Navigasi ke halaman detail aduan
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: _getGradientForStatus(status),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getColorForStatus(status).withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Tooltip(
                            message:
                            'Status: $displayStatus\nDesa: ${aduanData['desa'] ?? 'Unknown'}\nPelapor: ${aduanData['nama'] ?? 'Unknown'}',
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).where((marker) => marker != null).cast<Marker>().toList(),
                ),
              ],
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Peta Interaktif',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAduanList(BuildContext context, AdminMonitoringViewModel vm) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[50]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.list_alt_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Aduan',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          '${vm.filteredAduan.length} aduan dengan status: ${vm.selectedStatusFilter}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: vm.filteredAduan.isEmpty
                  ? _buildEmptyState(context, vm)
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vm.filteredAduan.length,
                itemBuilder: (context, index) {
                  final aduanData = vm.filteredAduan[index].data() as Map<String, dynamic>?;
                  if (aduanData == null) return const SizedBox.shrink();

                  final status = aduanData['status']?.toString() ?? 'baru';
                  final displayStatus = _getDisplayStatus(status);

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getColorForStatus(status).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getColorForStatus(status).withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: _getGradientForStatus(status),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getIconForStatus(status),
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  aduanData['keterangan'] ?? 'Tidak ada keterangan',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF2D3748),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: _getGradientForStatus(status),
                                  borderRadius: BorderRadius.circular(15),
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
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_rounded,
                                      color: Colors.grey[600],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pelapor: ${aduanData['nama'] ?? 'Tidak diketahui'}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.grey[600],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Desa: ${aduanData['desa'] ?? 'Tidak diketahui'}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AdminMonitoringViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[100]!, Colors.grey[50]!],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada aduan',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada aduan dengan status "${vm.selectedStatusFilter}"',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}