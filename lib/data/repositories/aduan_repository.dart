import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jabar_caang/data/models/aduan_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AduanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addAduan(AduanModel aduan) async {
    await _firestore.collection('aduan_listrik').add(aduan.toJson());
  }

  Future<String> uploadImageFromBytes(Uint8List imageBytes, String userId) async {
    final ref = _storage.ref().child('aduan_images/$userId/${DateTime.now().toIso8601String()}.jpg');
    await ref.putData(imageBytes);
    return await ref.getDownloadURL();
  }

  Stream<QuerySnapshot> getAduanStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.empty();

    return _firestore
        .collection('aduan_listrik')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<List<DocumentSnapshot>> getAduanFuture({String? status}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User tidak login!");

    Query query = _firestore
        .collection('aduan_listrik')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true);

    if (status != null && status != 'Semua') {
      query = query.where('status', isEqualTo: status.toLowerCase());
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }
}
