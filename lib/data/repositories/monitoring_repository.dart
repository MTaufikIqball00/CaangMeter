import 'package:jabar_caang/data/models/rasio_desa_model.dart';

class MonitoringRepository {
  Future<List<RasioDesaModel>> getDummyRasioData() async {
    // Data dummy
    return Future.delayed(const Duration(seconds: 1), () {
      return [
        RasioDesaModel(id: '1', namaDesa: 'Sumber Jaya', namaKabupaten: 'Bandung', rasio: 98.5, latitude: -6.277321, longitude: 107.154838),
        RasioDesaModel(id: '2', namaDesa: 'Karang Satria', namaKabupaten: 'Bandung', rasio: 99.2, latitude: -6.229378, longitude: 107.014202),
        RasioDesaModel(id: '3', namaDesa: 'Setia Mekar', namaKabupaten: 'Sumedang', rasio: 95.0, latitude: -6.245309, longitude: 107.030640),
        RasioDesaModel(id: '4', namaDesa: 'Tlajung Udik', namaKabupaten: 'Bandung Barat', rasio: 85.7, latitude: -6.457783, longitude: 106.890625),
        RasioDesaModel(id: '5', namaDesa: 'Bojong Gede', namaKabupaten: 'Bandung', rasio: 78.1, latitude: -6.481564, longitude: 106.821701),
        RasioDesaModel(id: '6', namaDesa: 'Mangunjaya', namaKabupaten: 'Bekasi', rasio: 88.3, latitude: -6.325560, longitude: 107.047928),
        RasioDesaModel(id: '7', namaDesa: 'Wanajaya', namaKabupaten: 'Bekasi', rasio: 91.4, latitude: -6.327446, longitude: 107.136147),
        RasioDesaModel(id: '8', namaDesa: 'Sukadami', namaKabupaten: 'Bekasi', rasio: 87.5, latitude: -6.386797, longitude: 107.153183),
        RasioDesaModel(id: '9', namaDesa: 'Sukaraya', namaKabupaten: 'Bekasi', rasio: 92.8, latitude: -6.357092, longitude: 107.177574),
        RasioDesaModel(id: '10', namaDesa: 'Telagamurni', namaKabupaten: 'Bekasi', rasio: 90.6, latitude: -6.408607, longitude: 107.137566),
      ];
    });
  }
}
