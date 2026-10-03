import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/design/components/app_button.dart';
import 'package:flowstate/design/components/empty_state.dart';
import 'package:flowstate/design/components/hairline_section.dart';
import 'package:flowstate/design/tokens.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/features/habits/application/habits_controller.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({required this.controller, super.key});

  final HabitsController controller;

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.load());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n =
        AppLocalizations.of(context) ?? AppLocalizationsPtBr();
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final HabitsController controller = widget.controller;
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: FlowTokens.contentMaxWidth,
              ),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverPadding(
                    padding: FlowTokens.pagePadding,
                    sliver: SliverList.list(
                      children: <Widget>[
                        _header(l10n),
                        const SizedBox(height: FlowTokens.space6),
                        if (controller.isLoading && controller.date == null)
                          const _LoadingState()
                        else if (controller.error != null &&
                            controller.date == null)
                          _LoadError(
                            title: l10n.habitsErrorTitle,
                            message: l10n.habitsLoadError,
                            retryLabel: l10n.habitsRetryAction,
                            onRetry: controller.load,
                          )
                        else if (controller.habits.isEmpty)
                          _EmptyHabits(
                            title: l10n.habitsEmptyTitle,
                            message: l10n.habitsEmptyMessage,
                            actionLabel: l10n.habitsCreateAction,
                            onCreate: () => _showEditor(context),
                          )
                        else ...<Widget>[
                          _TodaySummary(controller: controller, l10n: l10n),
                          const SizedBox(height: FlowTokens.space6),
                          HairlineSection(
                            title: l10n.habitsListSectionTitle,
                            child: Column(
                              children: <Widget>[
                                for (final Habit habit in controller.habits)
                                  Padding(
                                    padding: FlowTokens.habitRowPadding,
                                    child: _HabitTile(
                                      habit: habit,
                                      controller: controller,
                                      l10n: l10n,
                                      onEdit: () =>
                                          _showEditor(context, existing: habit),
                                      onArchive: () => _archive(habit, l10n),
                                      onLog: (HabitLogLevel level) =>
                                          _log(habit, level, l10n),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: FlowTokens.space8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(AppLocalizations l10n) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final bool stack =
          constraints.maxWidth < FlowTokens.habitHeaderStackWidth ||
          MediaQuery.textScalerOf(context).scale(1) >=
              FlowTokens.accessibilityLargeTextScale;
      final Widget title = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.habitsScreenTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: FlowTokens.space2),
          Text(l10n.habitsScreenSubtitle),
        ],
      );
      final Widget createButton = AppButton(
        label: l10n.habitsCreateAction,
        icon: stack ? null : Icons.add,
        onPressed: () => _showEditor(context),
      );
      if (stack) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            title,
            const SizedBox(height: FlowTokens.space3),
            createButton,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: title),
          const SizedBox(width: FlowTokens.space2),
          createButton,
        ],
      );
    },
  );

  Future<void> _showEditor(BuildContext context, {Habit? existing}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) =>
          _HabitEditorSheet(controller: widget.controller, existing: existing),
    );
  }

  Future<void> _log(
    Habit habit,
    HabitLogLevel level,
    AppLocalizations l10n,
  ) async {
    try {
      await widget.controller.logToday(habit, level);
      if (!mounted) return;
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.actionCompleted),
            action: SnackBarAction(
              label: l10n.undoAction,
              onPressed: () => unawaited(widget.controller.undoLastLog()),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
    } on Object {
      if (mounted) _showMessage(l10n.habitsSaveError);
    }
  }

  Future<void> _archive(Habit habit, AppLocalizations l10n) async {
    try {
      await widget.controller.archive(habit);
      if (mounted) _showMessage(l10n.habitsArchivedMessage);
    } on Object {
      if (mounted) _showMessage(l10n.habitsSaveError);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({required this.controller, required this.l10n});

  final HabitsController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final List<Habit> scheduled = controller.habits
        .where(controller.isScheduledToday)
        .toList(growable: false);
    final int completed = scheduled.where(controller.isCompletedToday).length;
    final int total = scheduled.length;
    final Widget progress = ClipRRect(
      borderRadius: BorderRadius.circular(FlowTokens.radiusMedium),
      child: LinearProgressIndicator(
        value: total == 0 ? 0 : completed / total,
        minHeight: FlowTokens.progressThickness,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
    final Widget count = Text(
      l10n.todayProgressValue(completed, total),
      style: Theme.of(context).textTheme.headlineLarge,
    );
    final bool stack =
        MediaQuery.textScalerOf(context).scale(1) >=
        FlowTokens.accessibilityLargeTextScale;
    return Semantics(
      label: l10n.todayProgressValue(completed, total),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.todayProgressTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: FlowTokens.space2),
            if (stack ||
                constraints.maxWidth < FlowTokens.habitHeaderStackWidth)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  count,
                  const SizedBox(height: FlowTokens.space2),
                  SizedBox(width: double.infinity, child: progress),
                ],
              )
            else
              Row(
                children: <Widget>[
                  count,
                  const SizedBox(width: FlowTokens.space3),
                  Expanded(child: progress),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({
    required this.habit,
    required this.controller,
    required this.l10n,
    required this.onEdit,
    required this.onArchive,
    required this.onLog,
  });

  final Habit habit;
  final HabitsController controller;
  final AppLocalizations l10n;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final ValueChanged<HabitLogLevel> onLog;

  @override
  Widget build(BuildContext context) {
    final bool completed = controller.isCompletedToday(habit);
    final int streak = controller.streakFor(habit);
    final bool weekly = habit.recurrence.isWeeklyTarget;
    final int? target = habit.recurrence.weeklyTarget;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(_iconFor(habit.iconId)),
        title: Text(habit.name),
        subtitle: Text(
          !controller.isScheduledToday(habit) && !completed
              ? l10n.habitsNotScheduledToday
              : habit.cue ??
                    (weekly
                        ? l10n.habitsWeekProgress(
                            controller.completedInCurrentWeek(habit),
                            target ?? 1,
                          )
                        : l10n.daysStreak(streak)),
        ),
        trailing: _HabitActions(
          habit: habit,
          completed: completed,
          canLogToday: controller.isScheduledToday(habit),
          isBusy: controller.busyHabitId == habit.id,
          l10n: l10n,
          onFull: () => onLog(HabitLogLevel.full),
          onMinimum: () => onLog(HabitLogLevel.minimum),
          onEdit: onEdit,
          onArchive: onArchive,
        ),
        childrenPadding: FlowTokens.habitDetailPadding,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _Stat(
                  label: l10n.habitsStreakLabel,
                  value: l10n.daysStreak(streak),
                ),
              ),
              if (weekly)
                Expanded(
                  child: _Stat(
                    label: l10n.habitsWeekLabel,
                    value: l10n.habitsWeekProgress(
                      controller.completedInCurrentWeek(habit),
                      target ?? 1,
                    ),
                  ),
                ),
              if (completed)
                Expanded(
                  child: _Stat(
                    label: l10n.habitsTodayCompleted,
                    value: _levelLabel(controller.levelToday(habit), l10n),
                  ),
                ),
            ],
          ),
          const SizedBox(height: FlowTokens.space4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.habitsHistoryLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: FlowTokens.space2),
          _HabitHeatmap(
            habit: habit,
            logs: controller.logs,
            date: controller.currentDate,
            l10n: l10n,
          ),
          const SizedBox(height: FlowTokens.space2),
          Wrap(
            spacing: FlowTokens.space3,
            runSpacing: FlowTokens.space2,
            children: <Widget>[
              _LegendDot(
                label: l10n.habitsHistoryFull,
                color: Theme.of(context).colorScheme.primary,
              ),
              _LegendDot(
                label: l10n.habitsHistoryMinimum,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              _LegendDot(
                label: l10n.habitsHistoryMissed,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitActions extends StatelessWidget {
  const _HabitActions({
    required this.habit,
    required this.completed,
    required this.canLogToday,
    required this.isBusy,
    required this.l10n,
    required this.onFull,
    required this.onMinimum,
    required this.onEdit,
    required this.onArchive,
  });

  final Habit habit;
  final bool completed;
  final bool canLogToday;
  final bool isBusy;
  final AppLocalizations l10n;
  final VoidCallback onFull;
  final VoidCallback onMinimum;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      IconButton.filledTonal(
        tooltip: completed
            ? l10n.habitsTodayCompleted
            : l10n.habitsLogFullAction,
        onPressed: completed || !canLogToday || isBusy ? null : onFull,
        icon: isBusy
            ? const SizedBox.square(
                dimension: FlowTokens.iconSmall,
                child: CircularProgressIndicator(
                  strokeWidth: FlowTokens.progressThickness,
                ),
              )
            : Icon(completed ? Icons.check : Icons.check_rounded),
      ),
      PopupMenuButton<String>(
        tooltip: l10n.habitsEditAction,
        onSelected: (String action) {
          switch (action) {
            case 'minimum':
              onMinimum();
            case 'edit':
              onEdit();
            case 'archive':
              onArchive();
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          if (!completed && canLogToday)
            PopupMenuItem<String>(
              value: 'minimum',
              child: Text(l10n.habitsLogMinimumAction),
            ),
          PopupMenuItem<String>(
            value: 'edit',
            child: Text(l10n.habitsEditAction),
          ),
          PopupMenuItem<String>(
            value: 'archive',
            child: Text(l10n.habitsArchiveAction),
          ),
        ],
      ),
      ExcludeSemantics(
        child: Icon(Icons.expand_more, size: FlowTokens.iconSmall),
      ),
    ],
  );
}

class _HabitHeatmap extends StatelessWidget {
  const _HabitHeatmap({
    required this.habit,
    required this.logs,
    required this.date,
    required this.l10n,
  });

  final Habit habit;
  final List<HabitLog> logs;
  final LocalDate date;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final List<Widget> cells = <Widget>[];
    for (int offset = 27; offset >= 0; offset--) {
      final LocalDate day = date.addDays(-offset);
      HabitLogLevel? level;
      for (final HabitLog log in logs) {
        if (log.habitId == habit.id &&
            log.logicalDate == day &&
            log.metadata.deletedAt == null) {
          level = log.level;
          break;
        }
      }
      final bool isScheduled =
          habit.recurrence.isWeeklyTarget ||
          habit.recurrence.isScheduledOn(day);
      final String status = switch (level) {
        HabitLogLevel.full => l10n.habitsHistoryFull,
        HabitLogLevel.minimum => l10n.habitsHistoryMinimum,
        HabitLogLevel.skipped || null => l10n.habitsHistoryMissed,
      };
      final Color cellColor = switch (level) {
        HabitLogLevel.full => Theme.of(context).colorScheme.primary,
        HabitLogLevel.minimum => Theme.of(context).colorScheme.tertiary,
        HabitLogLevel.skipped => Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest,
        null =>
          isScheduled
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Theme.of(context).colorScheme.surfaceContainerLow,
      };
      cells.add(
        Semantics(
          label: '${day.toString()}: $status',
          child: Tooltip(
            message: '${day.toString()} · $status',
            child: Container(
              width: FlowTokens.heatmapCellSize,
              height: FlowTokens.heatmapCellSize,
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(
                  FlowTokens.heatmapCellRadius,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Wrap(
      spacing: FlowTokens.heatmapGap,
      runSpacing: FlowTokens.heatmapGap,
      children: cells,
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Container(
        width: FlowTokens.heatmapCellSize,
        height: FlowTokens.heatmapCellSize,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: FlowTokens.space2),
      Text(label),
    ],
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      Text(value, style: Theme.of(context).textTheme.titleMedium),
    ],
  );
}

class _HabitEditorSheet extends StatefulWidget {
  const _HabitEditorSheet({required this.controller, this.existing});

  final HabitsController controller;
  final Habit? existing;

  @override
  State<_HabitEditorSheet> createState() => _HabitEditorSheetState();
}

class _HabitEditorSheetState extends State<_HabitEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _cue;
  late final TextEditingController _minimum;
  late String _iconId;
  late String _categoryId;
  late RecurrenceKind _frequency;
  late int _weeklyTarget;
  late Set<int> _weekdays;
  late bool _essential;
  late int? _reminderMinute;
  bool _isSaving = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final Habit? habit = widget.existing;
    _name = TextEditingController(text: habit?.name ?? '');
    _cue = TextEditingController(text: habit?.cue ?? '');
    _minimum = TextEditingController(text: habit?.minimumVersion ?? '');
    _iconId = habit?.iconId ?? 'mindfulness';
    _categoryId = habit?.categoryId ?? HabitCategoryId.mind;
    _frequency = habit?.recurrence.kind ?? RecurrenceKind.daily;
    _weeklyTarget = habit?.recurrence.weeklyTarget ?? 3;
    _weekdays = habit?.recurrence.weekdays.toSet() ?? <int>{1, 2, 3, 4, 5};
    _essential = habit?.isEssential ?? false;
    _reminderMinute = habit?.reminderMinute;
  }

  @override
  void dispose() {
    _name.dispose();
    _cue.dispose();
    _minimum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n =
        AppLocalizations.of(context) ?? AppLocalizationsPtBr();
    final int? reminderMinute = _reminderMinute;
    return Padding(
      padding: FlowTokens.formSheetPadding(
        MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: FlowTokens.formMaxWidth),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  widget.existing == null
                      ? l10n.habitsCreateTitle
                      : l10n.habitsEditTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: FlowTokens.space4),
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  maxLength: 60,
                  decoration: InputDecoration(
                    labelText: l10n.habitsNameLabel,
                    hintText: l10n.habitsNameHint,
                  ),
                  validator: (String? value) =>
                      value == null || value.trim().isEmpty
                      ? l10n.habitsNameLabel
                      : null,
                ),
                const SizedBox(height: FlowTokens.space2),
                Text(
                  l10n.habitsIconLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: FlowTokens.space2),
                Wrap(
                  spacing: FlowTokens.space2,
                  runSpacing: FlowTokens.space2,
                  children: <Widget>[
                    for (final String id in _iconIds)
                      ChoiceChip(
                        avatar: Icon(_iconFor(id)),
                        label: Text(_iconLabel(id, l10n)),
                        selected: _iconId == id,
                        onSelected: (_) => setState(() => _iconId = id),
                      ),
                  ],
                ),
                const SizedBox(height: FlowTokens.space4),
                DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: InputDecoration(
                    labelText: l10n.habitsCategoryLabel,
                  ),
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: HabitCategoryId.mind,
                      child: Text(l10n.habitsCategoryMind),
                    ),
                    DropdownMenuItem(
                      value: HabitCategoryId.body,
                      child: Text(l10n.habitsCategoryBody),
                    ),
                    DropdownMenuItem(
                      value: HabitCategoryId.focus,
                      child: Text(l10n.habitsCategoryFocus),
                    ),
                  ],
                  onChanged: (String? value) {
                    if (value != null) setState(() => _categoryId = value);
                  },
                ),
                const SizedBox(height: FlowTokens.space4),
                DropdownButtonFormField<RecurrenceKind>(
                  initialValue: _frequency,
                  decoration: InputDecoration(
                    labelText: l10n.habitsFrequencyLabel,
                  ),
                  items: <DropdownMenuItem<RecurrenceKind>>[
                    DropdownMenuItem(
                      value: RecurrenceKind.daily,
                      child: Text(l10n.habitsFrequencyDaily),
                    ),
                    DropdownMenuItem(
                      value: RecurrenceKind.weekdays,
                      child: Text(l10n.habitsFrequencyWeekdays),
                    ),
                    DropdownMenuItem(
                      value: RecurrenceKind.weeklyTarget,
                      child: Text(l10n.habitsFrequencyWeeklyTarget),
                    ),
                  ],
                  onChanged: (RecurrenceKind? value) {
                    if (value != null) setState(() => _frequency = value);
                  },
                ),
                if (_frequency == RecurrenceKind.weekdays) ...<Widget>[
                  const SizedBox(height: FlowTokens.space3),
                  Text(l10n.habitsWeekdaysLabel),
                  const SizedBox(height: FlowTokens.space2),
                  Wrap(
                    spacing: FlowTokens.space2,
                    children: <Widget>[
                      for (int weekday = 1; weekday <= 7; weekday++)
                        FilterChip(
                          label: Text(_weekdayLabel(weekday, l10n)),
                          selected: _weekdays.contains(weekday),
                          onSelected: (bool selected) => setState(() {
                            if (selected) {
                              _weekdays.add(weekday);
                            } else if (_weekdays.length > 1) {
                              _weekdays.remove(weekday);
                            }
                          }),
                        ),
                    ],
                  ),
                ],
                if (_frequency == RecurrenceKind.weeklyTarget) ...<Widget>[
                  const SizedBox(height: FlowTokens.space3),
                  DropdownButtonFormField<int>(
                    initialValue: _weeklyTarget,
                    decoration: InputDecoration(
                      labelText: l10n.habitsWeeklyTargetLabel,
                    ),
                    items: <DropdownMenuItem<int>>[
                      for (int target = 1; target <= 7; target++)
                        DropdownMenuItem(
                          value: target,
                          child: Text(l10n.habitsWeeklyTargetOption(target)),
                        ),
                    ],
                    onChanged: (int? value) {
                      if (value != null) setState(() => _weeklyTarget = value);
                    },
                  ),
                ],
                const SizedBox(height: FlowTokens.space3),
                TextFormField(
                  controller: _cue,
                  maxLength: 100,
                  decoration: InputDecoration(
                    labelText: l10n.habitsCueLabel,
                    hintText: l10n.habitsCueHint,
                  ),
                ),
                TextFormField(
                  controller: _minimum,
                  maxLength: 100,
                  decoration: InputDecoration(
                    labelText: l10n.habitsMinimumLabel,
                    hintText: l10n.habitsMinimumHint,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.habitsReminderLabel),
                  subtitle: reminderMinute == null
                      ? null
                      : Text(
                          TimeOfDay(
                            hour: reminderMinute ~/ 60,
                            minute: reminderMinute % 60,
                          ).format(context),
                        ),
                  trailing: TextButton(
                    onPressed: _reminderMinute == null
                        ? _chooseReminder
                        : () => setState(() => _reminderMinute = null),
                    child: Text(
                      _reminderMinute == null
                          ? l10n.habitsChooseReminderAction
                          : l10n.habitsRemoveReminderAction,
                    ),
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.habitsEssentialLabel),
                  value: _essential,
                  onChanged: (bool value) => setState(() => _essential = value),
                ),
                const SizedBox(height: FlowTokens.space3),
                AppButton(
                  label: l10n.habitsSaveAction,
                  icon: Icons.check,
                  onPressed: _isSaving ? null : () => _save(l10n),
                ),
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(l10n.habitsCancelAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(AppLocalizations l10n) async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    setState(() => _isSaving = true);
    try {
      final Recurrence recurrence = switch (_frequency) {
        RecurrenceKind.daily => Recurrence.daily(),
        RecurrenceKind.weekdays => Recurrence.weekdays(_weekdays),
        RecurrenceKind.weeklyTarget => Recurrence.weeklyTarget(_weeklyTarget),
        RecurrenceKind.everyNDays => Recurrence.daily(),
        RecurrenceKind.monthlyDay => Recurrence.daily(),
      };
      await widget.controller.saveHabit(
        existing: widget.existing,
        name: _name.text,
        iconId: _iconId,
        categoryId: _categoryId,
        recurrence: recurrence,
        cue: _cue.text,
        minimumVersion: _minimum.text,
        isEssential: _essential,
        reminderMinute: _reminderMinute,
      );
      if (mounted) Navigator.of(context).pop();
    } on Object {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.habitsSaveError)));
      }
    }
  }

  Future<void> _chooseReminder() async {
    final int? reminderMinute = _reminderMinute;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: reminderMinute == null
          ? const TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay(hour: reminderMinute ~/ 60, minute: reminderMinute % 60),
    );
    if (time != null && mounted) {
      setState(() => _reminderMinute = time.hour * 60 + time.minute);
    }
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: FlowTokens.emptyStatePadding,
      child: Column(
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: FlowTokens.space3),
          Text(
            (AppLocalizations.of(context) ?? AppLocalizationsPtBr())
                .habitsLoading,
          ),
        ],
      ),
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String title;
  final String message;
  final String retryLabel;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      EmptyState(title: title, message: message),
      AppButton(label: retryLabel, icon: Icons.refresh, onPressed: onRetry),
    ],
  );
}

class _EmptyHabits extends StatelessWidget {
  const _EmptyHabits({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onCreate,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      EmptyState(title: title, message: message),
      AppButton(label: actionLabel, icon: Icons.add, onPressed: onCreate),
    ],
  );
}

const List<String> _iconIds = <String>[
  'mindfulness',
  'reading',
  'movement',
  'water',
];

IconData _iconFor(String id) => switch (id) {
  'reading' => Icons.menu_book_outlined,
  'movement' => Icons.directions_run_outlined,
  'water' => Icons.self_improvement_outlined,
  _ => Icons.air_outlined,
};

String _iconLabel(String id, AppLocalizations l10n) => switch (id) {
  'reading' => l10n.habitIconReading,
  'movement' => l10n.habitIconMovement,
  'water' => l10n.habitIconWater,
  _ => l10n.habitIconMindfulness,
};

String _weekdayLabel(int weekday, AppLocalizations l10n) => switch (weekday) {
  1 => l10n.weekdayMon,
  2 => l10n.weekdayTue,
  3 => l10n.weekdayWed,
  4 => l10n.weekdayThu,
  5 => l10n.weekdayFri,
  6 => l10n.weekdaySat,
  _ => l10n.weekdaySun,
};

String _levelLabel(HabitLogLevel? level, AppLocalizations l10n) =>
    switch (level) {
      HabitLogLevel.full => l10n.habitsHistoryFull,
      HabitLogLevel.minimum => l10n.habitsHistoryMinimum,
      HabitLogLevel.skipped || null => l10n.habitsHistoryMissed,
    };
