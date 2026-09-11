import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';

/// Screen 4 — preview the home-screen widget sizes and pick one.
///
/// The real widgets are platform surfaces (WidgetKit on iOS, Glance on
/// Android) rendered by the OS, not by this Flutter view — this screen is
/// the in-app preview/picker described in the design, with a static mockup
/// of each size. Wiring the actual home-screen widgets is a
/// platform-channel / native-target task outside a single Flutter widget
/// tree.
class WidgetScreen extends StatelessWidget {
  const WidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final state = context.watch<AppState>();

    return Container(
      decoration: BoxDecoration(gradient: p.widgetTabBg),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Widgets', style: AppText.screenTitle(size: 25, color: p.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      'Choose how the verse meets you on your home screen.',
                      style: AppText.secondary(color: p.warmBase.withValues(alpha: 0.55)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _SectionLabel(label: 'LARGE', size: '4 × 2'),
              const SizedBox(height: 11),
              _LargeWidgetCard(streak: state.streak),
              const SizedBox(height: 22),
              _SectionLabel(label: 'SMALL', size: '2 × 2'),
              const SizedBox(height: 11),
              _SmallWidgetRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.size});
  final String label;
  final String size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.eyebrow(color: p.warmBase.withValues(alpha: 0.62))),
          Text(size, style: AppText.meta(color: p.warmBase.withValues(alpha: 0.35))),
        ],
      ),
    );
  }
}

class _LargeWidgetCard extends StatelessWidget {
  const _LargeWidgetCard({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(
          gradient: p.widgetCardGradientLarge,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: p.isDark ? 0.45 : 0.14),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -60,
              child: Container(
                width: 280,
                height: 230,
                decoration: BoxDecoration(gradient: p.widgetGlowLarge),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(colors: p.buttonGradient),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'JOHN 3:16',
                      style: AppText.widgetEyebrow(
                        color: p.accentText.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'For God so loved the world, that he gave his only '
                  'begotten Son…',
                  style: AppText.widgetVerse(size: 19, color: p.textPrimary),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'John 3:16 · KJV',
                      style: AppText.meta(color: p.warmBase.withValues(alpha: 0.5)),
                    ),
                    Text(
                      '$streak-day streak',
                      style: AppText.meta(
                        weight: 500,
                        color: p.accentText.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallWidgetRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Container(
            width: 158,
            height: 158,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: p.widgetCardGradientSmall,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: p.isDark ? 0.45 : 0.14),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: -70,
                  left: -30,
                  child: Container(
                    width: 200,
                    height: 170,
                    decoration: BoxDecoration(gradient: p.widgetGlowSmall),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'God so loved the world…',
                      style: AppText.widgetVerse(size: 15, color: p.textPrimary),
                    ),
                    Text(
                      'JOHN 3:16',
                      style: AppText.widgetEyebrow(
                        size: 10.5,
                        color: p.accentText.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: p.widgetCardGradientSmall,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: p.isDark ? 0.4 : 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text('3:16', style: AppText.iconNumeral(size: 20, color: p.accentText)),
              ),
              const SizedBox(height: 7),
              Text(
                'John 3:16',
                style: AppText.meta(size: 10.5, color: p.warmBase.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 14),
              Text(
                'Refreshes each morning at 6 am.',
                textAlign: TextAlign.center,
                style: AppText.meta(
                  size: 12,
                  color: p.warmBase.withValues(alpha: p.isDark ? 0.4 : 0.68),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
