import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:jabar_caang/features/admin/repository/admin_repository.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();
  
  List<DocumentSnapshot> _aduanList = [];
  List<DocumentSnapshot> get aduanList => _aduanList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AdminViewModel() {
    fetchAduan();
  }

  Future<void> fetchAduan() async {
    _isLoading = true;
    notifyListeners();
    try {
      _aduanList = await _repository.getAllAduanFuture();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String aduanId, String status) async {
    try {
      await _repository.updateAduanStatus(aduanId, status);
      // Refresh the list after updating the status
      fetchAduan();
    } catch (e) {

    }
  }
}
