import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadImage(File file, String userId) async {
    try {
      final String fileName = _uuid.v4();
      final ref = _storage.ref().child('aduan_images').child(userId).child('$fileName.jpg');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Gagal mengunggah gambar: $e');
    }
  }
}
