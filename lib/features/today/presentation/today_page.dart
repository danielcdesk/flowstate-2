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
import 'package:flowstate/domain/gamification/skill_scores.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/planning/next_action.dart';
import 'package:flowstate/features/today/application/today_controller.dart';
import 'package:flowstate/features/evolution/application/evolution_controller.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({
    required this.controller,
    this.evolutionController,
    this.onStartFocus,
    super.key,
  });

  final TodayController controller;
  final EvolutionController? evolutionController;
  final VoidCallback? onStartFocus;

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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide =
            constraints.maxWidth >= FlowTokens.wideDashboardBreakpoint;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: FlowTokens.contentMaxWidth,
            ),
            child: ListView(
              padding: constraints.maxWidth < FlowTokens.compactBreakpoint
                  ? FlowTokens.compactPagePadding
                  : FlowTokens.dashboardPadding,
              children: <Widget>[
                _buildDashboardHeader(context, localizations, snapshot, level),
                const SizedBox(height: FlowTokens.space6),
                if (wide)
                  _buildWideDashboard(context, localizations, snapshot, action)
                else
                  _buildCompactDashboard(
                    context,
                    localizations,
                    snapshot,
                    action,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardHeader(
    BuildContext context,
    AppLocalizations localizations,
    TodaySnapshot snapshot,
    int level,
  ) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: FlowTokens.space3,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              localizations.todayGreeting,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.8),
            ),
            const SizedBox(height: FlowTokens.space1),
            Text(
              localizations.todaySubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(FlowTokens.radiusMedium),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline
                  .withValues(alpha: 0.7),
            ),
          ),
          child: Padding(
            padding: FlowTokens.dateControlPadding,
            child: Wrap(
              spacing: FlowTokens.space2,
              runSpacing: FlowTokens.space1,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.calendar_today_outlined,
                  size: FlowTokens.iconSmall,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(snapshot.date.toString()),
                Text(
                  localizations.todayLevelXp(level, snapshot.totalXp),
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideDashboard(
    BuildContext context,
    AppLocalizations localizations,
    TodaySnapshot snapshot,
    NextAction? action,
  ) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _buildHero(snapshot, localizations)),
            const SizedBox(width: FlowTokens.dashboardGap),
            Expanded(child: _buildNextAction(context, localizations, action)),
            const SizedBox(width: FlowTokens.dashboardGap),
            Expanded(
              child: _buildProgressPanel(context, localizations, snapshot),
            ),
          ],
        ),
        const SizedBox(height: FlowTokens.dashboardGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 7,
              child: _buildTimelinePanel(context, localizations, snapshot),
            ),
            const SizedBox(width: FlowTokens.dashboardGap),
            Expanded(
              flex: 4,
              child: Column(
                children: <Widget>[
                  _buildHabitsPanel(context, localizations, snapshot),
                  const SizedBox(height: FlowTokens.dashboardGap),
                  _buildEvolutionPanel(context, localizations),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: FlowTokens.dashboardGap),
        _buildQuickActions(localizations),
      ],
    );
  }

  Widget _buildCompactDashboard(
    BuildContext context,
    AppLocalizations localizations,
    TodaySnapshot snapshot,
    NextAction? action,
  ) {
    return Column(
      children: <Widget>[
        _buildHero(snapshot, localizations),
        const SizedBox(height: FlowTokens.dashboardGap),
        _buildQuickActions(localizations),
        const SizedBox(height: FlowTokens.dashboardGap),
        _buildNextAction(context, localizations, action),
        const SizedBox(height: FlowTokens.dashboardGap),
        _buildHabitsPanel(context, localizations, snapshot),
        const SizedBox(height: FlowTokens.dashboardGap),
        _buildTimelinePanel(context, localizations, snapshot),
        const SizedBox(height: FlowTokens.dashboardGap),
        _buildEvolutionPanel(context, localizations),
      ],
    );
  }

  Widget _buildHero(TodaySnapshot snapshot, AppLocalizations localizations) {
    return HeroStat(
      title: localizations.todayProgressTitle,
      value: localizations.todayProgressValue(
        snapshot.completedCount,
        snapshot.totalCount,
      ),
      progress: snapshot.progress,
    );
  }

  Widget _buildNextAction(
    BuildContext context,
    AppLocalizations localizations,
    NextAction? action,
  ) {
    return Card(
      child: Padding(
        padding: FlowTokens.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              localizations.nextActionTitle,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: FlowTokens.space6),
            if (action == null)
              Text(localizations.nextActionEmpty)
            else ...<Widget>[
              Text(
                action.title,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (action.kind != NextActionKind.routineBlock) ...<Widget>[
                const SizedBox(height: FlowTokens.space6),
                AppButton(
                  label: localizations.completeAction,
                  icon: Icons.check_rounded,
                  onPressed: () => _completeNextAction(localizations),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressPanel(
    BuildContext context,
    AppLocalizations localizations,
    TodaySnapshot snapshot,
  ) {
    return Card(
      child: Padding(
        padding: FlowTokens.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  localizations.todayProgressTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(
                  Icons.more_horiz_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: FlowTokens.space6),
            Text(
              localizations.todayProgressValue(
                snapshot.completedCount,
                snapshot.totalCount,
              ),
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: FlowTokens.space3),
            LinearProgressIndicator(
              value: snapshot.progress,
              minHeight: FlowTokens.progressHeight,
              borderRadius: BorderRadius.circular(FlowTokens.progressHeight),
            ),
            const SizedBox(height: FlowTokens.space3),
            Text(
              localizations.todaySubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations localizations) {
    return HairlineSection(
      title: localizations.quickActionsTitle,
      child: QuickActionGrid(
        actions: <QuickAction>[
          QuickAction(
            label: localizations.newHabitAction,
            icon: Icons.repeat_rounded,
            onPressed: () => _showComingSoon(localizations),
          ),
          QuickAction(
            label: localizations.newTaskAction,
            icon: Icons.add_task_rounded,
            onPressed: () => _showComingSoon(localizations),
          ),
          QuickAction(
            label: localizations.startFocusAction,
            icon: Icons.center_focus_strong,
            onPressed:
                widget.onStartFocus ?? () => _showComingSoon(localizations),
          ),
          QuickAction(
            label: localizations.startWorkoutAction,
            icon: Icons.fitness_center_rounded,
            onPressed: () => _showComingSoon(localizations),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsPanel(
    BuildContext context,
    AppLocalizations localizations,
    TodaySnapshot snapshot,
  ) {
    final List<Habit> habits = snapshot.habits;
    return Card(
      child: Padding(
        padding: FlowTokens.sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    localizations.todayHabitsTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Flexible(
                  child: Text(
                    localizations.todayProgressValue(
                      habits.where(snapshot.isHabitComplete).length,
                      habits.length,
                    ),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FlowTokens.space2),
            if (habits.isEmpty)
              EmptyState(
                title: localizations.todayHabitsEmptyTitle,
                message: localizations.todayHabitsEmptyMessage,
              )
            else
              for (int index = 0; index < habits.length; index++)
                ListRow(
                  title: habits[index].name,
                  subtitle:
                      habits[index].cue ?? localizations.habitTapToComplete,
                  leading: snapshot.isHabitComplete(habits[index])
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  trailing: snapshot.isHabitComplete(habits[index])
                      ? localizations.completedStatus
                      : localizations.daysStreak(
                          habitStreak(
                            habit: habits[index],
                            logs: snapshot.habitLogs,
                            through: snapshot.date,
                          ),
                        ),
                  showDivider: index < habits.length - 1,
                  onTap: snapshot.isHabitComplete(habits[index])
                      ? null
                      : () => _completeHabit(habits[index], localizations),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelinePanel(
    BuildContext context,
    AppLocalizations localizations,
    TodaySnapshot snapshot,
  ) {
    return Card(
      child: Padding(
        padding: FlowTokens.sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              localizations.timelineTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: FlowTokens.space2),
            _buildTimeline(context, localizations, snapshot),
          ],
        ),
      ),
    );
  }

  Widget _buildEvolutionPanel(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final List<SkillScore> radar =
        widget.evolutionController?.radar ?? const <SkillScore>[];
    return Card(
      child: Padding(
        padding: FlowTokens.sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              localizations.skillRadarTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: FlowTokens.space3),
            if (radar.isEmpty)
              Text(
                localizations.skillRadarDescription,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              for (final SkillScore score in radar)
                _buildSkillMeter(
                  context,
                  _skillLabel(localizations, score.moduleId),
                  score.score,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillMeter(BuildContext context, String label, int score) {
    return Padding(
      padding: FlowTokens.skillMeterPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(label),
              Text(
                '$score%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: FlowTokens.space1),
          LinearProgressIndicator(
            value: score / 100,
            minHeight: FlowTokens.progressHeight,
            borderRadius: BorderRadius.circular(FlowTokens.progressHeight),
          ),
        ],
      ),
    );
  }

  String _skillLabel(AppLocalizations localizations, String moduleId) {
    return switch (moduleId) {
      'focus' => localizations.skillFocus,
      'planning' => localizations.skillPlanning,
      'habits' => localizations.skillConsistency,
      'body' => localizations.skillStrength,
      _ => moduleId,
    };
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
