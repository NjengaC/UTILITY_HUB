import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utility_hub/features/bmi/domain/bmi_calculator_service.dart';

final bmiResultProvider = StateProvider<BmiResult?>((ref) => null);

class BmiScreen extends ConsumerStatefulWidget {
  const BmiScreen({super.key});

  @override
  ConsumerState<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends ConsumerState<BmiScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final height = double.parse(_heightController.text.trim());
    final weight = double.parse(_weightController.text.trim());

    final result = BmiCalculatorService.calculate(
      heightCm: height,
      weightKg: weight,
    );

    ref.read(bmiResultProvider.notifier).state = result;
  }

  void _clear() {
    _heightController.clear();
    _weightController.clear();
    ref.read(bmiResultProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(bmiResultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('BMI Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter your details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Height',
                          suffixText: 'cm',
                          prefixIcon: Icon(Icons.height_rounded),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          final v = double.tryParse(val.trim());
                          if (v == null || v <= 0 || v > 300) return 'Enter a valid height';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Weight',
                          suffixText: 'kg',
                          prefixIcon: Icon(Icons.monitor_weight_outlined),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          final v = double.tryParse(val.trim());
                          if (v == null || v <= 0 || v > 700) return 'Enter a valid weight';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _calculate,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Calculate BMI'),
                    ),
                  ),
                ],
              ),
              if (result != null) ...[
                const SizedBox(height: 24),
                _BmiResultCard(result: result),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BmiResultCard extends StatelessWidget {
  final BmiResult result;

  const _BmiResultCard({required this.result});

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Severely Underweight':
        return const Color(0xFFBA1A1A);
      case 'Underweight':
        return const Color(0xFFE65100);
      case 'Normal':
        return const Color(0xFF2E7D32);
      case 'Overweight':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFFBA1A1A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _getCategoryColor(result.category);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Your BMI',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.bmi.toStringAsFixed(1),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: categoryColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                result.category,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: categoryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              result.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            // BMI scale
            _BmiScale(currentBmi: result.bmi),
          ],
        ),
      ),
    );
  }
}

class _BmiScale extends StatelessWidget {
  final double currentBmi;

  const _BmiScale({required this.currentBmi});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BMI Scale',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                _scaleSegment(const Color(0xFF2196F3), 18.5 / 40),
                _scaleSegment(const Color(0xFF4CAF50), 6.5 / 40),
                _scaleSegment(const Color(0xFFFF9800), 5 / 40),
                _scaleSegment(const Color(0xFFF44336), 10 / 40),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: Theme.of(context).textTheme.bodySmall),
            Text('18.5', style: Theme.of(context).textTheme.bodySmall),
            Text('25', style: Theme.of(context).textTheme.bodySmall),
            Text('30', style: Theme.of(context).textTheme.bodySmall),
            Text('40', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _scaleSegment(Color color, double flex) {
    return Expanded(
      flex: (flex * 100).round(),
      child: Container(color: color),
    );
  }
}
