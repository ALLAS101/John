import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/verse.dart';
import '../state/app_state.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';
import '../utils/date_format.dart';
import '../widgets/app_icons.dart';
import '../widgets/controls.dart';
import '../widgets/dawn_glow.dart';

/// Screen 1 — read the day's verse, hear it, save it, keep the streak.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final state = context.watch<AppState>();
    final today = DateTime.now();

    return Stack(
      children: [
        DawnGlow(gradient: p.dawnGlow),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 18, 26, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${greetingForHour(today.hour)}, '
                            '${state.userName}',
                            style: AppText.greeting(color: p.warmBase),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fullDayMonth(today),
                            style: AppText.secondary(
                              color: p.warmBase.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    StreakPill(days: state.streak),
                  ],
                ),
                const SizedBox(height: 26),
                _VerseCard(
                  verse: state.verseOfDay,
                  saved: state.isSaved,
                  onToggleSave: state.toggleSaved,
                  isPlaying: state.isPlayingVerse,
                  isPreparing: state.isPreparingVerseAudio,
                  playbackProgress: state.versePlaybackProgress,
                  onTogglePlayback: state.toggleVersePlayback,
                  ttsError: state.ttsError,
                  onDismissTtsError: state.dismissTtsError,
                ),
                const SizedBox(height: 26),
                _ReflectionBlock(
                  onWriteAboutThis: (prompt) =>
                      state.openJournalWithPrompt(prompt),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard({
    required this.verse,
    required this.saved,
    required this.onToggleSave,
    required this.isPlaying,
    required this.isPreparing,
    required this.playbackProgress,
    required this.onTogglePlayback,
    required this.ttsError,
    required this.onDismissTtsError,
  });

  final Verse verse;
  final bool saved;
  final VoidCallback onToggleSave;
  final bool isPlaying;
  final bool isPreparing;
  final double playbackProgress;
  final Future<void> Function() onTogglePlayback;
  final String? ttsError;
  final VoidCallback onDismissTtsError;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: p.elevatedSurfaceGradient,
        border: Border.all(color: p.cardBorder),
        boxShadow: [p.elevatedSurfaceShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VERSE OF THE DAY', style: AppText.eyebrow(color: p.accentText)),
          const SizedBox(height: 22),
          Text('“${verse.text}”', style: AppText.verse(color: p.textPrimary)),
          const SizedBox(height: 22),
          Text(
            '${verse.reference} · ${verse.translation}',
            style: AppText.secondary(color: p.warmBase.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ListenButton(
                isPlaying: isPlaying,
                isPreparing: isPreparing,
                progress: playbackProgress,
                onToggle: onTogglePlayback,
              ),
              const SizedBox(width: 10),
              SaveButton(saved: saved, onTap: onToggleSave),
            ],
          ),
          if (ttsError != null) ...[
            const SizedBox(height: 12),
            InlineErrorBanner(message: ttsError!, onDismiss: onDismissTtsError),
          ],
        ],
      ),
    );
  }
}

class _ReflectionBlock extends StatelessWidget {
  const _ReflectionBlock({required this.onWriteAboutThis});

  final ValueChanged<String> onWriteAboutThis;

  static const _prompt =
      'Where did you see love given away today — not earned, just given?';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SIT WITH IT',
          style: AppText.eyebrow(color: p.warmBase.withValues(alpha: 0.62)),
        ),
        const SizedBox(height: 10),
        Text(
          _prompt,
          style: AppText.body(
            height: 1.6,
            color: p.warmBase.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => onWriteAboutThis(_prompt),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Write about this', style: AppText.link(color: p.accentText)),
              const SizedBox(width: 8),
              ArrowRightIcon(color: p.accentText),
            ],
          ),
        ),
      ],
    );
  }
}
