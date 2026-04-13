import 'package:utility_hub/features/unit_converter/domain/conversion_model.dart';

class ConverterUtils {
  static const Map<ConversionCategory, List<ConversionUnit>> units = {
    ConversionCategory.length: [
      ConversionUnit(name: 'Meter', symbol: 'm'),
      ConversionUnit(name: 'Kilometer', symbol: 'km'),
      ConversionUnit(name: 'Centimeter', symbol: 'cm'),
      ConversionUnit(name: 'Mile', symbol: 'mi'),
      ConversionUnit(name: 'Foot', symbol: 'ft'),
      ConversionUnit(name: 'Inch', symbol: 'in'),
    ],
    ConversionCategory.weight: [
      ConversionUnit(name: 'Kilogram', symbol: 'kg'),
      ConversionUnit(name: 'Gram', symbol: 'g'),
      ConversionUnit(name: 'Pound', symbol: 'lb'),
      ConversionUnit(name: 'Ounce', symbol: 'oz'),
    ],
    ConversionCategory.temperature: [
      ConversionUnit(name: 'Celsius', symbol: '°C'),
      ConversionUnit(name: 'Fahrenheit', symbol: '°F'),
      ConversionUnit(name: 'Kelvin', symbol: 'K'),
    ],
  };

  // Length: all conversions go through meters as base
  static const Map<String, double> _lengthToMeter = {
    'm': 1.0,
    'km': 1000.0,
    'cm': 0.01,
    'mi': 1609.344,
    'ft': 0.3048,
    'in': 0.0254,
  };

  // Weight: all conversions go through kilograms as base
  static const Map<String, double> _weightToKg = {
    'kg': 1.0,
    'g': 0.001,
    'lb': 0.453592,
    'oz': 0.0283495,
  };

  static double convert({
    required ConversionCategory category,
    required String fromSymbol,
    required String toSymbol,
    required double value,
    Map<String, double>? currencyRates,
  }) {
    if (fromSymbol == toSymbol) return value;

    switch (category) {
      case ConversionCategory.length:
        final inMeters = value * _lengthToMeter[fromSymbol]!;
        return inMeters / _lengthToMeter[toSymbol]!;

      case ConversionCategory.weight:
        final inKg = value * _weightToKg[fromSymbol]!;
        return inKg / _weightToKg[toSymbol]!;

      case ConversionCategory.temperature:
        return _convertTemperature(value, fromSymbol, toSymbol);

      case ConversionCategory.currency:
        if (currencyRates == null) return 0;
        final fromUnit = _currencySymbolToCode(fromSymbol);
        final toUnit = _currencySymbolToCode(toSymbol);
        final inUsd = value / currencyRates[fromUnit]!;
        return inUsd * currencyRates[toUnit]!;
    }
  }

  static String _currencySymbolToCode(String symbol) => symbol;

  static double _convertTemperature(double value, String from, String to) {
    // Convert to Celsius first
    double celsius;
    switch (from) {
      case '°C':
        celsius = value;
      case '°F':
        celsius = (value - 32) * 5 / 9;
      case 'K':
        celsius = value - 273.15;
      default:
        celsius = value;
    }

    // Convert from Celsius to target
    switch (to) {
      case '°C':
        return celsius;
      case '°F':
        return celsius * 9 / 5 + 32;
      case 'K':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  static String categoryLabel(ConversionCategory category) {
    switch (category) {
      case ConversionCategory.length:
        return 'Length';
      case ConversionCategory.weight:
        return 'Weight';
      case ConversionCategory.temperature:
        return 'Temperature';
      case ConversionCategory.currency:
        return 'Currency';
    }
  }
}
