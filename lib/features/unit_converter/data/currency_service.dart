import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const _baseUrl = 'https://open.er-api.com/v6/latest/USD';

  static final Map<String, double> _fallbackRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'NGN': 1550.0,
    'KES': 129.0,
    'JPY': 149.5,
    'CAD': 1.36,
    'AUD': 1.53,
  };

  static Map<String, double>? _cachedRates;

  static Future<Map<String, double>> fetchRates() async {
    if (_cachedRates != null) return _cachedRates!;

    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rates = (data['rates'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        );
        // Only keep the currencies we support
        _cachedRates = {
          for (final code in _fallbackRates.keys)
            if (rates.containsKey(code)) code: rates[code]!,
        };
        return _cachedRates!;
      }
    } catch (_) {}
    _cachedRates = _fallbackRates;
    return _fallbackRates;
  }

  static List<String> get supportedCurrencies => _fallbackRates.keys.toList();
}
