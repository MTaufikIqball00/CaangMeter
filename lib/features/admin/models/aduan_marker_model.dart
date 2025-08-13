import 'package:latlong2/latlong.dart';

class AduanMarkerModel {
  final String id;
  final String keterangan;
  final String namaPelapor;
  final String status;
  final String namaDesa;
  final LatLng position;

  AduanMarkerModel({
    required this.id,
    required this.keterangan,
    required this.namaPelapor,
    required this.status,
    required this.namaDesa,
    required this.position,
  });
}
