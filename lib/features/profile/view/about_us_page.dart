import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Kami'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb_circle, size: 100, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Jabar Caang',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Versi 1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            const Text(
              'Jabar Caang adalah sebuah inisiatif digital untuk mendukung program elektrifikasi desa di Jawa Barat. Aplikasi ini memungkinkan masyarakat untuk secara aktif melaporkan masalah kelistrikan dan membantu pemerintah daerah dalam memetakan serta menyelesaikan isu-isu yang ada di lapangan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const Spacer(),
            const Text(
              '© 2025 - Pemerintah Provinsi Jawa Barat',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
