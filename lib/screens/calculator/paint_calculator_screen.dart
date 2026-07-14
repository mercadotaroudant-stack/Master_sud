import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';

/// حاسبة كمية الصباغة: تُساعد صاحب المنزل والصباغ على تقدير عدد اللترات/
/// العلب اللازمة بناءً على أبعاد الغرفة، دون أي اتصال بـ Firebase — حساب
/// فوري بالكامل على الجهاز.
class PaintCalculatorScreen extends StatefulWidget {
  const PaintCalculatorScreen({super.key});

  @override
  State<PaintCalculatorScreen> createState() => _PaintCalculatorScreenState();
}

class _PaintCalculatorScreenState extends State<PaintCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController(text: '2.5');
  final _deductionController = TextEditingController(text: '0');
  final _coverageController = TextEditingController(text: '10');

  int _coats = 2;
  _CalculationResult? _result;

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _deductionController.dispose();
    _coverageController.dispose();
    super.dispose();
  }

  double _parse(String value) => double.tryParse(value.replaceAll(',', '.')) ?? 0;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final length = _parse(_lengthController.text);
    final width = _parse(_widthController.text);
    final height = _parse(_heightController.text);
    final deduction = _parse(_deductionController.text);
    final coverage = _parse(_coverageController.text);

    final grossWallArea = 2 * (length + width) * height;
    final netWallArea = (grossWallArea - deduction).clamp(0, double.infinity);
    final effectiveCoverage = coverage <= 0 ? 10 : coverage;
    final litersNeeded = (netWallArea * _coats) / effectiveCoverage;
    final buckets15L = (litersNeeded / 15).ceil();
    final buckets5L = (litersNeeded / 5).ceil();

    setState(() {
      _result = _CalculationResult(
        wallArea: netWallArea.toDouble(),
        liters: litersNeeded,
        buckets15L: buckets15L,
        buckets5L: buckets5L,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculateur de peinture')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.paddingMd),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Estimez la quantité de peinture nécessaire pour votre pièce.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimens.paddingLg),
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        controller: _lengthController,
                        label: 'Longueur (m)',
                      ),
                    ),
                    const SizedBox(width: AppDimens.paddingSm),
                    Expanded(
                      child: _NumberField(
                        controller: _widthController,
                        label: 'Largeur (m)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingSm),
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        controller: _heightController,
                        label: 'Hauteur (m)',
                      ),
                    ),
                    const SizedBox(width: AppDimens.paddingSm),
                    Expanded(
                      child: _NumberField(
                        controller: _deductionController,
                        label: 'Portes/fenêtres (m²)',
                        required: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingSm),
                _NumberField(
                  controller: _coverageController,
                  label: 'Rendement de la peinture (m²/L)',
                  helperText: 'Indiqué sur le pot du produit choisi. 10 m²/L par défaut.',
                ),
                const SizedBox(height: AppDimens.paddingMd),
                const Text(
                  'Nombre de couches',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('1 couche')),
                    ButtonSegment(value: 2, label: Text('2 couches')),
                  ],
                  selected: {_coats},
                  onSelectionChanged: (value) => setState(() => _coats = value.first),
                ),
                const SizedBox(height: AppDimens.paddingLg),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
                  ),
                  onPressed: _calculate,
                  child: const Text('Calculer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                if (_result != null) ...[
                  const SizedBox(height: AppDimens.paddingLg),
                  _ResultCard(result: _result!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculationResult {
  final double wallArea;
  final double liters;
  final int buckets15L;
  final int buckets5L;

  const _CalculationResult({
    required this.wallArea,
    required this.liters,
    required this.buckets15L,
    required this.buckets5L,
  });
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final bool required;

  const _NumberField({
    required this.controller,
    required this.label,
    this.helperText,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperMaxLines: 2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSm)),
        filled: true,
        fillColor: AppColors.background,
      ),
      validator: (value) {
        if (!required) return null;
        final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
        if (parsed == null || parsed <= 0) return 'Valeur requise';
        return null;
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _CalculationResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résultat estimatif',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          _ResultRow(label: 'Surface à peindre', value: '${result.wallArea.toStringAsFixed(1)} m²'),
          _ResultRow(label: 'Peinture nécessaire', value: '${result.liters.toStringAsFixed(1)} L'),
          _ResultRow(label: 'Soit environ', value: '${result.buckets15L} pot(s) de 15 L'),
          _ResultRow(label: 'Ou environ', value: '${result.buckets5L} pot(s) de 5 L'),
          const SizedBox(height: 10),
          const Text(
            'Estimation indicative — le rendement réel varie selon le support et le produit. '
            'Demandez conseil dans nos showrooms pour ajuster la quantité.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ],
      ),
    );
  }
}
