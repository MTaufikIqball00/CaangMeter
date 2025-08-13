import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jabar_caang/features/simulasi_solar/model/simulasi_result_model.dart';
import 'package:jabar_caang/features/simulasi_solar/model/simulasi_detail_model.dart';
import 'package:intl/intl.dart';

class SimulasiHasilPage extends StatelessWidget {
  final SimulasiResultModel result;
  final SimulasiDetailModel? details; // Optional untuk backward compatibility

  const SimulasiHasilPage({
    super.key,
    required this.result,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Hasil Simulasi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade300,
                        Colors.green.shade600,
                        Colors.teal.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 60,
                          color: Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Simulasi Selesai!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Berikut adalah hasil kalkulasi sistem panel surya Anda',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // System Size Card
              _buildResultCard(
                title: 'Ukuran Sistem',
                value: '${result.systemSizeKw.toStringAsFixed(1)} kWp',
                icon: Icons.solar_power,
                color: Colors.orange,
                subtitle: 'Rekomendasi kapasitas panel surya',
              ),

              const SizedBox(height: 16),

              // Cost Card
              _buildResultCard(
                title: 'Estimasi Biaya',
                value: currencyFormatter.format(result.estimatedCost),
                icon: Icons.attach_money,
                color: Colors.blue,
                subtitle: 'Termasuk instalasi dan komponen',
              ),

              const SizedBox(height: 16),

              // Production Card
              _buildResultCard(
                title: 'Produksi Listrik',
                value: '${result.monthlyProductionKwh.toStringAsFixed(0)} kWh/bulan',
                icon: Icons.electric_bolt,
                color: Colors.amber,
                subtitle: 'Estimasi energi yang dihasilkan',
              ),

              const SizedBox(height: 16),

              // Savings Card
              _buildResultCard(
                title: 'Penghematan Bulanan',
                value: currencyFormatter.format(result.monthlySavings),
                icon: Icons.savings,
                color: Colors.green,
                subtitle: 'Potensi pengurangan tagihan listrik',
              ),

              const SizedBox(height: 16),

              // Payback Period Card
              _buildResultCard(
                title: 'Periode Balik Modal',
                value: result.paybackPeriodYears == double.infinity
                    ? 'Tidak terhitung'
                    : '${result.paybackPeriodYears.toStringAsFixed(1)} tahun',
                icon: Icons.schedule,
                color: Colors.purple,
                subtitle: 'Waktu untuk mencapai break-even point',
              ),

              // Detail breakdown jika tersedia
              if (details != null) ...[
                const SizedBox(height: 24),
                _buildDetailSection(),
              ],

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('HITUNG ULANG'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: BorderSide(color: Colors.orange.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur berbagi akan segera hadir!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('BAGIKAN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Disclaimer
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Catatan Penting',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Hasil ini merupakan estimasi berdasarkan data yang dimasukkan\n'
                            '• Kondisi aktual dapat bervariasi tergantung lokasi, cuaca, dan faktor lainnya\n'
                            '• Konsultasikan dengan ahli untuk analisis yang lebih detail\n'
                            '• Perhitungan menggunakan data rata-rata Jawa Barat',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Perhitungan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildDetailRow(
              'Tagihan Asli',
              currencyFormatter.format(details!.originalBill),
            ),
            _buildDetailRow(
              'Konsumsi Asli',
              '${details!.originalKwh.toStringAsFixed(0)} kWh',
            ),
            _buildDetailRow(
              'Konsumsi Harian',
              '${details!.dailyKwh.toStringAsFixed(1)} kWh/hari',
            ),
            if (details!.isUsingBlock2)
              _buildDetailRow(
                'Penggunaan Blok 2',
                '${details!.block2Kwh.toStringAsFixed(0)} kWh (>${details!.originalKwh > 900 ? "900" : "0"} kWh)',
              ),
            _buildDetailRow(
              'Produksi Dapat Digunakan',
              '${details!.usableProductionKwh.toStringAsFixed(0)} kWh',
            ),
            _buildDetailRow(
              'Listrik Ter-offset',
              '${details!.offsetKwh.toStringAsFixed(0)} kWh',
            ),
            _buildDetailRow(
              'Sisa Konsumsi',
              '${details!.remainingKwh.toStringAsFixed(0)} kWh',
            ),
            _buildDetailRow(
              'Tagihan Baru (sebelum biaya tetap)',
              currencyFormatter.format(details!.newBill),
            ),
            _buildDetailRow(
              'Tagihan Final',
              currencyFormatter.format(details!.finalNewBill),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 8),
      ],
    );
  }
}