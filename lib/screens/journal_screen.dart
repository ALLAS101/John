import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/journal_entry.dart';
import '../state/app_state.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_icons.dart';
import '../widgets/controls.dart';

/// Screen 2 — write or speak a prayer, tag it, revisit past entries.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _controller = TextEditingController(text: state.draftBody);
    _controller.addListener(() {
      context.read<AppState>().setDraftBody(_controller.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Keep the field in sync if the draft was set externally (e.g. cleared
    // after submit) without fighting the user's own typing.
    final draft = context.read<AppState>().draftBody;
    if (draft != _controller.text && !_focusNode.hasFocus) {
      _controller.value = TextEditingValue(text: draft);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final state = context.watch<AppState>();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 18, 26, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Journal', style: AppText.screenTitle(color: p.textPrimary)),
            const SizedBox(height: 4),
            Text(
              'Say it plainly. He already knows.',
              style: AppText.secondary(color: p.warmBase.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 22),
            if (state.journalPromptContext != null) ...[
              _PromptContext(
                prompt: state.journalPromptContext!,
                onDismiss: state.clearJournalPromptContext,
              ),
              const SizedBox(height: 16),
            ],
            _Composer(
              controller: _controller,
              focusNode: _focusNode,
              draftTag: state.draftTag,
              onTagSelected: state.setDraftTag,
              isRecording: state.isListening,
              onMicStart: state.startDictation,
              onMicStop: state.stopDictation,
              micError: state.micError,
              onDismissMicError: state.dismissMicError,
              onSubmit: () {
                state.submitDraft();
                _controller.clear();
                _focusNode.unfocus();
              },
            ),
            const SizedBox(height: 22),
            Text(
              'EARLIER',
              style: AppText.eyebrow(color: p.warmBase.withValues(alpha: 0.62)),
            ),
            const SizedBox(height: 12),
            ...state.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EntryRow(entry: e),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptContext extends StatelessWidget {
  const _PromptContext({required this.prompt, required this.onDismiss});

  final String prompt;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: p.accent.withValues(alpha: p.isDark ? 0.1 : 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              prompt,
              style: AppText.body(height: 1.5, color: p.accentText),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 1),
              child: Text(
                '✕',
                style: TextStyle(
                  color: p.accentText.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.draftTag,
    required this.onTagSelected,
    required this.isRecording,
    required this.onMicStart,
    required this.onMicStop,
    required this.micError,
    required this.onDismissMicError,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final JournalTag draftTag;
  final ValueChanged<JournalTag> onTagSelected;
  final bool isRecording;
  final Future<void> Function() onMicStart;
  final Future<void> Function() onMicStop;
  final String? micError;
  final VoidCallback onDismissMicError;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.composerBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.composerBorder),
        boxShadow: p.composerShadow == null ? null : [p.composerShadow!],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            minLines: 1,
            maxLines: 8,
            textInputAction: TextInputAction.newline,
            style: AppText.entryBody(color: p.textPrimary),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: "What's on your heart this morning?",
              hintStyle: AppText.composerPlaceholder(
                color: p.warmBase.withValues(alpha: p.isDark ? 0.45 : 0.42),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: JournalTag.values
                .map(
                  (tag) => TagChip(
                    label: tag.label,
                    selected: tag == draftTag,
                    onTap: () => onTagSelected(tag),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    KeyboardIcon(
                      color: p.warmBase.withValues(alpha: p.isDark ? 0.45 : 0.68),
                    ),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        'Hold mic to speak',
                        style: AppText.meta(
                          size: 12.5,
                          color:
                              p.warmBase.withValues(alpha: p.isDark ? 0.45 : 0.68),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              MicButton(
                recording: isRecording,
                onStart: onMicStart,
                onStop: onMicStop,
              ),
            ],
          ),
          if (micError != null) ...[
            const SizedBox(height: 12),
            InlineErrorBanner(message: micError!, onDismiss: onDismissMicError),
          ],
          if (controller.text.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onSubmit,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: p.buttonGradient),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Save entry', style: AppText.link(color: p.buttonInk)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tagColor = p.tagColors[entry.tag.label]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: p.subtleSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.rowBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  entry.tag.label.toUpperCase(),
                  style: AppText.tagBadge(color: tagColor.fg),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                entry.relativeDate(DateTime.now()),
                style: AppText.meta(
                  size: 11.5,
                  color: p.warmBase.withValues(alpha: p.isDark ? 0.38 : 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.body,
            style: AppText.entryBody(
              color: p.entryBodyBase.withValues(alpha: p.isDark ? 0.88 : 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
