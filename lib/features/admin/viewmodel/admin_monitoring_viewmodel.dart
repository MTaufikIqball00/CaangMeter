import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jabar_caang/data/models/rasio_desa_model.dart';
import 'package:jabar_caang/data/repositories/monitoring_repository.dart';
import 'package:jabar_caang/features/admin/repository/admin_repository.dart';

class AdminMonitoringViewModel extends ChangeNotifier {
  final MonitoringRepository _monitoringRepo = MonitoringRepository();
  final AdminRepository _adminRepo = AdminRepository();

  List<RasioDesaModel> listDesa = [];
  List<QueryDocumentSnapshot<Object?>> _allAduan = []; // Simpan semua data
  List<QueryDocumentSnapshot<Object?>> filteredAduan = []; // Data yang sudah difilter

  bool isLoading = true;
  String selectedStatusFilter = 'Semua';

  AdminMonitoringViewModel() {
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _monitoringRepo.getDummyRasioData(),
        _adminRepo.getAllAduanFuture(), // Ambil semua data tanpa filter
      ]);

      listDesa = results[0] as List<RasioDesaModel>;
      _allAduan = results[1] as List<QueryDocumentSnapshot<Object?>>;

      // Terapkan filter setelah data dimuat
      _applyFilter();
    } catch (e) {
      // Tangani kesalahan
      print('Error fetching data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void changeStatusFilter(String newStatus) {
    selectedStatusFilter = newStatus;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (selectedStatusFilter == 'Semua') {
      filteredAduan = _allAduan;
    } else {
      filteredAduan = _allAduan.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final status = data?['status']?.toString().toLowerCase() ?? 'baru';
        return status == selectedStatusFilter.toLowerCase();
      }).toList();
    }
  }

  // Metode untuk refresh data
  Future<void> refreshData() async {
    await fetchData();
  }
}