import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jabar_caang/data/models/pln_data_model.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<PlnApiResponse> fetchPlnData() async {
    try {
      final snapshot = await _firestore.collection('data_pln').get();

      final results = snapshot.docs.map((doc) {
        return PlnDataModel.fromMap(doc.data());
      }).toList();

      return PlnApiResponse(results: results);
    } catch (e) {
      throw Exception('Gagal mengambil data PLN: $e');
    }
  }
}
