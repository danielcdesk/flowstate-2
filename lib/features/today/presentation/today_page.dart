import 'package:flutter/material.dart';

import 'package:flowstate/design/components/app_button.dart';
import 'package:flowstate/design/components/hairline_section.dart';
import 'package:flowstate/design/components/hero_stat.dart';
import 'package:flowstate/design/components/list_row.dart';
import 'package:flowstate/design/components/quick_action_grid.dart';
import 'package:flowstate/design/tokens.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations =
        AppLocalizations.of(context) ?? AppLocalizationsPtBr();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: FlowTokens.contentMaxWidth),
        child: ListView(
          padding: FlowTokens.pagePadding,
          children: <Widget>[
            Text(
              localizations.todayGreeting,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: FlowTokens.space2),
            Row(
              children: <Widget>[
                Expanded(child: Text(localizations.todaySubtitle)),
                Text(
                  localizations.todayLevelXp,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: FlowTokens.space6),
            HeroStat(
              title: localizations.todayProgressTitle,
              value: localizations.todayProgressValue,
              progress: 3 / 7,
            ),
            const SizedBox(height: FlowTokens.space6),
            Card(
              child: Padding(
                padding: FlowTokens.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      localizations.nextActionTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: FlowTokens.space2),
                    Text(localizations.nextActionTask),
                    const SizedBox(height: FlowTokens.space4),
                    AppButton(
                      label: localizations.completeAction,
                      icon: Icons.check,
                      onPressed: _noop,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: FlowTokens.space6),
            HairlineSection(
              title: localizations.quickActionsTitle,
              child: QuickActionGrid(
                actions: <QuickAction>[
                  QuickAction(
                    label: localizations.newHabitAction,
                    icon: Icons.repeat,
                    onPressed: _noop,
                  ),
                  QuickAction(
                    label: localizations.newTaskAction,
                    icon: Icons.add_task,
                    onPressed: _noop,
                  ),
                  QuickAction(
                    label: localizations.startFocusAction,
                    icon: Icons.center_focus_strong,
                    onPressed: _noop,
                  ),
                  QuickAction(
                    label: localizations.startWorkoutAction,
                    icon: Icons.fitness_center,
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
            const SizedBox(height: FlowTokens.space6),
            HairlineSection(
              title: localizations.todayHabitsTitle,
              child: Card(
                child: Column(
                  children: <Widget>[
                    ListRow(
                      title: localizations.habitMorning,
                      subtitle: localizations.habitMorningCue,
                      trailing: localizations.habitMorningStreak,
                      onTap: _noop,
                    ),
                    ListRow(
                      title: localizations.habitReading,
                      subtitle: localizations.habitReadingCue,
                      trailing: localizations.habitReadingStreak,
                      onTap: _noop,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: FlowTokens.space6),
            HairlineSection(
              title: localizations.timelineTitle,
              child: Card(
                child: Padding(
                  padding: FlowTokens.sectionPadding,
                  child: Text(localizations.timelineEmpty),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
