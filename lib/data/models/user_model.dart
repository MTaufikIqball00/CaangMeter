class UserModel {
  final String uid;
  final String email;
  final String role;
  final String? namaLengkap;
  UserModel({required this.uid, required this.email, required this.role, this.namaLengkap});

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      namaLengkap: data['namaLengkap']
    );
  }
}
