import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:jabar_caang/data/models/user_model.dart';
import 'package:jabar_caang/data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _authRepository.currentUser;

  UserModel? _userModel;
  UserModel? get userModel => _userModel;
  bool get isAdmin => _userModel?.role == 'admin';

  AuthViewModel() {
    // Listen to authentication state changes
    _authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        await checkUserRole();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<bool> updateUserProfile(String namaLengkap) async {
    if (currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.updateUserData(
        uid: currentUser!.uid,
        namaLengkap: namaLengkap,
      );
      // Perbarui juga data model lokal agar UI langsung berubah
      _userModel = UserModel(
        uid: _userModel!.uid,
        email: _userModel!.email,
        role: _userModel!.role,
        namaLengkap: namaLengkap,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui profil: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid.';
          break;
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          _errorMessage = 'Email atau password yang Anda masukkan salah.';
          break;
        case 'email-already-in-use':
          _errorMessage = 'Email ini sudah terdaftar. Silakan gunakan email lain.';
          break;
        case 'weak-password':
          _errorMessage = 'Password terlalu lemah.';
          break;
        default:
          _errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
    } else {
      _errorMessage = 'Terjadi kesalahan: $e';
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authRepository.signIn(
        email: email,
        password: password,
      );
      if (userCredential != null) {
        _userModel = await _authRepository.getUserData(userCredential.uid);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        _userModel = await _authRepository.getUserData(user.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Login dengan Google dibatalkan.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String namaLengkap,
    String role = 'user', // Default role
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        namaLengkap: namaLengkap,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.changeUserPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return null; // Mengembalikan null menandakan sukses
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _errorMessage = 'Password saat ini yang Anda masukkan salah.';
      } else {
        _errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return _errorMessage; // Mengembalikan pesan error jika gagal
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _isLoading = false;
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<void> checkUserRole() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      _userModel = await _authRepository.getUserData(user.uid);
      notifyListeners();
    }
  }
}