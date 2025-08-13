import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

class WawasanProvinsiCard extends StatelessWidget {
  const WawasanProvinsiCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blueGrey[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wawasan Kelistrikan Jawa Barat',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sumber: Statistik PLN 2024',
              style: textTheme.bodySmall?.copyWith(color: Colors.blueGrey[600]),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.flash_on,
                  value: '99,98%',
                  label: 'Rasio Elektrifikasi',
                ),
                _buildStatItem(
                  context,
                  icon: Icons.home_work,
                  value: '100%',
                  label: 'Desa Berlistrik',
                ),
                _buildStatItem(
                  context,
                  icon: Icons.people,
                  value: '15,2 Jt',
                  label: 'Total Pelanggan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required IconData icon, required String value, required String label}) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        Icon(icon, size: 32, color: primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: Colors.blueGrey[700]),
        ),
      ],
    );
  }
}