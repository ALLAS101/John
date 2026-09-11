// Pre-generates the shared ElevenLabs audio for every verse in
// Verse.dailyVerses, once, so that every user's app downloads the same
// file instead of each device calling ElevenLabs individually for
// identical content — see the top-level README's "Shared daily audio"
// section for the full picture (why this exists, how the app consumes its
// output, the one-time GitHub setup it depends on).
//
// Run from the `john316/` package root:
//   ELEVENLABS_API_KEY=... dart run tool/generate_daily_audio.dart
//
// Normally run by .github/workflows/generate-daily-audio.yml, not by hand
// — but it's a plain script, so it's fine to run locally too (e.g. to
// preview new verse audio before pushing).
//
// Writes into docs/audio/, which GitHub Pages serves as-is when Pages is
// configured to deploy from the `main` branch's `/docs` folder (a one-time
// repo-settings step — see the README):
//   docs/audio/verse-<index>.mp3     the audio itself
//   docs/audio/verse-<index>.sha256  hash of the text it was generated
//                                    from, so a re-run only regenerates
//                                    entries whose text actually changed
//   docs/audio/manifest.json         human-readable index of the above,
//                                    for browsing the published site —
//                                    the app doesn't read this; it computes
//                                    the same index Verse.forDate does and
//                                    fetches that file directly

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:john316/models/verse.dart';
import 'package:john316/services/eleven_labs_core.dart';

Future<void> main(List<String> args) async {
  final apiKey = Platform.environment['ELEVENLABS_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln(
      'ELEVENLABS_API_KEY is not set. Set it as an environment variable '
      '(a GitHub Actions secret in CI) and try again.',
    );
    exitCode = 1;
    return;
  }
  // `?? ''` then treating '' as unset: the GitHub Actions workflow always
  // sets this env var (from a repo *variable*, since a voice ID isn't a
  // secret), but as an empty string when that variable itself isn't
  // configured — not absent the way a truly-unset env var would be.
  final rawVoiceId = Platform.environment['ELEVENLABS_VOICE_ID'] ?? '';
  final voiceId = rawVoiceId.isEmpty ? null : rawVoiceId;

  final outDir = Directory('docs/audio');
  await outDir.create(recursive: true);

  var generated = 0;
  var skipped = 0;
  final manifestEntries = <Map<String, dynamic>>[];

  // Start from *today's* rotation index and wrap around, rather than
  // always 0, 1, 2, .... ElevenLabs' free tier only covers a fraction of
  // 365 verses per run (see the workflow's doc comment), so a plain
  // ascending order would mean whichever days are late in Verse.dailyVerses
  // stay on the on-device fallback voice for months while earlier days
  // finish first purely by list position — unrelated to which day anyone
  // is actually hearing. Starting from today means whatever's due to run
  // out of quota next, runs out having covered today and the nearest
  // upcoming days first.
  final todayIndex = Verse.indexForDate(DateTime.now());
  final order = [
    for (var i = 0; i < Verse.dailyVerses.length; i++)
      (todayIndex + i) % Verse.dailyVerses.length,
  ];

  for (final index in order) {
    final verse = Verse.dailyVerses[index];
    // The exact text spoken — kept identical to AppState.toggleVersePlayback
    // so the shared file matches what a direct ElevenLabs/on-device call
    // would have said.
    final spokenText = '${verse.text} ${verse.reference}, ${verse.translation}.';
    final hash = sha256.convert(utf8.encode(spokenText)).toString();

    final audioFile = File('${outDir.path}/verse-$index.mp3');
    final hashFile = File('${outDir.path}/verse-$index.sha256');
    final previousHash =
        await hashFile.exists() ? await hashFile.readAsString() : null;

    if (previousHash == hash && await audioFile.exists()) {
      stdout.writeln('[$index] unchanged (${verse.reference}) — skipping');
      skipped++;
    } else {
      stdout.writeln('[$index] generating (${verse.reference})…');
      try {
        final bytes = await ElevenLabsCore.synthesizeBytes(
          spokenText,
          apiKey: apiKey,
          voiceId: voiceId ?? ElevenLabsCore.defaultVoiceId,
        );
        await audioFile.writeAsBytes(bytes, flush: true);
        await hashFile.writeAsString(hash);
        generated++;
      } on ElevenLabsException catch (e) {
        stderr.writeln('[$index] FAILED (${verse.reference}): $e');
        exitCode = 1;
        continue;
      }
    }

    manifestEntries.add({
      'index': index,
      'reference': verse.reference,
      'translation': verse.translation,
      'sha256': hash,
      'file': 'verse-$index.mp3',
    });
  }

  // Generation order starts from today's index (see above) and wraps
  // around, but the published manifest is for humans browsing the site —
  // list it back in calendar order regardless.
  manifestEntries.sort(
    (a, b) => (a['index'] as int).compareTo(b['index'] as int),
  );

  final manifestFile = File('${outDir.path}/manifest.json');
  await manifestFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert({
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'verses': manifestEntries,
    }),
  );

  stdout.writeln('Done: $generated generated, $skipped unchanged.');
  if (exitCode != 0) {
    stderr.writeln('Completed with errors — see above.');
  }
}
