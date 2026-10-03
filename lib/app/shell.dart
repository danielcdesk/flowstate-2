import 'package:flutter/material.dart';

import 'package:flowstate/design/components/app_bottom_nav.dart';
import 'package:flowstate/design/components/empty_state.dart';
import 'package:flowstate/design/components/sidebar_nav.dart';
import 'package:flowstate/design/tokens.dart';
import 'package:flowstate/features/today/presentation/today_page.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class AdaptiveShell extends StatefulWidget {
  const AdaptiveShell({super.key});

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations =
        AppLocalizations.of(context) ?? AppLocalizationsPtBr();
    final List<String> labels = <String>[
      localizations.navToday,
      localizations.navPlan,
      localizations.navHabits,
      localizations.navWorkouts,
      localizations.navEvolution,
    ];
    final List<IconData> icons = <IconData>[
      Icons.today_outlined,
      Icons.view_agenda_outlined,
      Icons.repeat_outlined,
      Icons.fitness_center_outlined,
      Icons.insights_outlined,
    ];
    final List<Widget> pages = <Widget>[
      const TodayPage(),
      _ShellPlaceholder(label: labels[1]),
      _ShellPlaceholder(label: labels[2]),
      _ShellPlaceholder(label: labels[3]),
      _ShellPlaceholder(label: labels[4]),
    ];
    final List<NavigationDestination> bottomDestinations =
        <NavigationDestination>[
          for (int index = 0; index < labels.length; index++)
            NavigationDestination(
              icon: Icon(icons[index]),
              selectedIcon: Icon(icons[index]),
              label: labels[index],
            ),
        ];
    final List<NavigationRailDestination> railDestinations =
        <NavigationRailDestination>[
          for (int index = 0; index < labels.length; index++)
            NavigationRailDestination(
              icon: Icon(icons[index]),
              selectedIcon: Icon(icons[index]),
              label: Text(labels[index]),
            ),
        ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final Widget content = IndexedStack(
            index: _selectedIndex,
            children: pages,
          );
          if (width >= FlowTokens.expandedBreakpoint) {
            return Row(
              children: <Widget>[
                SidebarNav(
                  currentIndex: _selectedIndex,
                  onDestinationSelected: _select,
                  destinations: railDestinations,
                ),
                Expanded(child: content),
              ],
            );
          }
          if (width >= FlowTokens.compactBreakpoint) {
            return Row(
              children: <Widget>[
                SidebarNav(
                  rail: true,
                  currentIndex: _selectedIndex,
                  onDestinationSelected: _select,
                  destinations: railDestinations,
                ),
                Expanded(child: content),
              ],
            );
          }
          return Column(
            children: <Widget>[
              Expanded(child: content),
              AppBottomNav(
                currentIndex: _selectedIndex,
                onDestinationSelected: _select,
                destinations: bottomDestinations,
              ),
            ],
          );
        },
      ),
    );
  }

  void _select(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _ShellPlaceholder extends StatelessWidget {
  const _ShellPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyState(
        title: label,
        message: (AppLocalizations.of(context) ?? AppLocalizationsPtBr())
            .shellComingSoon,
      ),
    );
  }
}
