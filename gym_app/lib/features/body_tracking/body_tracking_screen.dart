import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/providers/body_tracking_provider.dart';
import 'package:gym_app/core/providers/auth_provider.dart';
import 'package:gym_app/core/models/body_measurement_model.dart';

class BodyTrackingScreen extends ConsumerStatefulWidget {
  const BodyTrackingScreen({super.key});
  @override
  ConsumerState<BodyTrackingScreen> createState() => _BodyTrackingScreenState();
}

class _BodyTrackingScreenState extends ConsumerState<BodyTrackingScreen> {
  String _period = '1M';
  final _periods = ['1S', '1M', '3M', '6M', '1A'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bodyTrackingProvider);
    final spots = ref.watch(weightHistoryProvider);
    final latest = ref.watch(latestMeasurementProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Seguimiento Corporal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: () => _showAddMeasurement(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(children: [
            _SummaryCard(
                label: 'Peso actual',
                value: latest?.weight != null ? '${latest!.weight!.toStringAsFixed(1)} kg' : '--',
                sub: 'Última medición',
                color: AppColors.primary).animate().fadeIn(delay: 50.ms),
            const Gap(8),
            _SummaryCard(
                label: 'IMC',
                value: latest?.bmi != null ? latest!.bmi!.toStringAsFixed(1) : '--',
                sub: latest?.bmi != null ? _bmiCategory(latest!.bmi!) : '--',
                color: AppColors.accent).animate().fadeIn(delay: 100.ms),
            const Gap(8),
            _SummaryCard(
                label: 'Grasa corp.',
                value: latest?.bodyFat != null ? '${latest!.bodyFat!.toStringAsFixed(1)}%' : '--',
                sub: 'Porcentaje',
                color: AppColors.warning).animate().fadeIn(delay: 150.ms),
          ]),
          const Gap(20),

          // Weight chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Historial de Peso', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                Row(children: _periods.map((p) {
                  final sel = _period == p;
                  return GestureDetector(
                    onTap: () => setState(() => _period = p),
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(p, style: TextStyle(color: sel ? Colors.white : AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList()),
              ]),
              const Gap(16),
              SizedBox(
                height: 180,
                child: spots.isEmpty
                    ? const Center(child: Text('Sin datos aún', style: TextStyle(color: AppColors.textMuted)))
                    : LineChart(LineChartData(
                        lineBarsData: [LineChartBarData(
                          spots: spots,
                          isCurved: true, color: AppColors.primary, barWidth: 3,
                          belowBarData: BarAreaData(show: true, gradient: LinearGradient(
                            colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0)],
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          )),
                          dotData: FlDotData(show: true, getDotPainter: (s, _, __, ___) =>
                              FlDotCirclePainter(radius: 3, color: AppColors.primary, strokeWidth: 0)),
                        )],
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true, drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 44,
                              getTitlesWidget: (v, _) => Text('${v.toInt()}kg', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)))),
                          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => AppColors.cardElevated,
                            getTooltipItems: (spots) => spots.map((s) =>
                                LineTooltipItem('${s.y.toStringAsFixed(1)} kg',
                                    const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))).toList(),
                          ),
                        ),
                      )),
              ),
            ]),
          ),
          const Gap(16),

          // Measurements grid
          if (latest != null) ...[
            const Text('Última Medición', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
            const Gap(12),
            _MeasurementGrid(measurement: latest).animate().fadeIn(),
            const Gap(16),
          ],

          // History list
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Historial', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
            Text('${state.measurements.length} registros', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ]),
          const Gap(12),
          ...state.measurements.asMap().entries.map((e) =>
              _MeasurementCard(m: e.value, onDelete: () =>
                  ref.read(bodyTrackingProvider.notifier).deleteMeasurement(e.value.id))
                  .animate(delay: (e.key * 40).ms).fadeIn()),
          const Gap(80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMeasurement(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Registrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  void _showAddMeasurement(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddMeasurementSheet(
        onSave: (m) => ref.read(bodyTrackingProvider.notifier).addMeasurement(m),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value, sub; final Color color;
  const _SummaryCard({required this.label, required this.value, required this.sub, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const Gap(4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
        Text(sub, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ]),
    ),
  );
}

class _MeasurementGrid extends StatelessWidget {
  final BodyMeasurement measurement;
  const _MeasurementGrid({required this.measurement});
  @override
  Widget build(BuildContext context) {
    final items = <String, double?>{
      'Cuello': measurement.neck, 'Hombros': measurement.shoulders,
      'Pecho': measurement.chest, 'Cintura': measurement.waist,
      'Cadera': measurement.hips, 'Bícep Izq.': measurement.leftBicep,
      'Bícep Der.': measurement.rightBicep, 'Muslo Izq.': measurement.leftThigh,
      'Muslo Der.': measurement.rightThigh,
    };
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: items.entries.where((e) => e.value != null).map((e) =>
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              Text(e.key, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const Gap(2),
              Text('${e.value!.toStringAsFixed(1)} cm',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
            ]),
          )).toList(),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final BodyMeasurement m; final VoidCallback onDelete;
  const _MeasurementCard({required this.m, required this.onDelete});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Row(children: [
      const Icon(Icons.monitor_weight_outlined, color: AppColors.primary, size: 24),
      const Gap(12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${m.date.day}/${m.date.month}/${m.date.year}',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        if (m.weight != null) Text('${m.weight!.toStringAsFixed(1)} kg',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ])),
      if (m.bodyFat != null) Text('${m.bodyFat!.toStringAsFixed(1)}% grasa',
          style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600)),
      IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20), onPressed: onDelete),
    ]),
  );
}

class _AddMeasurementSheet extends ConsumerStatefulWidget {
  final void Function(BodyMeasurement) onSave;
  const _AddMeasurementSheet({required this.onSave});
  @override
  ConsumerState<_AddMeasurementSheet> createState() => _AddMeasurementSheetState();
}

class _AddMeasurementSheetState extends ConsumerState<_AddMeasurementSheet> {
  final _weight = TextEditingController();
  final _bf = TextEditingController();
  final _neck = TextEditingController();
  final _chest = TextEditingController();
  final _waist = TextEditingController();
  final _hips = TextEditingController();
  final _bicepL = TextEditingController();
  final _bicepR = TextEditingController();
  final _thighL = TextEditingController();
  final _thighR = TextEditingController();
  final _notes = TextEditingController();

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.75, maxChildSize: 0.95, minChildSize: 0.5, expand: false,
    builder: (_, ctrl) => ListView(controller: ctrl, padding: EdgeInsets.only(
        left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
        const Gap(16),
        const Text('Registrar Medidas', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
        const Gap(20),
        Row(children: [
          Expanded(child: _TF('Peso (kg)', _weight, keyboard: TextInputType.number)),
          const Gap(12),
          Expanded(child: _TF('Grasa corp. (%)', _bf, keyboard: TextInputType.number)),
        ]),
        const Gap(12),
        const Text('Medidas en cm', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const Gap(8),
        Row(children: [
          Expanded(child: _TF('Cuello', _neck, keyboard: TextInputType.number)),
          const Gap(8),
          Expanded(child: _TF('Pecho', _chest, keyboard: TextInputType.number)),
          const Gap(8),
          Expanded(child: _TF('Cintura', _waist, keyboard: TextInputType.number)),
          const Gap(8),
          Expanded(child: _TF('Cadera', _hips, keyboard: TextInputType.number)),
        ]),
        const Gap(8),
        Row(children: [
          Expanded(child: _TF('Bícep Izq.', _bicepL, keyboard: TextInputType.number)),
          const Gap(8),
          Expanded(child: _TF('Bícep Der.', _bicepR, keyboard: TextInputType.number)),
          const Gap(8),
          Expanded(child: _TF('Muslo Izq.', _thighL, keyboard: TextInputType.number)),
          const Gap(8),
          Expanded(child: _TF('Muslo Der.', _thighR, keyboard: TextInputType.number)),
        ]),
        const Gap(12),
        _TF('Notas (opcional)', _notes, maxLines: 3),
        const Gap(20),
        ElevatedButton(onPressed: _save, child: const Text('Guardar Medidas')),
      ],
    ),
  );

  Widget _TF(String label, TextEditingController ctrl, {TextInputType? keyboard, int? maxLines}) =>
      TextField(controller: ctrl, keyboardType: keyboard, maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(labelText: label, isDense: true, contentPadding: const EdgeInsets.all(12)));

  void _save() {
    final user = ref.read(authProvider).user;
    final m = BodyMeasurement(
      id: const Uuid().v4(),
      memberId: user?.id ?? '',
      date: DateTime.now(),
      weight: double.tryParse(_weight.text),
      bodyFat: double.tryParse(_bf.text),
      neck: double.tryParse(_neck.text),
      chest: double.tryParse(_chest.text),
      waist: double.tryParse(_waist.text),
      hips: double.tryParse(_hips.text),
      leftBicep: double.tryParse(_bicepL.text),
      rightBicep: double.tryParse(_bicepR.text),
      leftThigh: double.tryParse(_thighL.text),
      rightThigh: double.tryParse(_thighR.text),
      notes: _notes.text.isEmpty ? null : _notes.text,
    );
    widget.onSave(m);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medidas guardadas ✓')));
  }
}
