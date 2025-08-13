import 'package:cloud_firestore/cloud_firestore.dart';

class AduanModel {
  final String userId;
  final String nama;
  final String hp;
  final String desa;
  final String keterangan;
  final GeoPoint lokasi;
  final Timestamp timestamp;
  final String? fotoUrl;

  AduanModel({
    required this.userId,
    required this.nama,
    required this.hp,
    required this.desa,
    required this.keterangan,
    required this.lokasi,
    required this.timestamp,
    this.fotoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nama': nama,
      'hp': hp,
      'desa': desa,
      'keterangan': keterangan,
      'lokasi': lokasi,
      'timestamp': timestamp,
      'fotoUrl': fotoUrl,
      'status': 'baru'
    };
  }
}
