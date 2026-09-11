import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_tab.dart';
import '../state/app_state.dart';
import '../theme/app_palette.dart';
import '../widgets/app_tab_bar.dart';
import 'journal_screen.dart';
import 'plan_screen.dart';
import 'today_screen.dart';
import 'widget_screen.dart';

/// Hosts the four screens under one bottom tab bar. Uses [IndexedStack] so
/// each tab keeps its own scroll position when switching, and tab switches
/// are instant with no cross-fade — both called out in the design's
/// Interactions section.
class RootShell extends StatelessWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final state = context.watch<AppState>();
    final index = AppTab.values.indexOf(state.activeTab);

    return Scaffold(
      backgroundColor: p.screenBg,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: index,
              children: const [
                TodayScreen(),
                JournalScreen(),
                PlanScreen(),
                WidgetScreen(),
              ],
            ),
          ),
          AppTabBar(active: state.activeTab, onSelect: state.setActiveTab),
        ],
      ),
    );
  }
}
