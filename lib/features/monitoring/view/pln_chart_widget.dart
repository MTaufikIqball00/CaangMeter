import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jabar_caang/data/models/pln_data_model.dart';
import 'package:jabar_caang/core/services/api_service.dart';

class PlnChartWidget extends StatefulWidget {
  const PlnChartWidget({super.key});

  @override
  State<PlnChartWidget> createState() => _PlnChartWidgetState();
}

class _PlnChartWidgetState extends State<PlnChartWidget> {
  final ApiService _apiService = ApiService();
  late Future<PlnApiResponse> _plnDataFuture;

  @override
  void initState() {
    super.initState();
    _plnDataFuture = _apiService.fetchPlnData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlnApiResponse>(
      future: _plnDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat data chart: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
          return const Center(child: Text('Tidak ada data untuk ditampilkan.'));
        }

        // Urutkan data dan ambil 10 terbesar
        final allData = snapshot.data!.results;
        allData.sort((a, b) => b.jumlahKeluarga.compareTo(a.jumlahKeluarga));
        final top10Data = allData.take(10).toList();

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: top10Data.first.jumlahKeluarga * 1.2,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 100,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index >= top10Data.length) return const SizedBox.shrink();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 8.0,
                      child: Transform.rotate(
                        angle: -45 * (3.1415926535 / 180),
                        child: Text(
                          top10Data[index].namaDesa,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value % 5000 != 0) return const SizedBox.shrink();
                    return Text('${value ~/ 1000}k', style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (value) => const FlLine(
                color: Colors.grey,
                strokeWidth: 0.5,
              ),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            barGroups: top10Data.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data.jumlahKeluarga.toDouble(),
                    color: Colors.blue,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
