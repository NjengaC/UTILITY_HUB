enum ConversionCategory { length, weight, temperature, currency }

class ConversionUnit {
  final String name;
  final String symbol;

  const ConversionUnit({required this.name, required this.symbol});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionUnit && name == other.name && symbol == other.symbol;

  @override
  int get hashCode => name.hashCode ^ symbol.hashCode;
}
