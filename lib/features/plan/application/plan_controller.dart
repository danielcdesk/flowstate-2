import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flowstate/core/ids.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/core/logical_date.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/planning/schedule.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/domain/repositories/routine_repository.dart';
import 'package:flowstate/domain/repositories/task_repository.dart';
import 'package:flowstate/domain/repositories/xp_repository.dart';
import 'package:flowstate/domain/routine/routine_block.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';
import 'package:flowstate/domain/tasks/task.dart';

final class PlanController extends ChangeNotifier {
  PlanController({
    required this.taskRepository,
    required this.routineRepository,
    required this.xpRepository,
    required this.clock,
    required this.deviceId,
    this.onDataChanged,
  });

  final TaskRepository taskRepository;
  final RoutineRepository routineRepository;
  final XpRepository xpRepository;
  final Clock clock;
  final String deviceId;
  final Future<void> Function()? onDataChanged;

  LocalDate? selectedDate;
  List<Task> tasks = <Task>[];
  List<RoutineBlock> routineBlocks = <RoutineBlock>[];
  List<TaskCompletion> completions = <TaskCompletion>[];
  Object? error;
  bool isLoading = false;
  bool isSaving = false;
  _UndoTaskCompletion? _undo;

  List<Task> get dayTasks {
    final LocalDate? date = selectedDate;
    if (date == null) return <Task>[];
    final List<Task> result = tasks
        .where((Task task) => task.isScheduledOn(date))
        .toList();
    result.sort(_compareTasks);
    return List<Task>.unmodifiable(result);
  }

  List<Task> get unscheduledTasks =>
      List<Task>.unmodifiable(tasks.where((Task task) => task.dueDate == null));

  List<RoutineBlock> get dayBlocks {
    final LocalDate? date = selectedDate;
    if (date == null) return <RoutineBlock>[];
    final List<RoutineBlock> result =
        routineBlocks
            .where((RoutineBlock block) => block.isScheduledOn(date))
            .toList()
          ..sort(
            (RoutineBlock a, RoutineBlock b) =>
                a.startMinute.compareTo(b.startMinute),
          );
    return List<RoutineBlock>.unmodifiable(result);
  }

  List<ScheduleConflict> get conflicts {
    final LocalDate? date = selectedDate;
    if (date == null) return <ScheduleConflict>[];
    return detectConflicts(blocks: routineBlocks, tasks: tasks, date: date);
  }

  List<FreeSlot> get suggestedSlots {
    final LocalDate? date = selectedDate;
    if (date == null) return <FreeSlot>[];
    return findFreeSlots(
      blocks: routineBlocks,
      tasks: tasks,
      date: date,
      durationMinutes: 25,
      windowStartMinute: 8 * 60,
      windowEndMinute: 20 * 60,
    ).take(3).toList(growable: false);
  }

  bool isTaskComplete(Task task) {
    final LocalDate? date = selectedDate;
    if (date == null) return false;
    return isTaskCompleted(
      task: task,
      occurrenceDate: date,
      completions: completions,
    );
  }

  Future<void> load({LocalDate? date}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final LocalDate selected =
          date ??
          selectedDate ??
          logicalDate(clock.now().toLocal(), dayStartMinute: 240);
      final List<Object> records = await Future.wait<Object>(<Future<Object>>[
        taskRepository.getActiveTasks(),
        routineRepository.getActiveBlocks(),
        taskRepository.getCompletions(from: selected, through: selected),
      ]);
      tasks = records[0] as List<Task>;
      routineBlocks = records[1] as List<RoutineBlock>;
      completions = records[2] as List<TaskCompletion>;
      selectedDate = selected;
    } on Object catch (caught) {
      error = caught;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectDate(LocalDate date) => load(date: date);

  Future<void> saveTask({
    Task? existing,
    required String title,
    String? notes,
    required LocalDate date,
    required int? dueMinute,
    required int? estimatedMinutes,
    required TaskPriority priority,
    required Recurrence? recurrence,
  }) async {
    final DateTime now = clock.now().toUtc();
    final String? cleanNotes = _cleanOptional(notes);
    final Task updated = Task(
      metadata: existing == null
          ? RecordMetadata.create(clock: clock, deviceId: deviceId)
          : RecordMetadata(
              id: existing.id,
              createdAt: existing.metadata.createdAt,
              updatedAt: now,
              deletedAt: null,
              deviceId: existing.metadata.deviceId,
            ),
      title: title.trim(),
      notes: cleanNotes,
      dueDate: date,
      dueMinute: dueMinute,
      estimatedMinutes: estimatedMinutes,
      priority: priority,
      projectId: existing?.projectId,
      recurrence: recurrence,
    );
    await _perform(
      () => taskRepository.saveTask(updated),
      changedInToday: true,
    );
  }

  Future<void> scheduleTask(Task task, int startMinute) async {
    final LocalDate? date = selectedDate;
    if (date == null || startMinute < 0 || startMinute >= 1440) return;
    await saveTask(
      existing: task,
      title: task.title,
      notes: task.notes,
      date: date,
      dueMinute: startMinute,
      estimatedMinutes: task.estimatedMinutes ?? 25,
      priority: task.priority,
      recurrence: null,
    );
  }

  Future<void> archiveTask(Task task) async {
    final DateTime now = clock.now().toUtc();
    await _perform(
      () => taskRepository.saveTask(
        Task(
          metadata: RecordMetadata(
            id: task.id,
            createdAt: task.metadata.createdAt,
            updatedAt: now,
            deletedAt: now,
            deviceId: task.metadata.deviceId,
          ),
          title: task.title,
          notes: task.notes,
          dueDate: task.dueDate,
          dueMinute: task.dueMinute,
          estimatedMinutes: task.estimatedMinutes,
          priority: task.priority,
          projectId: task.projectId,
          recurrence: task.recurrence,
        ),
      ),
      changedInToday: true,
    );
  }

  Future<void> saveRoutineBlock({
    RoutineBlock? existing,
    required String title,
    required int startMinute,
    required int durationMinutes,
    required String categoryId,
    required Set<int> weekdays,
  }) async {
    final DateTime now = clock.now().toUtc();
    final RoutineBlock block = RoutineBlock(
      metadata: existing == null
          ? RecordMetadata.create(clock: clock, deviceId: deviceId)
          : RecordMetadata(
              id: existing.id,
              createdAt: existing.metadata.createdAt,
              updatedAt: now,
              deletedAt: null,
              deviceId: existing.metadata.deviceId,
            ),
      title: title.trim(),
      startMinute: startMinute,
      durationMinutes: durationMinutes,
      categoryId: categoryId,
      weekdays: weekdays,
    );
    await _perform(
      () => routineRepository.saveBlock(block),
      changedInToday: true,
    );
  }

  Future<void> archiveRoutineBlock(RoutineBlock block) async {
    final DateTime now = clock.now().toUtc();
    await _perform(
      () => routineRepository.saveBlock(
        RoutineBlock(
          metadata: RecordMetadata(
            id: block.id,
            createdAt: block.metadata.createdAt,
            updatedAt: now,
            deletedAt: now,
            deviceId: block.metadata.deviceId,
          ),
          title: block.title,
          startMinute: block.startMinute,
          durationMinutes: block.durationMinutes,
          categoryId: block.categoryId,
          weekdays: block.weekdays,
        ),
      ),
      changedInToday: true,
    );
  }

  Future<void> completeTask(Task task) async {
    final LocalDate? date = selectedDate;
    if (date == null || isTaskComplete(task) || isSaving) return;
    final DateTime now = clock.now().toUtc();
    isSaving = true;
    notifyListeners();
    try {
      await taskRepository.saveCompletion(
        TaskCompletion(
          metadata: RecordMetadata.create(clock: clock, deviceId: deviceId),
          taskId: task.id,
          occurrenceDate: date,
        ),
      );
      final List<XpEvent> ledger = await xpRepository.getLedger(through: date);
      final XpAwardResult award = awardXp(
        ledger: ledger,
        action: XpAction.task,
        sourceId: task.id,
        logicalDate: date,
        units: 1,
        clock: clock,
        deviceId: deviceId,
      );
      if (award.awarded) await xpRepository.insertIfAbsent(award.events.last);
      _undo = _UndoTaskCompletion(taskId: task.id, date: date, createdAt: now);
      await load(date: date);
      await onDataChanged?.call();
    } on Object catch (caught) {
      error = caught;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> undoLastCompletion() async {
    final _UndoTaskCompletion? undo = _undo;
    if (undo == null ||
        clock.now().toUtc().difference(undo.createdAt) >
            const Duration(seconds: 5)) {
      return;
    }
    final DateTime now = clock.now().toUtc();
    await taskRepository.saveCompletion(
      TaskCompletion(
        metadata: RecordMetadata(
          id: newId(),
          createdAt: now,
          updatedAt: now,
          deletedAt: now,
          deviceId: deviceId,
        ),
        taskId: undo.taskId,
        occurrenceDate: undo.date,
      ),
    );
    final List<XpEvent> ledger = await xpRepository.getLedger(
      through: undo.date,
    );
    for (final XpEvent event in ledger) {
      if (event.action == XpAction.task &&
          event.sourceId == undo.taskId &&
          event.logicalDate == undo.date &&
          event.reversedAt == null) {
        await xpRepository.reverse(event.reverse(clock: clock));
      }
    }
    _undo = null;
    await load(date: undo.date);
    await onDataChanged?.call();
  }

  Future<void> _perform(
    Future<void> Function() operation, {
    bool changedInToday = false,
  }) async {
    if (isSaving) return;
    final LocalDate? date = selectedDate;
    isSaving = true;
    notifyListeners();
    try {
      await operation();
      await load(date: date);
      if (changedInToday) await onDataChanged?.call();
    } on Object catch (caught) {
      error = caught;
      notifyListeners();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}

int _compareTasks(Task a, Task b) {
  final int aMinute = a.dueMinute ?? 1440;
  final int bMinute = b.dueMinute ?? 1440;
  final int minuteOrder = aMinute.compareTo(bMinute);
  if (minuteOrder != 0) return minuteOrder;
  final int priorityOrder = b.priority.index.compareTo(a.priority.index);
  return priorityOrder != 0 ? priorityOrder : a.title.compareTo(b.title);
}

String? _cleanOptional(String? value) {
  final String cleaned = value?.trim() ?? '';
  return cleaned.isEmpty ? null : cleaned;
}

final class _UndoTaskCompletion {
  const _UndoTaskCompletion({
    required this.taskId,
    required this.date,
    required this.createdAt,
  });

  final String taskId;
  final LocalDate date;
  final DateTime createdAt;
}
