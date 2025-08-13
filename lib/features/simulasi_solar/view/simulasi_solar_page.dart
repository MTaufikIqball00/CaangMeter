import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jabar_caang/features/simulasi_solar/model/simulasi_result_model.dart';
import 'package:jabar_caang/features/simulasi_solar/services/simulasi_solar_service.dart';
import 'package:intl/intl.dart';

class SimulasiSolarPage extends StatefulWidget {
  const SimulasiSolarPage({super.key});

  @override
  State<SimulasiSolarPage> createState() => _SimulasiSolarPageState();
}

class _SimulasiSolarPageState extends State<SimulasiSolarPage> {
  final _formKey = GlobalKey<FormState>();
  final _billController = TextEditingController();
  final _solarService = SimulasiSolarService();
  bool _isLoading = false;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Hapus format Rupiah sebelum mengubah ke double
      final cleanString = _billController.text.replaceAll(RegExp(r'[^\d]'), '');
      final monthlyBill = double.tryParse(cleanString) ?? 0;

      final SimulasiResultModel result = _solarService.calculate(monthlyBill: monthlyBill);

      // Delay untuk memberi kesan kalkulasi sedang berjalan
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          context.push('/simulasi-hasil', extra: result);
        }
      });
    }
  }

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Simulasi Panel Surya'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              margin: const EdgeInsets.all(20),
              child: Card(
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
                        Colors.orange.shade300,
                        Colors.orange.shade600,
                        Colors.deepOrange.shade600,
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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.wb_sunny,
                          size: 60,
                          color: Colors.orange.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Kalkulator Solar Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hitung potensi penghematan dengan panel surya',
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
            ),

            // Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Penting',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Masukkan rata-rata tagihan listrik bulanan Anda (3-6 bulan terakhir)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Input Form Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Input Tagihan Listrik',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Input Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.orange.shade200, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _billController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _RupiahInputFormatter(),
                            ],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Tagihan Listrik Bulanan',
                              labelStyle: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(
                                Icons.receipt_long,
                                color: Colors.orange,
                              ),
                              prefixText: 'Rp ',
                              prefixStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mohon masukkan jumlah tagihan';
                              }
                              final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
                              final amount = double.tryParse(cleanValue);

                              if (amount == null) {
                                return 'Format tidak valid';
                              }

                              if (amount < 100000) {
                                return 'Minimum tagihan Rp 100.000';
                              }

                              if (amount > 10000000) {
                                return 'Maksimum tagihan Rp 10.000.000';
                              }

                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Helper text
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: Colors.grey.shade600, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Contoh: Jika tagihan 3 bulan terakhir Rp 500k, 600k, 550k → masukkan Rp 550.000',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Calculate Button
                        Container(
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(27.5),
                            gradient: _isLoading
                                ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400])
                                : LinearGradient(
                              colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _isLoading
                                    ? Colors.grey.withOpacity(0.3)
                                    : Colors.orange.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _calculate,
                            icon: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Icon(Icons.calculate, color: Colors.white),
                            label: Text(
                              _isLoading ? 'MENGHITUNG...' : 'HITUNG SIMULASI',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Features Info
            Container(
              margin: const EdgeInsets.all(20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yang Akan Anda Dapatkan:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        icon: Icons.solar_power,
                        text: 'Rekomendasi ukuran sistem panel surya',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        icon: Icons.attach_money,
                        text: 'Estimasi biaya pemasangan',
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        icon: Icons.savings,
                        text: 'Perkiraan penghematan bulanan',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        icon: Icons.schedule,
                        text: 'Estimasi waktu balik modal',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Input Formatter untuk format Rupiah
class _RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String cleanString = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanString.isEmpty) {
      return const TextEditingValue();
    }

    // Format with thousand separators
    final formatter = NumberFormat('#,###', 'id_ID');
    String formatted = formatter.format(int.parse(cleanString));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}