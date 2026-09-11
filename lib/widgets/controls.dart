import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';
import 'app_icons.dart';

/// A dismissible, plain-language error banner — shared shape for both the
/// Listen (text-to-speech) and Journal (speech-to-text) failure states, per
/// the design's call for plain-language permission/error messaging.
class InlineErrorBanner extends StatelessWidget {
  const InlineErrorBanner({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.warmBase.withValues(alpha: p.isDark ? 0.06 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.warmBase.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              message,
              style: AppText.meta(
                size: 12,
                color: p.warmBase.withValues(alpha: p.isDark ? 0.7 : 0.75),
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 1),
              child: Text(
                '✕',
                style: TextStyle(
                  color: p.warmBase.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Streak pill — flame icon + day count, top-right of the Today header.
class StreakPill extends StatelessWidget {
  const StreakPill({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: p.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlameIcon(color: p.accentText, size: 13),
          const SizedBox(width: 7),
          Text('$days days', style: AppText.streak(color: p.accentText)),
        ],
      ),
    );
  }
}

/// Listen pill button — plays the verse aloud (ElevenLabs when configured,
/// else the on-device voice; see `AppState`'s verse-playback section).
/// Purely presentational: [isPlaying], [isPreparing] and [progress] are
/// driven entirely by AppState, not a local timer.
class ListenButton extends StatelessWidget {
  const ListenButton({
    super.key,
    required this.isPlaying,
    required this.isPreparing,
    required this.progress,
    required this.onToggle,
  });

  final bool isPlaying;

  /// True while a cloud voice request is in flight — a brief loading state
  /// distinct from [isPlaying] (never true for the on-device voice, which
  /// starts speaking immediately).
  final bool isPreparing;

  /// 0-1 fraction through the spoken verse.
  final double progress;
  final Future<void> Function() onToggle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final label = isPreparing
        ? 'Preparing…'
        : isPlaying
            ? 'Pause'
            : 'Listen';
    return Expanded(
      child: Semantics(
        button: true,
        label: isPlaying ? 'Pause verse playback' : 'Listen to this verse',
        child: GestureDetector(
          onTap: onToggle,
          child: Container(
            height: 52,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: p.buttonGradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: p.buttonShadowColor.withValues(alpha: 0.28),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // FittedBox rather than a bare Row: if the pill is ever
                // squeezed narrower than the icon+label's natural width — a
                // transient first-layout frame, very large accessibility
                // text scaling, an unusually narrow screen — this scales
                // the content down to fit instead of throwing a RenderFlex
                // overflow.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPreparing)
                        SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(p.buttonInk),
                          ),
                        )
                      else if (isPlaying)
                        _PauseGlyph(color: p.buttonInk)
                      else
                        PlayIcon(color: p.buttonInk, size: 15),
                      const SizedBox(width: 10),
                      Text(label, style: AppText.button(color: p.buttonInk)),
                    ],
                  ),
                ),
                if (isPlaying)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                      builder: (context, value, _) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value,
                        child: Container(
                          height: 2.5,
                          color: p.buttonInk.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseGlyph extends StatelessWidget {
  const _PauseGlyph({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15,
      height: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: 4, height: 15, color: color),
          Container(width: 4, height: 15, color: color),
        ],
      ),
    );
  }
}

/// 52x52 circular save (bookmark) toggle with an optimistic ~180ms ease-out
/// transition on fill/border.
class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.saved, required this.onTap});

  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = saved
        ? p.accent.withValues(alpha: 0.16)
        : p.warmBase.withValues(alpha: p.isDark ? 0.06 : 0.05);
    final border = saved
        ? p.accent.withValues(alpha: 0.4)
        : p.warmBase.withValues(alpha: 0.14);
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: saved ? 'Remove this saved verse' : 'Save this verse',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: BookmarkIcon(
            filled: saved,
            fillColor: p.accent,
            strokeColor: saved ? p.accent : p.warmBase.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

/// 56x56 mic button. Press-and-hold starts dictation; the halo pulses while
/// [recording] is true.
class MicButton extends StatefulWidget {
  const MicButton({
    super.key,
    required this.recording,
    required this.onStart,
    required this.onStop,
  });

  final bool recording;
  final Future<void> Function() onStart;
  final Future<void> Function() onStop;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didUpdateWidget(covariant MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recording && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.recording && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: 'Hold to speak',
      child: GestureDetector(
        onTapDown: (_) => widget.onStart(),
        onTapUp: (_) => widget.onStop(),
        onTapCancel: widget.onStop,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final haloAlpha = 0.10 + _pulse.value * 0.12;
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: p.buttonGradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: p.accent.withValues(alpha: haloAlpha),
                    blurRadius: 0,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: p.buttonShadowColor.withValues(alpha: 0.3),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: MicIcon(color: p.buttonInk),
            );
          },
        ),
      ),
    );
  }
}

/// A single selectable tag chip (Gratitude / Request / Praise / Confession).
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = selected
        ? p.accent.withValues(alpha: 0.18)
        : p.warmBase.withValues(alpha: p.isDark ? 0.05 : 0.04);
    final fg = selected
        ? p.accentTextDeep
        : p.warmBase.withValues(alpha: 0.62);
    final border = selected
        ? p.accent.withValues(alpha: 0.42)
        : p.warmBase.withValues(alpha: 0.12);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Text(label, style: AppText.tagChip(color: fg)),
      ),
    );
  }
}
