package com.pepla.john316.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import com.pepla.john316.MainActivity
import com.pepla.john316.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * "Large (4 × 2)" home-screen widget — see the design handoff's Widget
 * screen. Data is pushed from Dart by `HomeWidgetService.syncVerse` (in
 * lib/services/home_widget_service.dart, which is the single source of
 * truth for the exact strings shown here); this class only ever reads that
 * data back out of [widgetData] and draws it into
 * [R.layout.verse_widget_large]. Refresh timing (daily 6am) is handled by
 * `home_widget`'s own alarm scheduler, wired up in AndroidManifest.xml.
 */
class VerseWidgetLargeProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.verse_widget_large).apply {
            setTextViewText(
                R.id.widget_verse_large,
                widgetData.getString("widget_verse_large", null)
                    ?: context.getString(R.string.widget_verse_placeholder),
            )
            setTextViewText(
                R.id.widget_footer_left,
                widgetData.getString("widget_footer_left", null) ?: "",
            )
            setTextViewText(
                R.id.widget_streak_label,
                widgetData.getString("widget_streak_label", null) ?: "",
            )
            // Tapping deep-links to Today (see the design's Interactions
            // section) — HomeWidgetService.handleInitialLaunch /
            // listenForClicks read this same URI back on the Dart side.
            setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    // The `homeWidget` query item isn't needed by Android
                    // (which reads the launch intent's data unconditionally)
                    // but is required by home_widget's iOS AppDelegate hook
                    // to recognize this as a widget-originated launch — kept
                    // identical here so both platforms share one URI shape.
                    Uri.parse("john316://today?homeWidget=true"),
                ),
            )
          }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
