import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jabar_caang/app/constants/firebase_constants.dart';
import 'package:jabar_caang/data/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Getter untuk user yang sedang login
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream untuk cek status login user
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Registrasi user baru
  Future<User?> signUp({
    required String email,
    required String password,
    required String namaLengkap,
    required String role,
  }) async {
    try {
      // Buat akun di Firebase Authentication
      UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // Simpan data user ke Firestore
      if (user != null) {
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(user.uid)
            .set({
          FirebaseConstants.namaLengkapField: namaLengkap,
          'email': email,
          FirebaseConstants.roleField: role,
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Gagal membuat akun');
    }
  }

  // Login user
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Gagal login');
    }
  }

  // Login dengan Google
  Future<User?> signInWithGoogle() async {
    try {
      // Mulai flow Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User membatalkan login
        return null;
      }

      // Ambil kredensial Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login ke Firebase dengan kredensial Google
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;

      // Simpan data user ke Firestore jika user baru
      if (user != null) {
        final userDoc = await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await _firestore
              .collection(FirebaseConstants.usersCollection)
              .doc(user.uid)
              .set({
            FirebaseConstants.namaLengkapField: user.displayName ?? 'User Google',
            'email': user.email,
            FirebaseConstants.roleField: 'user', // Default role untuk Google Sign-In
          });
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Gagal login dengan Google');
    }
  }

  // Logout user
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // Ambil data user dari Firestore
  Future<UserModel> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>, uid);
      }
      throw Exception("User tidak ditemukan");
    } catch (e) {
      throw Exception('Gagal mengambil data user');
    }
  }

  // Update data user di Firestore
  Future<void> updateUserData({
    required String uid,
    required String namaLengkap,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update({FirebaseConstants.namaLengkapField: namaLengkap});
    } catch (e) {
      throw Exception('Gagal memperbarui data user');
    }
  }

  // Ganti password user
  Future<void> changeUserPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final cred = EmailAuthProvider.credential(
            email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(newPassword);
      } else {
        throw Exception("User tidak login, tidak bisa ganti password.");
      }
    } on FirebaseAuthException {
      rethrow; // Lempar kembali exception dari firebase auth untuk ditangani di ViewModel
    }
  }

  // Ambil role user dari Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection(FirebaseConstants.usersCollection).doc(uid).get();

      if (doc.exists) {
        return doc.get(FirebaseConstants.roleField) as String?;
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil role user');
    }
  }
}