import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jabar_caang/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        // Menggunakan ListView agar bisa scroll jika ada konten tambahan
        padding: EdgeInsets.zero, // Menghilangkan padding default dari ListView
        children: [
          const WelcomeCard(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Layanan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8, // Mengatur rasio aspek kartu agar sedikit lebih tinggi
                  children: [
                    _buildMenuCard(
                      context: context,
                      imagePath: 'assets/img/aduan.jpg',
                      title: 'Buat Aduan Baru',
                      onTap: () => context.push('/form-aduan'),
                    ),
                    _buildMenuCard(
                      context: context,
                      imagePath: 'assets/img/riwayat.jpg',
                      title: 'Riwayat Aduan',
                      onTap: () => context.push('/list-aduan'),
                    ),
                    _buildMenuCard(
                      context: context,
                      imagePath: 'assets/img/solar.jpg',
                      title: 'Simulasi Solar',
                      onTap: () => context.push('/simulasi-solar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({required BuildContext context, required String imagePath, required String title, required VoidCallback onTap}) {
    return Card(
      clipBehavior: Clip.antiAlias, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withAlpha(26),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bagian untuk gambar
            Expanded(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                // Menampilkan ikon error jika gambar gagal dimuat
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 48, color: Colors.grey);
                },
              ),
            ),
            // Bagian untuk teks
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan listen = true agar widget rebuild saat userModel berubah
    final authVM = Provider.of<AuthViewModel>(context);

    final user = FirebaseAuth.instance.currentUser;

    // Jika masih loading data user, tampilkan CircularProgressIndicator
    if (authVM.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Ambil nama user dengan fallback: Firestore -> FirebaseAuth -> "Pengguna"
    final displayName =
        authVM.userModel?.namaLengkap ?? user?.displayName ?? 'Pengguna';

    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $displayName!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Siap membantu Jawa Barat lebih terang?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Avatar
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 28,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
