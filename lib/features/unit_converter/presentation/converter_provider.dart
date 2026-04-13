import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utility_hub/features/unit_converter/data/currency_service.dart';
import 'package:utility_hub/features/unit_converter/domain/conversion_model.dart';
import 'package:utility_hub/features/unit_converter/domain/converter_utils.dart';

class ConverterState {
  final ConversionCategory category;
  final ConversionUnit fromUnit;
  final ConversionUnit toUnit;
  final double inputValue;
  final double result;
  final Map<String, double>? currencyRates;
  final bool isLoadingRates;
  final List<ConversionUnit> availableUnits;

  const ConverterState({
    required this.category,
    required this.fromUnit,
    required this.toUnit,
    this.inputValue = 0,
    this.result = 0,
    this.currencyRates,
    this.isLoadingRates = false,
    this.availableUnits = const [],
  });

  ConverterState copyWith({
    ConversionCategory? category,
    ConversionUnit? fromUnit,
    ConversionUnit? toUnit,
    double? inputValue,
    double? result,
    Map<String, double>? currencyRates,
    bool? isLoadingRates,
    List<ConversionUnit>? availableUnits,
  }) {
    return ConverterState(
      category: category ?? this.category,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      inputValue: inputValue ?? this.inputValue,
      result: result ?? this.result,
      currencyRates: currencyRates ?? this.currencyRates,
      isLoadingRates: isLoadingRates ?? this.isLoadingRates,
      availableUnits: availableUnits ?? this.availableUnits,
    );
  }
}

class ConverterNotifier extends StateNotifier<ConverterState> {
  ConverterNotifier()
      : super(ConverterState(
          category: ConversionCategory.length,
          fromUnit: ConverterUtils.units[ConversionCategory.length]![0],
          toUnit: ConverterUtils.units[ConversionCategory.length]![1],
          availableUnits: ConverterUtils.units[ConversionCategory.length]!,
        ));

  void setCategory(ConversionCategory category) {
    if (category == ConversionCategory.currency) {
      final currencyUnits = CurrencyService.supportedCurrencies
          .map((c) => ConversionUnit(name: c, symbol: c))
          .toList();
      state = state.copyWith(
        category: category,
        fromUnit: currencyUnits[0],
        toUnit: currencyUnits[1],
        availableUnits: currencyUnits,
        inputValue: 0,
        result: 0,
      );
      _loadCurrencyRates();
    } else {
      final units = ConverterUtils.units[category]!;
      state = state.copyWith(
        category: category,
        fromUnit: units[0],
        toUnit: units[1],
        availableUnits: units,
        inputValue: 0,
        result: 0,
      );
    }
  }

  void setFromUnit(ConversionUnit unit) {
    state = state.copyWith(fromUnit: unit);
    _recalculate();
  }

  void setToUnit(ConversionUnit unit) {
    state = state.copyWith(toUnit: unit);
    _recalculate();
  }

  void setInputValue(double value) {
    state = state.copyWith(inputValue: value);
    _recalculate();
  }

  void swapUnits() {
    state = state.copyWith(
      fromUnit: state.toUnit,
      toUnit: state.fromUnit,
    );
    _recalculate();
  }

  void _recalculate() {
    final result = ConverterUtils.convert(
      category: state.category,
      fromSymbol: state.fromUnit.symbol,
      toSymbol: state.toUnit.symbol,
      value: state.inputValue,
      currencyRates: state.currencyRates,
    );
    state = state.copyWith(result: result);
  }

  Future<void> _loadCurrencyRates() async {
    state = state.copyWith(isLoadingRates: true);
    final rates = await CurrencyService.fetchRates();
    state = state.copyWith(currencyRates: rates, isLoadingRates: false);
    _recalculate();
  }
}

final converterProvider =
    StateNotifierProvider<ConverterNotifier, ConverterState>((ref) {
  return ConverterNotifier();
});
