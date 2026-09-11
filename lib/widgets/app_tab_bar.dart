import 'package:flutter/material.dart';

import '../models/app_tab.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';
import 'app_icons.dart';

/// Bottom tab bar shared by all four screens: 4 equal columns, a top
/// hairline, and a background that fades from opaque to 85% so content
/// scrolls under it. 104pt tall total (78pt content + 26pt safe-area inset).
class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, required this.active, required this.onSelect});

  final AppTab active;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 26),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.tabBarBorder)),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [p.screenBg, p.screenBg.withValues(alpha: 0.85)],
          stops: const [0.55, 1],
        ),
      ),
      child: Row(
        children: AppTab.values.map((tab) {
          final isActive = tab == active;
          final color = isActive ? p.accent : p.tabInactive;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(tab),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconFor(tab, color),
                  const SizedBox(height: 5),
                  Text(
                    _labelFor(tab),
                    style: AppText.tabLabel(active: isActive, color: color),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _iconFor(AppTab tab, Color color) {
    return switch (tab) {
      AppTab.today => SunriseIcon(color: color),
      AppTab.journal => BookIcon(color: color),
      AppTab.plan => ChecklistIcon(color: color),
      AppTab.widget => GridIcon(color: color),
    };
  }

  String _labelFor(AppTab tab) {
    return switch (tab) {
      AppTab.today => 'Today',
      AppTab.journal => 'Journal',
      AppTab.plan => 'Plan',
      AppTab.widget => 'Widget',
    };
  }
}
