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
 * "Small (2 × 2)" home-screen widget — see [VerseWidgetLargeProvider] for
 * how data flows in from Dart; this one only differs in layout and which
 * keys it reads.
 */
class VerseWidgetSmallProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.verse_widget_small).apply {
            setTextViewText(
                R.id.widget_verse_small,
                widgetData.getString("widget_verse_small", null)
                    ?: context.getString(R.string.widget_verse_placeholder),
            )
            setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    // See VerseWidgetLargeProvider for why `?homeWidget=true`
                    // is part of this URI on both platforms.
                    Uri.parse("john316://today?homeWidget=true"),
                ),
            )
          }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
