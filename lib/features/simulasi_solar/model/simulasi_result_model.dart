class SimulasiResultModel {
  final double systemSizeKw;
  final double estimatedCost;
  final double monthlyProductionKwh;
  final double monthlySavings;
  final double paybackPeriodYears;

  SimulasiResultModel({
    required this.systemSizeKw,
    required this.estimatedCost,
    required this.monthlyProductionKwh,
    required this.monthlySavings,
    required this.paybackPeriodYears,
  });
}
