import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

/// Thrown when the shared daily audio can't be fetched — not configured,
/// not published yet for today's verse, or a network failure.
class DailyAudioException implements Exception {
  DailyAudioException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'DailyAudioException($statusCode): $message';
}

/// Fetches the *shared* pre-generated verse audio — the whole point being
/// that every user's app downloads the same file `tool/generate_daily_audio.dart`
/// produced once, instead of each device separately calling ElevenLabs for
/// identical content. This is `AppState`'s first tier for Listen, ahead of
/// both ElevenLabs-direct and the on-device voice — see its "Verse
/// playback" section, and the top-level README's "Shared daily audio"
/// section for the full picture (the GitHub Actions + Pages pipeline this
/// depends on).
///
/// **Setup**: needs the base URL the pipeline publishes to (its own
/// `.github/workflows/generate-daily-audio.yml` and one-time GitHub Pages
/// setup — see the README), passed at build time so it's never hardcoded to
/// a placeholder that would silently 404 for everyone:
/// ```
/// flutter run --dart-define=DAILY_AUDIO_BASE_URL=https://<user>.github.io/<repo>/audio
/// ```
/// With no URL configured, [isConfigured] is false and this tier is skipped
/// entirely — `AppState` falls through to ElevenLabs-direct or the
/// on-device voice, so the app works either way.
class DailyAudioService {
  DailyAudioService._();

  static const _baseUrl = String.fromEnvironment('DAILY_AUDIO_BASE_URL');

  /// Test-only override, so a test can exercise the "configured" path
  /// without a real `--dart-define`.
  @visibleForTesting
  static String? debugBaseUrlOverride;

  /// Test-only override of the `http.Client` used when a call site doesn't
  /// pass one explicitly.
  @visibleForTesting
  static http.Client? debugHttpClientOverride;

  /// Test-only override of the cache directory, so tests don't need a
  /// working `path_provider` platform channel.
  @visibleForTesting
  static Directory? debugCacheDirectoryOverride;

  static String get _resolvedBaseUrl => debugBaseUrlOverride ?? _baseUrl;

  static bool get isConfigured => _resolvedBaseUrl.isNotEmpty;

  /// The published URL for [verseIndex]'s shared audio — no network or disk
  /// access, just string-building. Used directly on web (see `AppState`),
  /// where there's no `path_provider` disk cache to write into, so the
  /// player streams straight from this URL instead of going through
  /// [fetchCached].
  static String urlFor(int verseIndex) => '$_resolvedBaseUrl/verse-$verseIndex.mp3';

  /// Returns a local file containing today's shared verse audio, from the
  /// on-disk cache when available (one cached file per rotation index —
  /// see `Verse.indexForDate`; the *content* for a given index only changes
  /// if `Verse.dailyVerses` itself is edited, which is rare), else
  /// downloaded and cached for next time.
  ///
  /// Throws [DailyAudioException] if [isConfigured] is false, the download
  /// fails, or nothing has been published yet for [verseIndex] (a 404 —
  /// e.g. a brand new rotation entry the pipeline hasn't generated for).
  static Future<File> fetchCached(int verseIndex, {http.Client? client}) async {
    if (!isConfigured) {
      throw DailyAudioException(
        'Shared daily audio is not configured (no DAILY_AUDIO_BASE_URL).',
      );
    }

    final baseDir =
        debugCacheDirectoryOverride ?? await getApplicationSupportDirectory();
    final cacheDir = Directory('${baseDir.path}/daily_audio_cache');
    final file = File('${cacheDir.path}/verse-$verseIndex.mp3');

    if (await file.exists() && await file.length() > 0) {
      return file;
    }

    final httpClient = client ?? debugHttpClientOverride ?? http.Client();
    final shouldClose = client == null && debugHttpClientOverride == null;
    try {
      final response = await httpClient
          .get(Uri.parse(urlFor(verseIndex)))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw DailyAudioException(
          'Shared audio not available for verse $verseIndex.',
          statusCode: response.statusCode,
        );
      }
      if (response.bodyBytes.isEmpty) {
        throw DailyAudioException(
          'Shared audio download was empty.',
          statusCode: response.statusCode,
        );
      }

      await cacheDir.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes, flush: true);
      return file;
    } on DailyAudioException {
      rethrow;
    } catch (e) {
      throw DailyAudioException('Network error fetching shared audio: $e');
    } finally {
      if (shouldClose) httpClient.close();
    }
  }
}
