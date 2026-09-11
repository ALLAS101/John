import SwiftUI
import WidgetKit

/// Must match `HomeWidgetService._iosAppGroupId` in
/// lib/services/home_widget_service.dart and the App Group entitlement on
/// both this extension and the host app (Runner.entitlements).
private let appGroupId = "group.com.pepla.john316.widget"

private let placeholderVerse = "Open John 3:16 to see today's verse."

// MARK: - Timeline

struct VerseEntry: TimelineEntry {
  let date: Date
  let verseLarge: String
  let verseSmall: String
  let footerLeft: String
  let streakLabel: String
}

struct VerseProvider: TimelineProvider {
  func placeholder(in context: Context) -> VerseEntry {
    VerseEntry(
      date: Date(),
      verseLarge: "For God so loved the world, that he gave his only begotten Son…",
      verseSmall: "God so loved the world…",
      footerLeft: "John 3:16 · KJV",
      streakLabel: "12-day streak"
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> Void) {
    completion(currentEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<VerseEntry>) -> Void) {
    let timeline = Timeline(entries: [currentEntry()], policy: .after(Self.next6AM(after: Date())))
    completion(timeline)
  }

  /// Reads whatever `HomeWidgetService.syncVerse` (Dart) last wrote into the
  /// shared App Group container. There is no scheduling to arm here —
  /// unlike Android, WidgetKit itself decides when to call this again, and
  /// `.after(next6AM)` in `getTimeline` is the ask, not a guarantee (iOS
  /// budgets background refreshes; see the design's "Refreshes each
  /// morning at 6 am" as a target, not an exact promise, on this platform).
  private func currentEntry() -> VerseEntry {
    let defaults = UserDefaults(suiteName: appGroupId)
    return VerseEntry(
      date: Date(),
      verseLarge: defaults?.string(forKey: "widget_verse_large") ?? placeholderVerse,
      verseSmall: defaults?.string(forKey: "widget_verse_small") ?? placeholderVerse,
      footerLeft: defaults?.string(forKey: "widget_footer_left") ?? "",
      streakLabel: defaults?.string(forKey: "widget_streak_label") ?? ""
    )
  }

  private static func next6AM(after date: Date) -> Date {
    var calendar = Calendar.current
    calendar.timeZone = .current
    var components = calendar.dateComponents([.year, .month, .day], from: date)
    components.hour = 6
    components.minute = 0
    components.second = 0
    guard let today6AM = calendar.date(from: components) else { return date }
    return today6AM > date
      ? today6AM
      : (calendar.date(byAdding: .day, value: 1, to: today6AM) ?? date)
  }
}

// MARK: - Palette
//
// Mirrors lib/theme/app_palette.dart's dark/light tokens for the widget
// screen specifically. SwiftUI's `colorScheme` environment value does the
// same job `AppPalette.isDark` does in the Flutter app.

private extension Color {
  init(hex: UInt32, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255,
      opacity: alpha
    )
  }
}

private struct VersePalette {
  let backgroundLarge: LinearGradient
  let backgroundSmall: LinearGradient
  let textPrimary: Color
  let textSecondary: Color
  let accent: Color

  static func forScheme(_ scheme: ColorScheme) -> VersePalette {
    scheme == .dark
      ? VersePalette(
        backgroundLarge: LinearGradient(
          colors: [Color(hex: 0x1B2145), Color(hex: 0x0D1128), Color(hex: 0x0A0D1C)],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        ),
        backgroundSmall: LinearGradient(
          colors: [Color(hex: 0x1B2145), Color(hex: 0x0C1026)],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        ),
        textPrimary: Color(hex: 0xF7F0E2),
        textSecondary: Color(hex: 0xF4EAD8, alpha: 0.6),
        accent: Color(hex: 0xE8B65A)
      )
      : VersePalette(
        backgroundLarge: LinearGradient(
          colors: [Color(hex: 0xFFFFFF), Color(hex: 0xFFF8EA), Color(hex: 0xFBEFDA)],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        ),
        backgroundSmall: LinearGradient(
          colors: [Color(hex: 0xFFFFFF), Color(hex: 0xFCF3E3)],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        ),
        textPrimary: Color(hex: 0x12172B),
        textSecondary: Color(hex: 0x161B30, alpha: 0.55),
        accent: Color(hex: 0x8A5910)
      )
  }
}

// MARK: - Views

/// "Small (2 × 2)" — see the design's Widget screen.
private struct VerseSmallView: View {
  let entry: VerseEntry
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    let palette = VersePalette.forScheme(colorScheme)
    ZStack {
      palette.backgroundSmall
      VStack(alignment: .leading, spacing: 0) {
        Text(entry.verseSmall)
          .font(.system(size: 14.5, weight: .regular, design: .serif))
          .italic()
          .foregroundColor(palette.textPrimary)
          .lineLimit(3)
        Spacer(minLength: 4)
        Text("JOHN 3:16")
          .font(.system(size: 10, weight: .bold))
          .tracking(1)
          .foregroundColor(palette.accent)
      }
      .padding(16)
    }
  }
}

/// "Large (4 × 2)" — see the design's Widget screen.
private struct VerseMediumView: View {
  let entry: VerseEntry
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    let palette = VersePalette.forScheme(colorScheme)
    ZStack {
      palette.backgroundLarge
      VStack(alignment: .leading, spacing: 10) {
        HStack(spacing: 8) {
          RoundedRectangle(cornerRadius: 5)
            .fill(
              LinearGradient(
                colors: [Color(hex: 0xE8B65A), Color(hex: 0xD97742)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 14, height: 14)
          Text("JOHN 3:16")
            .font(.system(size: 11, weight: .bold))
            .tracking(1.2)
            .foregroundColor(palette.accent)
        }
        Text(entry.verseLarge)
          .font(.system(size: 17, weight: .regular, design: .serif))
          .italic()
          .foregroundColor(palette.textPrimary)
          .lineLimit(3)
          .fixedSize(horizontal: false, vertical: true)
        Spacer(minLength: 0)
        HStack {
          Text(entry.footerLeft)
            .font(.system(size: 11.5))
            .foregroundColor(palette.textSecondary)
          Spacer()
          Text(entry.streakLabel)
            .font(.system(size: 11.5, weight: .semibold))
            .foregroundColor(palette.accent)
        }
      }
      .padding(18)
    }
  }
}

private struct VerseWidgetEntryView: View {
  @Environment(\.widgetFamily) private var family
  let entry: VerseEntry

  var body: some View {
    Group {
      switch family {
      case .systemSmall:
        VerseSmallView(entry: entry)
      default:
        VerseMediumView(entry: entry)
      }
    }
    // Tapping either size deep-links to Today — see the design's
    // Interactions section. `?homeWidget=true` is what home_widget's
    // AppDelegate/SceneDelegate hook looks for to recognize this as a
    // widget-originated launch (see HomeWidgetPlugin.swift's isWidgetUrl).
    .widgetURL(URL(string: "john316://today?homeWidget=true"))
  }
}

struct VerseWidget: Widget {
  let kind: String = "VerseWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: VerseProvider()) { entry in
      VerseWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("John 3:16")
    .description("Today's verse, right on your Home Screen.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
