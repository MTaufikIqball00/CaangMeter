import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mengambil SEMUA aduan untuk ditampilkan di dashboard admin (Future-based)
  Future<List<DocumentSnapshot>> getAllAduanFuture({String? status}) async {
    Query query = _firestore.collection('aduan_listrik').orderBy('timestamp', descending: true);

    // Hanya apply filter jika status bukan null dan bukan 'Semua'
    if (status != null && status != 'Semua') {
      // Pastikan case matching yang benar
      String filterStatus = status.toLowerCase();
      query = query.where('status', isEqualTo: filterStatus);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }

  // Mengambil SEMUA aduan secara real-time untuk dashboard admin (Stream-based)
  Stream<List<DocumentSnapshot>> getAllAduanStream({String? status}) {
    Query query = _firestore.collection('aduan_listrik').orderBy('timestamp', descending: true);

    // Hanya apply filter jika status bukan null dan bukan 'Semua'
    if (status != null && status != 'Semua') {
      String filterStatus = status.toLowerCase();
      query = query.where('status', isEqualTo: filterStatus);
    }

    return query.snapshots().map((snapshot) => snapshot.docs);
  }

  // Mengupdate status sebuah aduan
  Future<void> updateAduanStatus(String aduanId, String newStatus) {
    return _firestore.collection('aduan_listrik').doc(aduanId).update({'status': newStatus.toLowerCase()});
  }
}