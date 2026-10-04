import 'package:flutter/material.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/design/components/empty_state.dart';
import 'package:flowstate/design/components/hairline_section.dart';
import 'package:flowstate/design/tokens.dart';
import 'package:flowstate/domain/planning/schedule.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/domain/routine/routine_block.dart';
import 'package:flowstate/domain/tasks/task.dart';
import 'package:flowstate/features/plan/application/plan_controller.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({required this.controller, this.onFocusTask, super.key});

  final PlanController controller;
  final ValueChanged<Task>? onFocusTask;

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n =
        AppLocalizations.of(context) ?? AppLocalizationsPtBr();
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final PlanController controller = widget.controller;
        final LocalDate? selected = controller.selectedDate;
        if (selected == null && controller.isLoading) {
          return Center(
            child: Semantics(
              label: l10n.planLoading,
              child: const CircularProgressIndicator(),
            ),
          );
        }
        if (selected == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(l10n.planLoadError),
                const SizedBox(height: FlowTokens.space3),
                FilledButton(
                  onPressed: controller.load,
                  child: Text(l10n.planRetry),
                ),
              ],
            ),
          );
        }
        return _buildPlan(context, l10n, controller, selected);
      },
    );
  }

  Widget _buildPlan(
    BuildContext context,
    AppLocalizations l10n,
    PlanController controller,
    LocalDate selected,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: FlowTokens.contentMaxWidth),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide =
                constraints.maxWidth >= FlowTokens.expandedBreakpoint;
            return ListView(
              padding: FlowTokens.pagePadding,
              children: <Widget>[
                Text(
                  l10n.planTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: FlowTokens.space2),
                Text(l10n.planSubtitle),
                const SizedBox(height: FlowTokens.space4),
                _WeekPicker(
                  selected: selected,
                  onSelect: controller.selectDate,
                  onPrevious: () => controller.selectDate(selected.addDays(-7)),
                  onNext: () => controller.selectDate(selected.addDays(7)),
                ),
                const SizedBox(height: FlowTokens.space6),
                if (controller.error != null)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: FlowTokens.cardPadding,
                      child: Text(l10n.planSaveError),
                    ),
                  ),
                if (controller.conflicts.isNotEmpty)
                  _ConflictNotice(
                    l10n: l10n,
                    details: controller.conflicts
                        .map(
                          (ScheduleConflict conflict) => l10n.planConflictPair(
                            _titleFor(controller, conflict.firstId),
                            _titleFor(controller, conflict.secondId),
                          ),
                        )
                        .toList(growable: false),
                  ),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: _taskSection(context, l10n, controller),
                      ),
                      const SizedBox(width: FlowTokens.space6),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: <Widget>[
                            _routineSection(context, l10n, controller),
                            const SizedBox(height: FlowTokens.space6),
                            _freeSlotsSection(context, l10n, controller),
                            if (controller
                                .unscheduledTasks
                                .isNotEmpty) ...<Widget>[
                              const SizedBox(height: FlowTokens.space6),
                              _unscheduledSection(context, l10n, controller),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                else ...<Widget>[
                  _taskSection(context, l10n, controller),
                  const SizedBox(height: FlowTokens.space6),
                  _routineSection(context, l10n, controller),
                  const SizedBox(height: FlowTokens.space6),
                  _freeSlotsSection(context, l10n, controller),
                  if (controller.unscheduledTasks.isNotEmpty) ...<Widget>[
                    const SizedBox(height: FlowTokens.space6),
                    _unscheduledSection(context, l10n, controller),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _taskSection(
    BuildContext context,
    AppLocalizations l10n,
    PlanController controller,
  ) {
    final List<Task> tasks = controller.dayTasks;
    return HairlineSection(
      title: l10n.planTasksTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: controller.isSaving
                  ? null
                  : () => _editTask(context, l10n, controller),
              icon: const Icon(Icons.add),
              label: Text(l10n.planCreateTask),
            ),
          ),
          if (tasks.isEmpty)
            Padding(
              padding: FlowTokens.sectionPadding,
              child: EmptyState(
                title: l10n.planTasksEmptyTitle,
                message: l10n.planTasksEmptyMessage,
              ),
            )
          else
            for (final Task task in tasks)
              _TaskRow(
                task: task,
                completed: controller.isTaskComplete(task),
                l10n: l10n,
                onComplete: () => _completeTask(controller, task, l10n),
                onEdit: () => _editTask(context, l10n, controller, task),
                onArchive: () => _archiveTask(context, l10n, controller, task),
                onFocus: widget.onFocusTask == null
                    ? null
                    : () => widget.onFocusTask?.call(task),
              ),
        ],
      ),
    );
  }

  Widget _routineSection(
    BuildContext context,
    AppLocalizations l10n,
    PlanController controller,
  ) {
    final List<RoutineBlock> blocks = controller.dayBlocks;
    return HairlineSection(
      title: l10n.planRoutineTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: controller.isSaving
                  ? null
                  : () => _editRoutine(context, l10n, controller),
              icon: const Icon(Icons.add),
              label: Text(l10n.planCreateRoutine),
            ),
          ),
          if (blocks.isEmpty)
            Padding(
              padding: FlowTokens.sectionPadding,
              child: EmptyState(
                title: l10n.planRoutineEmptyTitle,
                message: l10n.planRoutineEmptyMessage,
              ),
            )
          else
            for (final RoutineBlock block in blocks)
              _RoutineRow(
                block: block,
                l10n: l10n,
                onEdit: () => _editRoutine(context, l10n, controller, block),
                onArchive: () =>
                    _archiveRoutine(context, l10n, controller, block),
              ),
        ],
      ),
    );
  }

  Widget _freeSlotsSection(
    BuildContext context,
    AppLocalizations l10n,
    PlanController controller,
  ) {
    final List<FreeSlot> slots = controller.suggestedSlots;
    return HairlineSection(
      title: l10n.planFreeSlotsTitle,
      child: slots.isEmpty
          ? Padding(
              padding: FlowTokens.sectionPadding,
              child: Text(l10n.planSlotsEmpty),
            )
          : Wrap(
              spacing: FlowTokens.space2,
              runSpacing: FlowTokens.space2,
              children: <Widget>[
                for (final FreeSlot slot in slots)
                  ActionChip(
                    avatar: const Icon(Icons.schedule_outlined),
                    label: Text(
                      l10n.planSuggestedSlot(_formatMinute(slot.startMinute)),
                    ),
                    onPressed: () => _editTask(
                      context,
                      l10n,
                      controller,
                      null,
                      slot.startMinute,
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _unscheduledSection(
    BuildContext context,
    AppLocalizations l10n,
    PlanController controller,
  ) {
    return HairlineSection(
      title: l10n.planUnscheduledTitle,
      child: Column(
        children: <Widget>[
          for (final Task task in controller.unscheduledTasks)
            ListTile(
              title: Text(task.title),
              subtitle: Text(l10n.planTaskNoDate),
              trailing: TextButton(
                onPressed: controller.suggestedSlots.isEmpty
                    ? null
                    : () => _chooseSlot(context, l10n, controller, task),
                child: Text(l10n.planScheduleTask),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _editTask(
    BuildContext context,
    AppLocalizations l10n,
    PlanController controller, [
    Task? task,
    int? initialMinute,
  ]) async {
    final LocalDate? date = controller.selectedDate;
    if (date == null) return;
    final _TaskFormValue? result = await showModalBottomSheet<_TaskFormValue>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) => _TaskForm(
        l10n: l10n,
        date: date,
        existing: task,
        initialMinute: initialMinute,
      ),
    );
    if (result == null || !mounted) return;
    await controller.saveTask(
      existing: task,
      title: result.title,
      notes: result.notes,
      date: date,
      dueMinute: result.minute,
      estimatedMinutes: result.duration,
      priority: result.priority,
      recurrence: result.recurrence,
    );
    if (mounted && controller.error == null) {
      _showMessage(l10n.planSaveTask);
    }
  }

  Future<void> _editRoutine(
    BuildContext context,
    AppLocalizations l10n,
    PlanController controller, [
    RoutineBlock? block,
  ]) async {
    final LocalDate? date = controller.selectedDate;
    if (date == null) return;
    final _RoutineFormValue? result =
        await showModalBottomSheet<_RoutineFormValue>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (BuildContext context) =>
              _RoutineForm(l10n: l10n, selectedDate: date, existing: block),
        );
    if (result == null || !mounted) return;
    await controller.saveRoutineBlock(
      existing: block,
      title: result.title,
      startMinute: result.minute,
      durationMinutes: result.duration,
      categoryId: result.category,
      weekdays: result.weekdays,
    );
  }

  Future<void> _completeTask(
    PlanController controller,
    Task task,
    AppLocalizations l10n,
  ) async {
    await controller.completeTask(task);
    if (!mounted || controller.error != null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.planTaskCompleted),
        action: SnackBarAction(
          label: l10n.undoAction,
          onPressed: controller.undoLastCompletion,
        ),
      ),
    );
  }

  Future<void> _archiveTask(
    BuildContext context,
    AppLocalizations l10n,
    PlanController controller,
    Task task,
  ) async {
    final bool confirmed = await _confirmArchive(
      context,
      l10n.planArchiveTask,
      task.title,
      l10n.planCancel,
    );
    if (!confirmed || !mounted) return;
    await controller.archiveTask(task);
    if (mounted && controller.error == null) {
      _showMessage(l10n.planTaskArchived);
    }
  }

  Future<void> _archiveRoutine(
    BuildContext context,
    AppLocalizations l10n,
    PlanController controller,
    RoutineBlock block,
  ) async {
    final bool confirmed = await _confirmArchive(
      context,
      l10n.planArchiveRoutine,
      block.title,
      l10n.planCancel,
    );
    if (!confirmed || !mounted) return;
    await controller.archiveRoutineBlock(block);
    if (mounted && controller.error == null) {
      _showMessage(l10n.planRoutineArchived);
    }
  }

  Future<void> _chooseSlot(
    BuildContext context,
    AppLocalizations l10n,
    PlanController controller,
    Task task,
  ) async {
    final FreeSlot? slot = await showModalBottomSheet<FreeSlot>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            for (final FreeSlot value in controller.suggestedSlots)
              ListTile(
                leading: const Icon(Icons.schedule_outlined),
                title: Text(
                  l10n.planSuggestedSlot(_formatMinute(value.startMinute)),
                ),
                onTap: () => Navigator.of(context).pop(value),
              ),
          ],
        ),
      ),
    );
    if (slot == null || !mounted) return;
    await controller.scheduleTask(task, slot.startMinute);
  }

  Future<bool> _confirmArchive(
    BuildContext context,
    String title,
    String itemName,
    String cancelLabel,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(title),
            content: Text(itemName),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelLabel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(title),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _WeekPicker extends StatelessWidget {
  const _WeekPicker({
    required this.selected,
    required this.onSelect,
    required this.onPrevious,
    required this.onNext,
  });

  final LocalDate selected;
  final ValueChanged<LocalDate> onSelect;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n =
        AppLocalizations.of(context) ?? AppLocalizationsPtBr();
    final List<String> weekdays = <String>[
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    final bool compactLabels =
        MediaQuery.textScalerOf(context).scale(1) >=
        FlowTokens.accessibilityLargeTextScale;
    final LocalDate start = selected.startOfIsoWeek;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              tooltip: l10n.planPreviousWeek,
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                '${_dateLabel(start)} – ${_dateLabel(start.addDays(6))}',
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            IconButton(
              tooltip: l10n.planNextWeek,
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            for (int offset = 0; offset < 7; offset++)
              Expanded(
                child: _WeekDayButton(
                  weekday: compactLabels
                      ? weekdays[offset].substring(0, 1)
                      : weekdays[offset],
                  date: start.addDays(offset),
                  selected: start.addDays(offset) == selected,
                  onTap: () => onSelect(start.addDays(offset)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _WeekDayButton extends StatelessWidget {
  const _WeekDayButton({
    required this.weekday,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final String weekday;
  final LocalDate date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: FlowTokens.planWeekdayPadding,
      child: Semantics(
        button: true,
        selected: selected,
        label: '$weekday ${date.day}/${date.month}',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FlowTokens.radiusMedium),
          child: Container(
            constraints: const BoxConstraints(minHeight: FlowTokens.tapTarget),
            padding: FlowTokens.planWeekdayButtonPadding,
            decoration: BoxDecoration(
              color: selected ? colors.primaryContainer : colors.surface,
              borderRadius: BorderRadius.circular(FlowTokens.radiusMedium),
            ),
            child: Column(
              children: <Widget>[
                Text(weekday),
                const SizedBox(height: FlowTokens.space2),
                Text(
                  date.day.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.completed,
    required this.l10n,
    required this.onComplete,
    required this.onEdit,
    required this.onArchive,
    this.onFocus,
  });

  final Task task;
  final bool completed;
  final AppLocalizations l10n;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback? onFocus;

  @override
  Widget build(BuildContext context) {
    final int? dueMinute = task.dueMinute;
    final int? estimatedMinutes = task.estimatedMinutes;
    final String details = <String>[
      if (dueMinute != null) _formatMinute(dueMinute),
      if (estimatedMinutes != null) l10n.planDurationMinutes(estimatedMinutes),
      _priorityLabel(task.priority, l10n),
    ].join(' · ');
    return Card(
      child: ListTile(
        leading: IconButton(
          tooltip: completed ? l10n.completedStatus : l10n.planCompleteTask,
          onPressed: completed ? null : onComplete,
          icon: Icon(completed ? Icons.check_circle : Icons.circle_outlined),
        ),
        title: Text(task.title),
        subtitle: Text(details),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (onFocus != null)
              IconButton(
                tooltip: l10n.planStartFocus,
                onPressed: onFocus,
                icon: const Icon(Icons.center_focus_strong),
              ),
            PopupMenuButton<String>(
              tooltip: l10n.planEditTask,
              onSelected: (String action) {
                if (action == 'edit') onEdit();
                if (action == 'archive') onArchive();
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text(l10n.planEditTask),
                ),
                PopupMenuItem<String>(
                  value: 'archive',
                  child: Text(l10n.planArchiveTask),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineRow extends StatelessWidget {
  const _RoutineRow({
    required this.block,
    required this.l10n,
    required this.onEdit,
    required this.onArchive,
  });

  final RoutineBlock block;
  final AppLocalizations l10n;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule_outlined),
        title: Text(block.title),
        subtitle: Text(
          '${_formatMinute(block.startMinute)} · ${l10n.planDurationMinutes(block.durationMinutes)}',
        ),
        trailing: PopupMenuButton<String>(
          tooltip: l10n.planEditRoutine,
          onSelected: (String action) {
            if (action == 'edit') onEdit();
            if (action == 'archive') onArchive();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'edit',
              child: Text(l10n.planEditRoutine),
            ),
            PopupMenuItem<String>(
              value: 'archive',
              child: Text(l10n.planArchiveRoutine),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConflictNotice extends StatelessWidget {
  const _ConflictNotice({required this.l10n, required this.details});

  final AppLocalizations l10n;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: const Icon(Icons.warning_amber_outlined),
        title: Text(l10n.planConflictTitle),
        subtitle: Text('${l10n.planConflictMessage}\n${details.join('\n')}'),
      ),
    );
  }
}

class _TaskFormValue {
  const _TaskFormValue({
    required this.title,
    required this.notes,
    required this.minute,
    required this.duration,
    required this.priority,
    required this.recurrence,
  });

  final String title;
  final String? notes;
  final int? minute;
  final int? duration;
  final TaskPriority priority;
  final Recurrence? recurrence;
}

class _TaskForm extends StatefulWidget {
  const _TaskForm({
    required this.l10n,
    required this.date,
    this.existing,
    this.initialMinute,
  });

  final AppLocalizations l10n;
  final LocalDate date;
  final Task? existing;
  final int? initialMinute;

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _title = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.existing?.notes ?? '',
  );
  late final TextEditingController _duration = TextEditingController(
    text:
        (widget.existing?.estimatedMinutes ??
                (widget.initialMinute == null ? null : 25))
            ?.toString() ??
        '',
  );
  late int? _minute = widget.existing?.dueMinute ?? widget.initialMinute;
  late TaskPriority _priority =
      widget.existing?.priority ?? TaskPriority.normal;
  late bool _repeat =
      widget.existing?.recurrence?.kind == RecurrenceKind.weekdays;
  late Set<int> _weekdays = _initialTaskWeekdays(
    widget.existing?.recurrence,
    widget.date,
  );

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _duration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = widget.l10n;
    final int? currentMinute = _minute;
    return Padding(
      padding: FlowTokens.formSheetPadding(
        MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.existing == null
                    ? l10n.planTaskCreateTitle
                    : l10n.planEditTask,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: FlowTokens.space4),
              TextFormField(
                controller: _title,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.planTaskNameLabel),
                validator: (String? value) => value?.trim().isEmpty ?? true
                    ? l10n.planTaskNameLabel
                    : null,
              ),
              const SizedBox(height: FlowTokens.space3),
              TextFormField(
                controller: _notes,
                decoration: InputDecoration(labelText: l10n.planTaskNotesLabel),
                maxLines: 2,
              ),
              const SizedBox(height: FlowTokens.space3),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(l10n.planTimeLabel),
                  Wrap(
                    children: <Widget>[
                      TextButton.icon(
                        onPressed: _chooseTime,
                        icon: const Icon(Icons.schedule_outlined),
                        label: Text(
                          currentMinute == null
                              ? l10n.planNoTime
                              : _formatMinute(currentMinute),
                        ),
                      ),
                      if (currentMinute != null)
                        IconButton(
                          tooltip: l10n.planRemoveTime,
                          onPressed: () => setState(() => _minute = null),
                          icon: const Icon(Icons.close),
                        ),
                    ],
                  ),
                ],
              ),
              TextFormField(
                controller: _duration,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.planDurationLabel),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final int? duration = int.tryParse(value);
                  return duration == null || duration < 1 || duration > 1440
                      ? l10n.planDurationLabel
                      : null;
                },
              ),
              const SizedBox(height: FlowTokens.space3),
              DropdownButtonFormField<TaskPriority>(
                initialValue: _priority,
                decoration: InputDecoration(labelText: l10n.planPriorityLabel),
                items: <DropdownMenuItem<TaskPriority>>[
                  DropdownMenuItem(
                    value: TaskPriority.low,
                    child: Text(l10n.planPriorityLow),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.normal,
                    child: Text(l10n.planPriorityNormal),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.high,
                    child: Text(l10n.planPriorityHigh),
                  ),
                ],
                onChanged: (TaskPriority? value) {
                  if (value != null) setState(() => _priority = value);
                },
              ),
              const SizedBox(height: FlowTokens.space3),
              Text(l10n.planRepeatLabel),
              Wrap(
                spacing: FlowTokens.space2,
                children: <Widget>[
                  ChoiceChip(
                    label: Text(l10n.planRepeatOnce),
                    selected: !_repeat,
                    onSelected: (bool value) =>
                        setState(() => _repeat = !value),
                  ),
                  ChoiceChip(
                    label: Text(l10n.planRepeatWeekdays),
                    selected: _repeat,
                    onSelected: (bool value) => setState(() => _repeat = value),
                  ),
                ],
              ),
              if (_repeat) ...<Widget>[
                Text(l10n.planRepeatOn),
                _WeekdayChips(
                  l10n: l10n,
                  selected: _weekdays,
                  onChanged: (Set<int> value) {
                    if (value.isNotEmpty) setState(() => _weekdays = value);
                  },
                ),
              ],
              const SizedBox(height: FlowTokens.space4),
              FilledButton(onPressed: _save, child: Text(l10n.planSaveTask)),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.planCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseTime() async {
    final int starting = _minute ?? 9 * 60;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: starting ~/ 60, minute: starting % 60),
    );
    if (time != null && mounted) {
      setState(() => _minute = time.hour * 60 + time.minute);
    }
  }

  void _save() {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    if (_repeat && _weekdays.isEmpty) return;
    Navigator.of(context).pop(
      _TaskFormValue(
        title: _title.text,
        notes: _notes.text,
        minute: _minute,
        duration: int.tryParse(_duration.text),
        priority: _priority,
        recurrence: _repeat
            ? Recurrence.weekdays(Set<int>.of(_weekdays))
            : widget.existing?.recurrence?.kind == RecurrenceKind.weekdays
            ? null
            : widget.existing?.recurrence,
      ),
    );
  }
}

class _RoutineForm extends StatefulWidget {
  const _RoutineForm({
    required this.l10n,
    required this.selectedDate,
    required this.existing,
  });

  final AppLocalizations l10n;
  final LocalDate selectedDate;
  final RoutineBlock? existing;

  @override
  State<_RoutineForm> createState() => _RoutineFormState();
}

class _RoutineFormState extends State<_RoutineForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _title = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final TextEditingController _duration = TextEditingController(
    text: (widget.existing?.durationMinutes ?? 60).toString(),
  );
  late int _minute = widget.existing?.startMinute ?? 9 * 60;
  late String _category = widget.existing?.categoryId ?? 'focus';
  late Set<int> _weekdays =
      widget.existing?.weekdays.toSet() ?? <int>{widget.selectedDate.weekday};

  @override
  void dispose() {
    _title.dispose();
    _duration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = widget.l10n;
    return Padding(
      padding: FlowTokens.formSheetPadding(
        MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.existing == null
                    ? l10n.planRoutineCreateTitle
                    : l10n.planEditRoutine,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: FlowTokens.space4),
              TextFormField(
                controller: _title,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.planRoutineNameLabel,
                ),
                validator: (String? value) => value?.trim().isEmpty ?? true
                    ? l10n.planRoutineNameLabel
                    : null,
              ),
              const SizedBox(height: FlowTokens.space3),
              TextButton.icon(
                onPressed: _chooseTime,
                icon: const Icon(Icons.schedule_outlined),
                label: Text('${l10n.planTimeLabel}: ${_formatMinute(_minute)}'),
              ),
              TextFormField(
                controller: _duration,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.planDurationLabel),
                validator: (String? value) {
                  final int? duration = int.tryParse(value ?? '');
                  return duration == null || duration < 1 || duration > 2880
                      ? l10n.planDurationLabel
                      : null;
                },
              ),
              const SizedBox(height: FlowTokens.space3),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: l10n.planRoutineCategoryLabel,
                ),
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem(
                    value: 'mind',
                    child: Text(l10n.planCategoryMind),
                  ),
                  DropdownMenuItem(
                    value: 'body',
                    child: Text(l10n.planCategoryBody),
                  ),
                  DropdownMenuItem(
                    value: 'focus',
                    child: Text(l10n.planCategoryFocus),
                  ),
                ],
                onChanged: (String? value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: FlowTokens.space3),
              Text(l10n.planRepeatOn),
              _WeekdayChips(
                l10n: l10n,
                selected: _weekdays,
                onChanged: (Set<int> value) {
                  if (value.isNotEmpty) setState(() => _weekdays = value);
                },
              ),
              const SizedBox(height: FlowTokens.space4),
              FilledButton(onPressed: _save, child: Text(l10n.planSaveRoutine)),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.planCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _minute ~/ 60, minute: _minute % 60),
    );
    if (time != null && mounted) {
      setState(() => _minute = time.hour * 60 + time.minute);
    }
  }

  void _save() {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate() || _weekdays.isEmpty) return;
    Navigator.of(context).pop(
      _RoutineFormValue(
        title: _title.text.trim(),
        minute: _minute,
        duration: int.parse(_duration.text),
        category: _category,
        weekdays: _weekdays,
      ),
    );
  }
}

class _RoutineFormValue {
  const _RoutineFormValue({
    required this.title,
    required this.minute,
    required this.duration,
    required this.category,
    required this.weekdays,
  });

  final String title;
  final int minute;
  final int duration;
  final String category;
  final Set<int> weekdays;
}

class _WeekdayChips extends StatelessWidget {
  const _WeekdayChips({
    required this.l10n,
    required this.selected,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = <String>[
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    return Wrap(
      spacing: FlowTokens.space2,
      children: <Widget>[
        for (int index = 0; index < labels.length; index++)
          FilterChip(
            label: Text(labels[index]),
            selected: selected.contains(index + 1),
            onSelected: (bool checked) {
              final Set<int> next = Set<int>.of(selected);
              checked ? next.add(index + 1) : next.remove(index + 1);
              onChanged(next);
            },
          ),
      ],
    );
  }
}

String _formatMinute(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';

String _dateLabel(LocalDate date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

String _priorityLabel(TaskPriority priority, AppLocalizations l10n) =>
    switch (priority) {
      TaskPriority.low => l10n.planPriorityLow,
      TaskPriority.normal => l10n.planPriorityNormal,
      TaskPriority.high => l10n.planPriorityHigh,
    };

Set<int> _initialTaskWeekdays(Recurrence? recurrence, LocalDate date) {
  if (recurrence == null || recurrence.kind != RecurrenceKind.weekdays) {
    return <int>{date.weekday};
  }
  return recurrence.weekdays.toSet();
}

String _titleFor(PlanController controller, String id) {
  for (final Task task in controller.tasks) {
    if (task.id == id) return task.title;
  }
  for (final RoutineBlock block in controller.routineBlocks) {
    if (block.id == id) return block.title;
  }
  return id;
}
