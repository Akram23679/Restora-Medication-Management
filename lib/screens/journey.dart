import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../provider.dart';
import '../widgets.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  DateTime _month = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(
        const Duration(milliseconds: 300), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final c = context.colors;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RestoraAppBar(
                subtitle: 'YOUR JOURNEY — ADHERENCE HISTORY',
                showSettings: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your\nJourney',
                      style: TextStyle(
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          fontSize: 40,
                          color: c.textDark,
                          height: 1.1)),
                  const SizedBox(height: 10),
                  Text(
                      'Reflecting on your habits. Consistency is the foundation of healing.',
                      style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          color: c.textMid,
                          height: 1.5)),
                  const SizedBox(height: 24),

                  // ── Adherence Rate
                  RestoraCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MONTHLY OVERVIEW',
                            style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: c.textLight)),
                        const SizedBox(height: 6),
                        Text('Adherence Rate',
                            style: TextStyle(
                                fontFamily: 'Georgia',
                                fontStyle: FontStyle.italic,
                                fontSize: 18,
                                color: c.textDark)),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AnimatedBuilder(
                              animation: _anim,
                              builder: (_, __) {
                                final rate = (provider.adherenceRate *
                                        100 *
                                        _anim.value)
                                    .round();
                                return Text('$rate',
                                    style: TextStyle(
                                        fontFamily: 'Georgia',
                                        fontStyle: FontStyle.italic,
                                        fontSize: 56,
                                        color: c.textDark));
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(' %',
                                  style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 20,
                                      color: c.textDark)),
                            ),
                            const SizedBox(width: 16),
                            if (provider.adherenceRate > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Icon(Icons.trending_up,
                                        color: c.primary, size: 16),
                                    const SizedBox(width: 4),
                                    Text('improving',
                                        style: TextStyle(
                                            fontFamily: 'Arial',
                                            fontSize: 12,
                                            color: c.primary)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Streak Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: c.primary,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color:
                                      c.primaryMuted.withValues(alpha: 0.1),
                                  width: 2)),
                          child: Icon(Icons.auto_awesome,
                              color: c.primaryMuted, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text('${provider.currentStreak} Day Streak',
                            style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontStyle: FontStyle.italic,
                                fontSize: 28,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          provider.currentStreak > 0
                              ? 'KEEP IT UP'
                              : 'START TODAY',
                          style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 10,
                              letterSpacing: 2,
                              color: c.primaryMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Calendar
                  _MonthCalendar(
                    month: _month,
                    selectedDay: _selectedDay,
                    provider: provider,
                    onDayTap: (d) => setState(() => _selectedDay = d),
                    onPrev: () => setState(() =>
                        _month = DateTime(_month.year, _month.month - 1)),
                    onNext: () => setState(() =>
                        _month = DateTime(_month.year, _month.month + 1)),
                  ),

                  // ── Selected day detail
                  if (_selectedDay != null) ...[
                    const SizedBox(height: 20),
                    _DayDetail(day: _selectedDay!, provider: provider),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full Month Calendar ───────────────────────────────────────────────────────
class _MonthCalendar extends StatelessWidget {
  final DateTime month;
  final DateTime? selectedDay;
  final AppProvider provider;
  final ValueChanged<DateTime> onDayTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthCalendar({
    required this.month,
    required this.selectedDay,
    required this.provider,
    required this.onDayTap,
    required this.onPrev,
    required this.onNext,
  });

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now();
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;
    final startOffset = firstDay.weekday - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_months[month.month - 1]} ${month.year}',
                style: TextStyle(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontSize: 22,
                    color: c.textDark)),
            Row(
              children: [
                GestureDetector(
                    onTap: onPrev,
                    child: Icon(Icons.chevron_left,
                        color: c.textMid, size: 26)),
                const SizedBox(width: 4),
                GestureDetector(
                    onTap: onNext,
                    child: Icon(Icons.chevron_right,
                        color: c.textMid, size: 26)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Day-of-week labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(d,
                          style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: c.textLight)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // Day grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, childAspectRatio: 1),
          itemCount: startOffset + daysInMonth,
          itemBuilder: (_, i) {
            if (i < startOffset) return const SizedBox.shrink();
            final dayNum = i - startOffset + 1;
            final day = DateTime(month.year, month.month, dayNum);
            final isToday = day.year == now.year &&
                day.month == now.month &&
                day.day == now.day;
            final isSelected = selectedDay != null &&
                day.year == selectedDay!.year &&
                day.month == selectedDay!.month &&
                day.day == selectedDay!.day;
            final isFuture = day.isAfter(now);
            final status =
                isFuture ? null : provider.dayStatus(day);

            return GestureDetector(
              onTap: () => onDayTap(day),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? c.primary
                        : status == true
                            ? c.primary.withValues(alpha: 0.15)
                            : isToday
                                ? Colors.transparent
                                : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: c.primary, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 13,
                        fontWeight: isToday
                            ? FontWeight.w700
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : status == true
                                ? c.primary
                                : status == false
                                    ? c.errorColor.withValues(alpha: 0.8)
                                    : isFuture
                                        ? c.textLight
                                        : c.textMid,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Legend
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(context, context.colors.primary.withValues(alpha: 0.15),
                'All taken'),
            const SizedBox(width: 20),
            _legend(
                context,
                context.colors.errorColor.withValues(alpha: 0.15),
                'Missed'),
            const SizedBox(width: 20),
            _legend(context, Colors.transparent, 'Today',
                border: true),
          ],
        ),
      ],
    );
  }

  Widget _legend(BuildContext ctx, Color color, String label,
      {bool border = false}) {
    final c = ctx.colors;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border:
                border ? Border.all(color: c.primary, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontFamily: 'Arial', fontSize: 11, color: c.textMid)),
      ],
    );
  }
}

// ── Day Detail ────────────────────────────────────────────────────────────────
class _DayDetail extends StatelessWidget {
  final DateTime day;
  final AppProvider provider;

  const _DayDetail({required this.day, required this.provider});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final logs = provider.doseLogs;

    return RestoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_months[day.month - 1]} ${day.day}, ${day.year}',
              style: TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                  color: c.textDark)),
          const SizedBox(height: 4),
          Text('DAILY SUMMARY',
              style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 10,
                  letterSpacing: 1.2,
                  color: c.textLight)),
          const SizedBox(height: 16),
          if (provider.medications.isEmpty)
            Text('No medications tracked.',
                style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    color: c.textMid))
          else
            ...provider.medications.map((med) {
              final taken = logs.any((l) =>
                  l.medicationId == med.id &&
                  l.takenAt.year == day.year &&
                  l.takenAt.month == day.month &&
                  l.takenAt.day == day.day &&
                  l.taken);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      taken
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: taken ? c.primary : c.textLight,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Icon(medIcon(med.iconName),
                        color: taken ? c.primary : c.textLight,
                        size: 16),
                    const SizedBox(width: 8),
                    Text('${med.name} ${med.dosage}',
                        style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            color: taken ? c.textDark : c.textLight)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}