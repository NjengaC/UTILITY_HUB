import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utility_hub/features/unit_converter/domain/conversion_model.dart';
import 'package:utility_hub/features/unit_converter/domain/converter_utils.dart';
import 'package:utility_hub/features/unit_converter/presentation/converter_provider.dart';

class UnitConverterScreen extends ConsumerStatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  ConsumerState<UnitConverterScreen> createState() =>
      _UnitConverterScreenState();
}

class _UnitConverterScreenState extends ConsumerState<UnitConverterScreen> {
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(converterProvider);
    final notifier = ref.read(converterProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Unit Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ConversionCategory.values.map((cat) {
                  final isSelected = state.category == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(ConverterUtils.categoryLabel(cat)),
                      onSelected: (_) => notifier.setCategory(cat),
                      selectedColor: colorScheme.primaryContainer,
                      checkmarkColor: colorScheme.onPrimaryContainer,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Loading indicator for currency
            if (state.isLoadingRates)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),

            // From section
            _buildUnitSection(
              context: context,
              label: 'From',
              selectedUnit: state.fromUnit,
              units: state.availableUnits,
              onChanged: notifier.setFromUnit,
              inputController: _inputController,
              onValueChanged: (val) {
                final parsed = double.tryParse(val) ?? 0;
                notifier.setInputValue(parsed);
              },
            ),
            const SizedBox(height: 16),

            // Swap button
            Center(
              child: IconButton.filled(
                onPressed: () {
                  notifier.swapUnits();
                  final resultText = _formatResult(state.result);
                  _inputController.text = resultText;
                  notifier.setInputValue(state.result);
                },
                icon: const Icon(Icons.swap_vert_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // To section
            _buildResultSection(
              context: context,
              label: 'To',
              selectedUnit: state.toUnit,
              units: state.availableUnits,
              onChanged: notifier.setToUnit,
              result: state.result,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSection({
    required BuildContext context,
    required String label,
    required ConversionUnit selectedUnit,
    required List<ConversionUnit> units,
    required ValueChanged<ConversionUnit> onChanged,
    required TextEditingController inputController,
    required ValueChanged<String> onValueChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ConversionUnit>(
              value: selectedUnit,
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: units.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text('${unit.name} (${unit.symbol})'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: inputController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter value',
                suffixText: selectedUnit.symbol,
              ),
              onChanged: onValueChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection({
    required BuildContext context,
    required String label,
    required ConversionUnit selectedUnit,
    required List<ConversionUnit> units,
    required ValueChanged<ConversionUnit> onChanged,
    required double result,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ConversionUnit>(
              value: selectedUnit,
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: units.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text('${unit.name} (${unit.symbol})'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_formatResult(result)} ${selectedUnit.symbol}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatResult(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e12) {
      return value.toStringAsFixed(0);
    }
    // Show up to 6 decimal places but trim trailing zeros
    String formatted = value.toStringAsFixed(6);
    formatted = formatted.replaceAll(RegExp(r'0+$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    return formatted;
  }
}
