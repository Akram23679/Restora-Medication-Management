import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../models.dart';
import '../widgets.dart';

class AddMedicationSheet extends StatefulWidget {
  final Medication? existing;

  const AddMedicationSheet({super.key, this.existing});

  @override
  State<AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<AddMedicationSheet> {
  final _uuid = const Uuid();
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  MedPeriod _period = MedPeriod.morning;
  String _iconName = 'medication';

  static const _icons = [
    ('medication', Icons.medication_outlined, 'Pill'),
    ('heart', Icons.favorite_outline, 'Heart'),
    ('spa', Icons.spa_outlined, 'Herb'),
    ('water', Icons.water_drop_outlined, 'Drop'),
    ('moon', Icons.nights_stay_outlined, 'Night'),
    ('brain', Icons.psychology_outlined, 'Mind'),
    ('leaf', Icons.eco_outlined, 'Plant'),
    ('eye', Icons.visibility_outlined, 'Vision'),
  ];

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final m = widget.existing!;
      _nameCtrl.text = m.name;
      _dosageCtrl.text = m.dosage;
      _purposeCtrl.text = m.purpose;
      _detailCtrl.text = m.detail;
      _period = m.period;
      _iconName = m.iconName;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _purposeCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_canSave) return;
    final med = Medication(
      id: widget.existing?.id ?? _uuid.v4(),
      name: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      purpose: _purposeCtrl.text.trim(),
      detail: _detailCtrl.text.trim().isEmpty
          ? '1 unit'
          : _detailCtrl.text.trim(),
      time: _period.defaultTime,
      period: _period,
      iconName: _iconName,
    );
    Navigator.of(context).pop(med);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: c.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.existing == null ? 'Add Medication' : 'Edit Medication',
              style: TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontSize: 26,
                  color: c.textDark),
            ),
            const SizedBox(height: 24),

            // Icon picker
            Text('ICON',
                style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: c.textLight)),
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final (name, icon, _) = _icons[i];
                  final selected = _iconName == name;
                  return GestureDetector(
                    onTap: () => setState(() => _iconName = name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: selected ? c.primary : c.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon,
                          color: selected ? Colors.white : c.textMid,
                          size: 22),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            RestoraTextField(
              label: 'Medication name *',
              controller: _nameCtrl,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: RestoraTextField(
                    label: 'Dosage (e.g. 500mg)',
                    controller: _dosageCtrl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RestoraTextField(
                    label: 'Detail (e.g. 1 capsule)',
                    controller: _detailCtrl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            RestoraTextField(
              label: 'Purpose / notes',
              controller: _purposeCtrl,
            ),
            const SizedBox(height: 20),

            // Period picker
            Text('WHEN TO TAKE',
                style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: c.textLight)),
            const SizedBox(height: 10),
            Row(
              children: MedPeriod.values.map((p) {
                final selected = _period == p;
                final isLast = p == MedPeriod.night;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _period = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(right: isLast ? 0 : 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? c.primary : c.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            p == MedPeriod.morning
                                ? Icons.wb_sunny_outlined
                                : p == MedPeriod.afternoon
                                    ? Icons.light_mode_outlined
                                    : p == MedPeriod.evening
                                        ? Icons.wb_twilight_outlined
                                        : Icons.nights_stay_outlined,
                            color: selected ? Colors.white : c.textMid,
                            size: 18,
                          ),
                          const SizedBox(height: 4),
                          Text(p.label,
                              style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 10,
                                  color:
                                      selected ? Colors.white : c.textMid)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            PrimaryButton(
              label: widget.existing == null
                  ? 'Add Medication'
                  : 'Save Changes',
              onTap: _save,
              enabled: _canSave,
            ),
          ],
        ),
      ),
    );
  }
}
