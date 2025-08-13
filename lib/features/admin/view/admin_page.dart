import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jabar_caang/features/admin/view/admin_monitoring_page.dart';
import 'package:jabar_caang/features/admin/viewmodel/admin_viewmodel.dart';
import 'package:jabar_caang/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:jabar_caang/features/profile/view/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminViewModel(),
      child: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) return;

          final now = DateTime.now();
          final isExiting =
              lastPressed != null && now.difference(lastPressed!).inSeconds < 2;

          if (isExiting) {
            if (context.mounted) Navigator.of(context).pop();
          } else {
            lastPressed = now;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tekan sekali lagi untuk keluar'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard Admin'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: () async {
                    final authViewModel =
                    Provider.of<AuthViewModel>(context, listen: false);
                    await authViewModel.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.list_alt), text: 'Daftar Aduan'),
                  Tab(icon: Icon(Icons.analytics), text: 'Monitoring & Analisis'),
                  Tab(icon: Icon(Icons.person), text: 'Profil'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildAduanList(),
                const AdminMonitoringPage(),
                const ProfilePage(role: 'admin'), // Profil admin, desain sama seperti user
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAduanList() {
    return Consumer<AdminViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.aduanList.isEmpty) {
          return const Center(child: Text('Belum ada aduan masuk.'));
        }
        return RefreshIndicator(
          onRefresh: () => vm.fetchAduan(),
          child: ListView.builder(
            itemCount: vm.aduanList.length,
            itemBuilder: (context, index) {
              final aduanDoc = vm.aduanList[index];
              final aduanData = aduanDoc.data() as Map<String, dynamic>;
              final aduanId = aduanDoc.id;
              return _buildAduanCard(context, aduanId, aduanData, vm);
            },
          ),
        );
      },
    );
  }

  Widget _buildAduanCard(
      BuildContext context,
      String aduanId,
      Map<String, dynamic> data,
      AdminViewModel vm,
      ) {
    final status = data['status'] ?? 'baru';
    final timestamp = (data['timestamp'] as Timestamp).toDate();
    final formattedDate = DateFormat('d MMM yyyy, HH:mm').format(timestamp);

    final lokasi = data['lokasi'] as GeoPoint?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Desa: ${data['desa']}',
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Pelapor: ${data['nama']} (${data['hp']})'),
            const Divider(height: 20),
            Text('Keterangan: ${data['keterangan']}'),
            const SizedBox(height: 8),
            Text('Waktu: $formattedDate',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            if (lokasi != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Koordinat: ${lokasi.latitude.toStringAsFixed(5)}, ${lokasi.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    tooltip: 'Buka di Peta',
                    onPressed: () async {
                      final url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${lokasi.latitude},${lokasi.longitude}');
                      final canLaunch = await canLaunchUrl(url);

                      if (!context.mounted) return;

                      if (canLaunch) {
                        await launchUrl(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tidak bisa membuka peta.')),
                        );
                      }
                    },
                  )
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(
                  label: 'Proses',
                  icon: Icons.sync,
                  color: Colors.orange,
                  onPressed: () => vm.updateStatus(aduanId, 'diproses'),
                ),
                const SizedBox(width: 8),
                _actionButton(
                  label: 'Selesai',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  onPressed: () => vm.updateStatus(aduanId, 'selesai'),
                ),
                const SizedBox(width: 8),
                _actionButton(
                  label: 'Tolak',
                  icon: Icons.cancel,
                  color: Colors.red,
                  onPressed: () => vm.updateStatus(aduanId, 'ditolak'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String label;
    switch (status) {
      case 'diproses':
        chipColor = Colors.orange;
        label = 'Diproses';
        break;
      case 'selesai':
        chipColor = Colors.green;
        label = 'Selesai';
        break;
      case 'ditolak':
        chipColor = Colors.red;
        label = 'Ditolak';
        break;
      default:
        chipColor = Colors.blue;
        label = 'Baru';
    }
    return Chip(
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color),
        ),
      ),
    );
  }
}
