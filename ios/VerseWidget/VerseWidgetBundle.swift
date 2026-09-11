import WidgetKit
import SwiftUI

/// Entry point for the widget extension target. See README.md in this
/// folder for the Xcode setup this needs (the target itself, App Group,
/// adding these files to it) — none of that can be done by hand-editing
/// project.pbxproj, so it isn't done here.
@main
struct VerseWidgetBundle: WidgetBundle {
  var body: some Widget {
    VerseWidget()
  }
}
