import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/plan_day.dart';
import '../state/app_state.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_icons.dart';

/// Screen 3 — work through "30 Days on Faith" and see progress.
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final done = state.planDoneCount;
    final left = planDays.length - done;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 18, 26, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProgressCard(done: done, left: left, progress: state.planProgress),
            const SizedBox(height: 20),
            Column(
              children: planDays
                  .map(
                    (day) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _DayRow(
                        day: day,
                        done: state.completedDays.contains(day.number),
                        onTap: () => state.togglePlanDay(day.number),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.done,
    required this.left,
    required this.progress,
  });

  final int done;
  final int left;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: p.planCardGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.planCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '30 Days on Faith',
            style: AppText.screenTitle(size: 25, color: p.textPrimary),
          ),
          const SizedBox(height: 5),
          Text(
            "You're $done days in. Keep going — a few minutes is enough.",
            style: AppText.secondary(color: p.warmBase.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: p.warmBase.withValues(alpha: 0.1)),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0, end: progress.clamp(0, 1)),
                    builder: (context, value, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: p.progressGradient),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day $done of ${planDays.length}',
                style: AppText.meta(color: p.warmBase.withValues(alpha: 0.5)),
              ),
              Text(
                '$left days to go',
                style: AppText.meta(color: p.warmBase.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.done, required this.onTap});

  final PlanDay day;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = done
        ? p.accent.withValues(alpha: 0.07)
        : p.warmBase.withValues(alpha: p.isDark ? 0.03 : 0.0);
    final border = done
        ? p.accent.withValues(alpha: 0.2)
        : p.rowBorder;
    final numBg = done
        ? p.accent.withValues(alpha: 0.16)
        : p.warmBase.withValues(alpha: p.isDark ? 0.05 : 0.04);
    final numFg = done ? p.accentText : p.warmBase.withValues(alpha: 0.55);
    final numBorder = done
        ? p.accent.withValues(alpha: 0.3)
        : p.warmBase.withValues(alpha: 0.1);
    final titleFg = done
        ? p.textPrimary
        : p.entryBodyBase.withValues(alpha: p.isDark ? 0.8 : 0.8);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: numBg,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: numBorder),
              ),
              child: Text('${day.number}', style: AppText.dayNumber(color: numFg)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day.theme, style: AppText.dayTitle(color: titleFg)),
                  const SizedBox(height: 3),
                  Text(
                    day.reference,
                    style: AppText.meta(
                      size: 12,
                      color: p.warmBase.withValues(alpha: p.isDark ? 0.4 : 0.68),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedScale(
              duration: const Duration(milliseconds: 160),
              scale: done ? 1 : 0.9,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done ? p.solidFill : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done
                        ? p.solidFill
                        : p.warmBase.withValues(alpha: 0.22),
                    width: 1.5,
                  ),
                ),
                child: done ? CheckIcon(color: p.onSolidFill) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
