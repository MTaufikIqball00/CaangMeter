import 'dart:math';

import 'package:jabar_caang/features/simulasi_solar/model/simulasi_result_model.dart';
import 'package:jabar_caang/features/simulasi_solar/model/simulasi_detail_model.dart';

class SimulasiSolarService {
  // Harga pemasangan panel surya per kWp (berdasarkan harga pasar 2024/2025)
  static const double costPerKwp = 20000000; // Rp 20.000.000 (lebih realistis)

  // Tarif dasar listrik PLN per kWh (R1/900VA - tarif progresif)
  static const Map<String, double> plnTariffBlocks = {
    'block1': 1352,  // 0-900 kWh
    'block2': 1444.7, // >900 kWh
    'average': 1400,  // rata-rata untuk perhitungan
  };

  // Konstanta tarif untuk akses langsung
  static const double block1Rate = 1352.0;
  static const double block2Rate = 1444.7;

  // Rata-rata jam puncak sinar matahari per hari di Jawa Barat
  static const double avgSunHoursPerDay = 4.2; // Lebih konservatif

  // Faktor efisiensi sistem (panel + inverter + kabel + debu/suhu)
  static const double systemEfficiency = 0.80; // Lebih realistis

  // Faktor degradasi panel per tahun (biasanya 0.5-0.8%)
  static const double annualDegradation = 0.007; // 0.7%

  // Biaya maintenance tahunan (% dari biaya instalasi)
  static const double annualMaintenanceRate = 0.02; // 2%

  SimulasiResultModel calculate({required double monthlyBill}) {
    // 1. Estimasi konsumsi energi bulanan berdasarkan tarif progresif
    final double monthlyKwh = _estimateMonthlyKwh(monthlyBill);

    // 2. Hitung kebutuhan energi harian
    final double dailyKwh = monthlyKwh / 30;

    // 3. Hitung ukuran sistem yang dibutuhkan (dengan margin keamanan 10%)
    final double requiredSystemSizeKw = (dailyKwh / (avgSunHoursPerDay * systemEfficiency)) * 1.1;

    // 4. Batasi ukuran sistem maksimal (untuk rumah tangga biasanya max 10kWp)
    final double systemSizeKw = min(requiredSystemSizeKw, 10.0);

    // 5. Hitung estimasi biaya total (instalasi + komponen pendukung)
    final double installationCost = systemSizeKw * costPerKwp;
    final double additionalCosts = installationCost * 0.15; // 15% untuk perizinan, instalasi, dll
    final double estimatedCost = installationCost + additionalCosts;

    // 6. Hitung produksi listrik bulanan aktual dari sistem
    final double monthlyProductionKwh = systemSizeKw * avgSunHoursPerDay * systemEfficiency * 30;

    // 7. Hitung penghematan dengan mempertimbangkan tarif progresif
    final savingsData = _calculateMonthlySavingsWithDetails(monthlyProductionKwh, monthlyBill, monthlyKwh);
    final double monthlySavings = savingsData['savings']!;

    // 8. Hitung periode balik modal dengan NPV sederhana
    final double annualSavings = monthlySavings * 12;
    final double annualMaintenance = estimatedCost * annualMaintenanceRate;
    final double netAnnualSavings = annualSavings - annualMaintenance;

    final double paybackPeriodYears = (netAnnualSavings > 0)
        ? estimatedCost / netAnnualSavings
        : double.infinity;

    return SimulasiResultModel(
      systemSizeKw: systemSizeKw,
      estimatedCost: estimatedCost,
      monthlyProductionKwh: monthlyProductionKwh,
      monthlySavings: monthlySavings,
      paybackPeriodYears: paybackPeriodYears,
    );
  }

  Map<String, dynamic> calculateWithDetails({required double monthlyBill}) {
    // 1. Estimasi konsumsi energi bulanan berdasarkan tarif progresif
    final double monthlyKwh = _estimateMonthlyKwh(monthlyBill);

    // 2. Hitung kebutuhan energi harian
    final double dailyKwh = monthlyKwh / 30;

    // 3. Hitung ukuran sistem yang dibutuhkan (dengan margin keamanan 10%)
    final double requiredSystemSizeKw = (dailyKwh / (avgSunHoursPerDay * systemEfficiency)) * 1.1;

    // 4. Batasi ukuran sistem maksimal (untuk rumah tangga biasanya max 10kWp)
    final double systemSizeKw = min(requiredSystemSizeKw, 10.0);

    // 5. Hitung estimasi biaya total (instalasi + komponen pendukung)
    final double installationCost = systemSizeKw * costPerKwp;
    final double additionalCosts = installationCost * 0.15; // 15% untuk perizinan, instalasi, dll
    final double estimatedCost = installationCost + additionalCosts;

    // 6. Hitung produksi listrik bulanan aktual dari sistem
    final double monthlyProductionKwh = systemSizeKw * avgSunHoursPerDay * systemEfficiency * 30;

    // 7. Hitung penghematan dengan detail
    final savingsData = _calculateMonthlySavingsWithDetails(monthlyProductionKwh, monthlyBill, monthlyKwh);
    final double monthlySavings = savingsData['savings']!;

    // 8. Hitung periode balik modal dengan NPV sederhana
    final double annualSavings = monthlySavings * 12;
    final double annualMaintenance = estimatedCost * annualMaintenanceRate;
    final double netAnnualSavings = annualSavings - annualMaintenance;

    final double paybackPeriodYears = (netAnnualSavings > 0)
        ? estimatedCost / netAnnualSavings
        : double.infinity;

    // Create result model
    final result = SimulasiResultModel(
      systemSizeKw: systemSizeKw,
      estimatedCost: estimatedCost,
      monthlyProductionKwh: monthlyProductionKwh,
      monthlySavings: monthlySavings,
      paybackPeriodYears: paybackPeriodYears,
    );

    // Create detail model
    final details = SimulasiDetailModel(
      originalBill: monthlyBill,
      originalKwh: monthlyKwh,
      dailyKwh: dailyKwh,
      isUsingBlock2: monthlyKwh > 900,
      block2Kwh: monthlyKwh > 900 ? monthlyKwh - 900 : 0,
      usableProductionKwh: savingsData['usableProduction']!,
      offsetKwh: savingsData['offsetKwh']!,
      remainingKwh: savingsData['remainingKwh']!,
      newBill: savingsData['newBill']!,
      finalNewBill: savingsData['finalNewBill']!,
    );

    return {
      'result': result,
      'details': details,
    };
  }

  // Estimasi kWh berdasarkan tarif progresif PLN
  double _estimateMonthlyKwh(double monthlyBill) {
    const double block1Limit = 900; // kWh
    final double block1Cost = block1Limit * block1Rate;

    if (monthlyBill <= block1Cost) {
      // Masih di blok 1
      return monthlyBill / block1Rate;
    } else {
      // Sebagian di blok 2
      final double block2Cost = monthlyBill - block1Cost;
      final double block2Kwh = block2Cost / block2Rate;
      return block1Limit + block2Kwh;
    }
  }

  // Hitung penghematan dengan mempertimbangkan net metering
  double _calculateMonthlySavings(double productionKwh, double originalBill) {
    // Asumsi: sistem net metering dengan efisiensi 90% (lebih realistis)
    // Tidak semua produksi bisa digunakan optimal karena ketidaksesuaian waktu produksi vs konsumsi

    final double originalKwh = _estimateMonthlyKwh(originalBill);

    // Faktor utilisasi realistis (90% dari produksi bisa dimanfaatkan)
    final double usableProductionKwh = productionKwh * 0.90;

    // kWh yang bisa di-offset (tidak boleh lebih dari kebutuhan)
    final double offsetKwh = min(usableProductionKwh, originalKwh);

    // Hitung tagihan baru setelah dikurangi produksi solar
    final double remainingKwh = originalKwh - offsetKwh;
    final double newBill = _calculateBillFromKwh(remainingKwh);

    // Tambahkan biaya bulanan tetap PLN (biaya beban/abodemen)
    final double monthlyFixedCharge = 15000; // Rp 15.000 biaya tetap bulanan
    final double finalNewBill = newBill + monthlyFixedCharge;

    // Penghematan = tagihan asli - tagihan baru
    final double savings = max(0, originalBill - finalNewBill);

    return savings;
  }

  // Hitung penghematan dengan detail untuk tampilan
  Map<String, double> _calculateMonthlySavingsWithDetails(double productionKwh, double originalBill, double originalKwh) {
    // Faktor utilisasi realistis (90% dari produksi bisa dimanfaatkan)
    final double usableProductionKwh = productionKwh * 0.90;

    // kWh yang bisa di-offset (tidak boleh lebih dari kebutuhan)
    final double offsetKwh = min(usableProductionKwh, originalKwh);

    // Hitung tagihan baru setelah dikurangi produksi solar
    final double remainingKwh = originalKwh - offsetKwh;
    final double newBill = _calculateBillFromKwh(remainingKwh);

    // Tambahkan biaya bulanan tetap PLN (biaya beban/abodemen)
    final double monthlyFixedCharge = 15000; // Rp 15.000 biaya tetap bulanan
    final double finalNewBill = newBill + monthlyFixedCharge;

    // Penghematan = tagihan asli - tagihan baru
    final double savings = max(0, originalBill - finalNewBill);

    return {
      'savings': savings,
      'usableProduction': usableProductionKwh,
      'offsetKwh': offsetKwh,
      'remainingKwh': remainingKwh,
      'newBill': newBill,
      'finalNewBill': finalNewBill,
    };
  }

  // Hitung tagihan dari kWh dengan tarif progresif
  double _calculateBillFromKwh(double kwh) {
    const double block1Limit = 900;

    if (kwh <= 0) return 0;

    if (kwh <= block1Limit) {
      return kwh * block1Rate;
    } else {
      final double block1Cost = block1Limit * block1Rate;
      final double block2Kwh = kwh - block1Limit;
      final double block2Cost = block2Kwh * block2Rate;
      return block1Cost + block2Cost;
    }
  }
}