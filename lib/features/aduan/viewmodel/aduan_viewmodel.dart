import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jabar_caang/core/utils/image_picker_util.dart';
import 'package:jabar_caang/data/models/aduan_model.dart';
import 'package:jabar_caang/data/repositories/aduan_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AduanViewModel extends ChangeNotifier {
  final AduanRepository _aduanRepository = AduanRepository();
  final _auth = FirebaseAuth.instance;

  Uint8List? _imageBytes;
  Position? _currentPosition;
  bool _isLoading = false;
  String _loadingMessage = 'Mengirim aduan...';

  Uint8List? get imageBytes => _imageBytes;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;

  Future<void> pickImage() async {
    _loadingMessage = 'Memproses gambar...';
    _isLoading = true;
    notifyListeners();

    final compressedBytes = await ImagePickerUtil.pickAndCompressImage();

    if (compressedBytes != null) {
      _imageBytes = compressedBytes;
    }

    _isLoading = false;
    _loadingMessage = 'Mengirim aduan...';
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Layanan lokasi tidak aktif.
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Izin lokasi ditolak.
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Izin lokasi ditolak permanen.
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      notifyListeners();
    } catch (e) {
      // Error mendapatkan lokasi
    }
  }

  Future<bool> submitAduan({
    required String nama,
    required String hp,
    required String desa,
    required String keterangan,
  }) async {
    _isLoading = true;
    _loadingMessage = 'Mengirim aduan...';
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null || _currentPosition == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      String? fotoUrl;
      if (_imageBytes != null) {
        _loadingMessage = 'Mengunggah foto...';
        notifyListeners();
        fotoUrl =
            await _aduanRepository.uploadImageFromBytes(_imageBytes!, user.uid);
      }

      _loadingMessage = 'Menyimpan data...';
      notifyListeners();

      final aduan = AduanModel(
        userId: user.uid,
        nama: nama,
        hp: hp,
        desa: desa,
        keterangan: keterangan,
        lokasi: GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        timestamp: Timestamp.now(),
        fotoUrl: fotoUrl,
      );

      await _aduanRepository.addAduan(aduan);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Error submit aduan
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
