import 'package:flutter/material.dart';
import 'package:jabar_caang/data/models/rasio_desa_model.dart';
import 'package:jabar_caang/data/repositories/monitoring_repository.dart';

class MonitoringViewModel extends ChangeNotifier {
  final MonitoringRepository _repository = MonitoringRepository();
  List<RasioDesaModel> _listDesa = [];
  bool _isLoading = true;

  List<RasioDesaModel> get listDesa => _listDesa;
  bool get isLoading => _isLoading;

  MonitoringViewModel() {
    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Di sini kita pakai data dummy
      _listDesa = await _repository.getDummyRasioData();
    } catch (e) {
      // handle error
    }
    _isLoading = false;
    notifyListeners();
  }
}