import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utility_hub/features/tip_calculator/domain/tip_calculator_service.dart';

final tipResultProvider = StateProvider<TipResult?>((ref) => null);

class TipCalculatorScreen extends ConsumerStatefulWidget {
  const TipCalculatorScreen({super.key});

  @override
  ConsumerState<TipCalculatorScreen> createState() =>
      _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends ConsumerState<TipCalculatorScreen> {
  final _billController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double _tipPercentage = 15;
  int _splitCount = 1;

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final bill = double.parse(_billController.text.trim());
    final result = TipCalculatorService.calculate(
      billAmount: bill,
      tipPercentage: _tipPercentage,
      splitCount: _splitCount,
    );
    ref.read(tipResultProvider.notifier).state = result;
  }

  void _clear() {
    _billController.clear();
    setState(() {
      _tipPercentage = 15;
      _splitCount = 1;
    });
    ref.read(tipResultProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(tipResultProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tip Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bill input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bill Amount',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _billController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          prefixText: '\$ ',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.receipt_long_rounded),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          final v = double.tryParse(val.trim());
                          if (v == null || v <= 0) return 'Enter a valid amount';
                          return null;
                        },
                        onChanged: (_) => _calculate(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tip percentage
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tip',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_tipPercentage.round()}%',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _tipPercentage,
                        min: 0,
                        max: 50,
                        divisions: 50,
                        label: '${_tipPercentage.round()}%',
                        onChanged: (val) {
                          setState(() => _tipPercentage = val);
                          _calculate();
                        },
                      ),
                      const SizedBox(height: 8),
                      // Quick tip buttons
                      Row(
                        children: [10.0, 15.0, 18.0, 20.0, 25.0].map((pct) {
                          final isSelected = _tipPercentage == pct;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: ChoiceChip(
                                label: Text('${pct.round()}%'),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() => _tipPercentage = pct);
                                  _calculate();
                                },
                                selectedColor: colorScheme.primaryContainer,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurfaceVariant,
                                ),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Split
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Split',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton.outlined(
                            onPressed: _splitCount > 1
                                ? () {
                                    setState(() => _splitCount--);
                                    _calculate();
                                  }
                                : null,
                            icon: const Icon(Icons.remove),
                            visualDensity: VisualDensity.compact,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$_splitCount',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton.outlined(
                            onPressed: () {
                              setState(() => _splitCount++);
                              _calculate();
                            },
                            icon: const Icon(Icons.add),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Buttons
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
                      child: const Text('Calculate'),
                    ),
                  ),
                ],
              ),

              // Result
              if (result != null) ...[
                const SizedBox(height: 24),
                _TipResultCard(result: result, splitCount: _splitCount),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TipResultCard extends StatelessWidget {
  final TipResult result;
  final int splitCount;

  const _TipResultCard({required this.result, required this.splitCount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _resultRow(context, 'Tip Amount', result.tipAmount),
            const SizedBox(height: 12),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 12),
            _resultRow(context, 'Total', result.totalAmount),
            if (splitCount > 1) ...[
              const SizedBox(height: 12),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 12),
              _resultRow(context, 'Per Person', result.perPerson, highlight: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _resultRow(BuildContext context, String label, double value,
      {bool highlight = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: highlight ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
