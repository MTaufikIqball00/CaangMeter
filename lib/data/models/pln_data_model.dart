
import 'dart:convert';

class PlnDataModel {
    final String namaProvinsi;
    final String namaDesa;
    final int jumlahKeluarga;
    final int tahun;

    PlnDataModel({
        required this.namaProvinsi,
        required this.namaDesa,
        required this.jumlahKeluarga,
        required this.tahun,
    });

    factory PlnDataModel.fromMap(Map<String, dynamic> map) {
        return PlnDataModel(
            namaProvinsi: map['nama_provinsi'] ?? '',
            namaDesa: map['nama_desa'] ?? '',
            jumlahKeluarga: (map['jumlah_keluarga'] ?? 0) is int
                ? map['jumlah_keluarga']
                : int.tryParse(map['jumlah_keluarga'].toString()) ?? 0,
            tahun: (map['tahun'] ?? 0) is int
                ? map['tahun']
                : int.tryParse(map['tahun'].toString()) ?? 0,
        );
    }
}

class PlnApiResponse {
    final List<PlnDataModel> results;

    PlnApiResponse({required this.results});
}
