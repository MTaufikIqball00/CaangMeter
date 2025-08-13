class SimulasiDetailModel {
  final double originalBill;
  final double originalKwh;
  final double dailyKwh;
  final bool isUsingBlock2;
  final double block2Kwh;
  final double usableProductionKwh;
  final double offsetKwh;
  final double remainingKwh;
  final double newBill;
  final double finalNewBill;

  SimulasiDetailModel({
    required this.originalBill,
    required this.originalKwh,
    required this.dailyKwh,
    required this.isUsingBlock2,
    required this.block2Kwh,
    required this.usableProductionKwh,
    required this.offsetKwh,
    required this.remainingKwh,
    required this.newBill,
    required this.finalNewBill,
  });
}