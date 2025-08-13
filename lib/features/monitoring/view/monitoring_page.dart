import 'package:flutter/material.dart';
import 'package:jabar_caang/features/monitoring/view/aduan_map_widget.dart';
import 'package:jabar_caang/features/monitoring/view/pln_chart_widget.dart';

class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), // background lembut
      appBar: AppBar(
        title: const Text(
          'Monitoring & Analisis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Section
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Monitoring Daerah Berlistrik PLN Jawa Barat",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // Map Section
            _buildModernCard(
              context,
              title: "Peta Distribusi Listrik",
              icon: Icons.map_outlined,
              child: SizedBox(
                height: screenHeight * 0.5,
                child: const AduanMapWidget(),
              ),
            ),

            const SizedBox(height: 20),

            // Chart Section
            _buildModernCard(
              context,
              title: "Analisis Keluarga Berlistrik PLN",
              icon: Icons.bar_chart_rounded,
              child: SizedBox(
                height: screenHeight * 0.4,
                child: const PlnChartWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCard(BuildContext context,
      {required String title,
        required IconData icon,
        required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Icon(icon, color: Colors.blue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1, height: 1),
            const SizedBox(height: 12),

            // Content
            child,
          ],
        ),
      ),
    );
  }
}
