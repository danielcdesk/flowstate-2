import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flowstate/design/components/app_button.dart';
import 'package:flowstate/design/components/empty_state.dart';
import 'package:flowstate/design/components/hairline_section.dart';
import 'package:flowstate/design/components/hero_stat.dart';
import 'package:flowstate/design/components/list_row.dart';
import 'package:flowstate/design/components/quick_action_grid.dart';
import 'package:flowstate/design/tokens.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/planning/next_action.dart';
import 'package:flowstate/features/today/application/today_controller.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({required this.controller, super.key});

  final TodayController controller;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations =
        AppLocalizations.of(context) ?? AppLocalizationsPtBr();
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final TodaySnapshot? snapshot = widget.controller.snapshot;
        if (snapshot == null && widget.controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(localizations.todayLoadError),
                const SizedBox(height: FlowTokens.space3),
                AppButton(
                  label: localizations.retryAction,
                  onPressed: widget.controller.load,
                ),
              ],
            ),
          );
        }
        return _buildContent(context, localizations, snapshot);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations localizations,
    TodaySnapshot snapshot,
  ) {
    final int level = levelForXp(snapshot.totalXp);
    final NextAction? action = snapshot.nextAction;
    final List<Habit> habits = snapshot.habits;
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
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: FlowTokens.space2,
              children: <Widget>[
                Text(localizations.todaySubtitle),
                Text(
                  localizations.todayLevelXp(level, snapshot.totalXp),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: FlowTokens.space6),
            HeroStat(
              title: localizations.todayProgressTitle,
              value: localizations.todayProgressValue(
                snapshot.completedCount,
                snapshot.totalCount,
              ),
              progress: snapshot.progress,
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
                    if (action == null)
                      Text(localizations.nextActionEmpty)
                    else ...<Widget>[
                      Text(action.title),
                      if (action.kind !=
                          NextActionKind.routineBlock) ...<Widget>[
                        const SizedBox(height: FlowTokens.space4),
                        AppButton(
                          label: localizations.completeAction,
                          icon: Icons.check,
                          onPressed: () => _completeNextAction(localizations),
                        ),
                      ],
                    ],
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
                    onPressed: () => _showComingSoon(localizations),
                  ),
                  QuickAction(
                    label: localizations.newTaskAction,
                    icon: Icons.add_task,
                    onPressed: () => _showComingSoon(localizations),
                  ),
                  QuickAction(
                    label: localizations.startFocusAction,
                    icon: Icons.center_focus_strong,
                    onPressed: () => _showComingSoon(localizations),
                  ),
                  QuickAction(
                    label: localizations.startWorkoutAction,
                    icon: Icons.fitness_center,
                    onPressed: () => _showComingSoon(localizations),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FlowTokens.space6),
            HairlineSection(
              title: localizations.todayHabitsTitle,
              child: habits.isEmpty
                  ? EmptyState(
                      title: localizations.todayHabitsEmptyTitle,
                      message: localizations.todayHabitsEmptyMessage,
                    )
                  : Card(
                      child: Column(
                        children: <Widget>[
                          for (final Habit habit in habits)
                            ListRow(
                              title: habit.name,
                              subtitle:
                                  habit.cue ?? localizations.habitTapToComplete,
                              trailing: snapshot.isHabitComplete(habit)
                                  ? localizations.completedStatus
                                  : localizations.daysStreak(
                                      habitStreak(
                                        habit: habit,
                                        logs: snapshot.habitLogs,
                                        through: snapshot.date,
                                      ),
                                    ),
                              onTap: snapshot.isHabitComplete(habit)
                                  ? null
                                  : () => _completeHabit(habit, localizations),
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: FlowTokens.space6),
            HairlineSection(
              title: localizations.timelineTitle,
              child: _buildTimeline(context, localizations, snapshot),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    AppLocalizations localizations,
    TodaySnapshot snapshot,
  ) {
    final List<({int minute, String title, String subtitle})> events =
        <({int minute, String title, String subtitle})>[];
    for (final block in snapshot.routineBlocks) {
      if (block.isScheduledOn(snapshot.date)) {
        events.add((
          minute: block.startMinute,
          title: block.title,
          subtitle: _formatMinute(context, block.startMinute),
        ));
      }
    }
    for (final task in snapshot.tasks) {
      final int? minute = task.dueMinute;
      if (minute != null) {
        events.add((
          minute: minute,
          title: task.title,
          subtitle: _formatMinute(context, minute),
        ));
      }
    }
    events.sort((a, b) => a.minute.compareTo(b.minute));
    if (events.isEmpty) {
      return Card(
        child: Padding(
          padding: FlowTokens.sectionPadding,
          child: Text(localizations.timelineEmpty),
        ),
      );
    }
    return Card(
      child: Column(
        children: <Widget>[
          for (final event in events.take(6))
            ListRow(title: event.title, subtitle: event.subtitle, trailing: ''),
        ],
      ),
    );
  }

  String _formatMinute(BuildContext context, int minute) {
    final TimeOfDay time = TimeOfDay(hour: minute ~/ 60, minute: minute % 60);
    return time.format(context);
  }

  Future<void> _completeHabit(
    Habit habit,
    AppLocalizations localizations,
  ) async {
    try {
      await widget.controller.completeHabit(habit);
      _showUndo(localizations);
    } on Object {
      _showMessage(localizations.todayActionError);
    }
  }

  Future<void> _completeNextAction(AppLocalizations localizations) async {
    try {
      await widget.controller.completeNextAction();
      _showUndo(localizations);
    } on Object {
      _showMessage(localizations.todayActionError);
    }
  }

  void _showUndo(AppLocalizations localizations) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.actionCompleted),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: localizations.undoAction,
          onPressed: () => unawaited(widget.controller.undoLastCompletion()),
        ),
      ),
    );
  }

  void _showComingSoon(AppLocalizations localizations) {
    _showMessage(localizations.quickActionComingSoon);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
