import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models.dart';
import '../provider.dart';
import '../widgets.dart';
import 'med_detail.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final c = context.colors;

    if (provider.isLoading) return _Shimmer();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RestoraAppBar(subtitle: 'TODAY — YOUR DAILY RITUAL'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_dateLabel(),
                      style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 10,
                          letterSpacing: 1.8,
                          color: c.textLight)),
                  const SizedBox(height: 12),
                  Text(
                    '${provider.greeting},\n${provider.profile?.name ?? "Friend"}',
                    style: TextStyle(
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                        fontSize: 44,
                        color: c.textDark,
                        height: 1.1),
                  ),
                  const SizedBox(height: 12),
                  Text(provider.greetingSubtitle,
                      style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          color: c.textMid,
                          height: 1.5)),
                  const SizedBox(height: 24),

                  if (provider.medications.isEmpty)
                    const EmptyState(
                      icon: Icons.medication_outlined,
                      title: 'No medications yet',
                      subtitle:
                          'Go to the Meds tab to add your first medication.',
                    )
                  else ...[
                    _ProgressCard(provider: provider),
                    const SizedBox(height: 16),
                    _NextDoseCard(provider: provider),
                    const SizedBox(height: 28),
                    ...MedPeriod.values.map((period) {
                      final meds = provider.medsForPeriod(period);
                      if (meds.isEmpty) return const SizedBox.shrink();
                      return _PeriodSection(
                          period: period,
                          meds: meds,
                          provider: provider);
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel() {
    final d = DateTime.now();
    const days = [
      'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY',
      'FRIDAY', 'SATURDAY', 'SUNDAY'
    ];
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    return '${days[d.weekday - 1]} · ${months[d.month - 1]} ${d.day}';
  }
}

// ── Progress Card ─────────────────────────────────────────────────────────────
class _ProgressCard extends StatefulWidget {
  final AppProvider provider;
  const _ProgressCard({required this.provider});

  @override
  State<_ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<_ProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(
        const Duration(milliseconds: 200),
        () => _ctrl.animateTo(widget.provider.todayProgress));
  }

  @override
  void didUpdateWidget(_ProgressCard old) {
    super.didUpdateWidget(old);
    _ctrl.animateTo(widget.provider.todayProgress);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = widget.provider;
    return RestoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TODAY'S PRACTICE",
              style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: c.textLight)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '${p.dosesToday} ',
                        style: TextStyle(
                            fontFamily: 'Georgia',
                            fontStyle: FontStyle.italic,
                            fontSize: 42,
                            color: c.textDark),
                      ),
                      TextSpan(
                        text: 'of ${p.totalDosesToday}',
                        style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 16,
                            color: c.textMid),
                      ),
                    ]),
                  ),
                  Text('doses completed',
                      style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          color: c.textMid)),
                ],
              ),
              AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => SizedBox(
                  width: 60,
                  height: 60,
                  child: CustomPaint(
                    painter: _ArcPainter(
                      progress: _anim.value,
                      fg: c.primary,
                      bg: c.progressBg,
                    ),
                    child: Center(
                      child: Text(
                        '${(p.todayProgress * 100).round()}%',
                        style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.textDark),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _anim.value,
                backgroundColor: c.progressBg,
                valueColor: AlwaysStoppedAnimation(c.primary),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Next Dose Card ────────────────────────────────────────────────────────────
class _NextDoseCard extends StatelessWidget {
  final AppProvider provider;
  const _NextDoseCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (provider.dosesToday >= provider.totalDosesToday) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: c.primary, borderRadius: BorderRadius.circular(16)),
        child: const Row(
          children: [
             Icon(Icons.check_circle_outline,
                color: Colors.white, size: 28),
             SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("All done for today!",
                      style:  TextStyle(
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          fontSize: 20,
                          color: Colors.white)),
                  Text("Every dose taken. Excellent.",
                      style:  TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 13,
                          color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final med = provider.nextMedication;
    if (med == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: c.primary, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NEXT DOSE',
              style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: c.primaryMuted)),
          const SizedBox(height: 8),
          Text(med.name,
              style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontSize: 26,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text('${med.time} · ${med.detail} · ${med.period.label}',
              style: TextStyle(
                  fontFamily: 'Arial', fontSize: 13, color: c.primaryMuted)),
          const SizedBox(height: 20),
          Row(
            children: [
              _btn(context,
                  label: 'Mark Taken',
                  icon: Icons.check,
                  filled: true,
                  onTap: () =>
                      context.read<AppProvider>().markDoseTaken(med.id)),
              const SizedBox(width: 12),
              _btn(context,
                  label: 'Snooze',
                  filled: false,
                  onTap: () =>
                      context.read<AppProvider>().skipDose(med.id)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(BuildContext ctx,
      {required String label,
      IconData? icon,
      required bool filled,
      required VoidCallback onTap}) {
    final c = ctx.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: filled ? c.primary : Colors.white, size: 16),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: filled ? c.primary : Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ── Period Section ────────────────────────────────────────────────────────────
class _PeriodSection extends StatelessWidget {
  final MedPeriod period;
  final List<Medication> meds;
  final AppProvider provider;

  const _PeriodSection(
      {required this.period, required this.meds, required this.provider});

  @override
  Widget build(BuildContext context) {
    final done = meds.where((m) => provider.isTakenToday(m.id)).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
            title: period.label, trailing: '$done/${meds.length} Complete'),
        const SizedBox(height: 12),
        ...meds.map((med) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MedItem(med: med, provider: provider),
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ── Med Item ──────────────────────────────────────────────────────────────────
class _MedItem extends StatelessWidget {
  final Medication med;
  final AppProvider provider;

  const _MedItem({required this.med, required this.provider});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final taken = provider.isTakenToday(med.id);

    return RestoraCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => MedDetailScreen(med: med))),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: taken
                  ? c.primary.withValues(alpha: 0.12)
                  : c.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(medIcon(med.iconName),
                color: taken ? c.primary : c.textMid, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${med.name} ${med.dosage}',
                    style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 15,
                        color: taken ? c.textMid : c.textDark)),
                const SizedBox(height: 2),
                Text('${med.time} · ${med.detail}',
                    style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        color: c.textLight)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (taken) {
                context.read<AppProvider>().undoDose(med.id);
              } else {
                context.read<AppProvider>().markDoseTaken(med.id);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: taken ? c.primary : c.progressBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                taken ? Icons.check : Icons.add,
                color: taken ? Colors.white : c.textLight,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Arc Painter ───────────────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color fg, bg;
  const _ArcPainter({required this.progress, required this.fg, required this.bg});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 5;
    const sw = 5.0;

    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = bg
          ..strokeWidth = sw
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = fg
          ..strokeWidth = sw
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ── Shimmer Loading ───────────────────────────────────────────────────────────
class _Shimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             SizedBox(height: 60),
             ShimmerCard(height: 130),
             SizedBox(height: 16),
             ShimmerCard(height: 170),
             SizedBox(height: 16),
             ShimmerCard(height: 80),
             SizedBox(height: 10),
             ShimmerCard(height: 80),
          ],
        ),
      ),
    );
  }
}