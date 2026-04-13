class TipResult {
  final double tipAmount;
  final double totalAmount;
  final double perPerson;

  const TipResult({
    required this.tipAmount,
    required this.totalAmount,
    required this.perPerson,
  });
}

class TipCalculatorService {
  static TipResult calculate({
    required double billAmount,
    required double tipPercentage,
    required int splitCount,
  }) {
    final tipAmount = billAmount * (tipPercentage / 100);
    final totalAmount = billAmount + tipAmount;
    final perPerson = splitCount > 0 ? totalAmount / splitCount : totalAmount;

    return TipResult(
      tipAmount: tipAmount,
      totalAmount: totalAmount,
      perPerson: perPerson,
    );
  }
}
