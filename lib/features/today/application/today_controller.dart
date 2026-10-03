import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flowstate/core/ids.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/core/logical_date.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/planning/next_action.dart';
import 'package:flowstate/domain/planning/planning_state.dart';
import 'package:flowstate/domain/repositories/habit_repository.dart';
import 'package:flowstate/domain/repositories/routine_repository.dart';
import 'package:flowstate/domain/repositories/task_repository.dart';
import 'package:flowstate/domain/repositories/xp_repository.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';
import 'package:flowstate/domain/tasks/task.dart';
import 'package:flowstate/domain/routine/routine_block.dart';

final class TodaySnapshot {
  TodaySnapshot({
    required this.date,
    required Iterable<Habit> habits,
    required Iterable<HabitLog> habitLogs,
    required Iterable<Task> tasks,
    required Iterable<TaskCompletion> taskCompletions,
    required Iterable<RoutineBlock> routineBlocks,
    required this.nextAction,
    required this.totalXp,
    required this.completedCount,
    required this.totalCount,
  }) : habits = List<Habit>.unmodifiable(habits),
       habitLogs = List<HabitLog>.unmodifiable(habitLogs),
       tasks = List<Task>.unmodifiable(tasks),
       taskCompletions = List<TaskCompletion>.unmodifiable(taskCompletions),
       routineBlocks = List<RoutineBlock>.unmodifiable(routineBlocks);

  final LocalDate date;
  final List<Habit> habits;
  final List<HabitLog> habitLogs;
  final List<Task> tasks;
  final List<TaskCompletion> taskCompletions;
  final List<RoutineBlock> routineBlocks;
  final NextAction? nextAction;
  final int totalXp;
  final int completedCount;
  final int totalCount;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  bool isHabitComplete(Habit habit) => habitLogs.any(
    (HabitLog log) => log.habitId == habit.id && log.logicalDate == date,
  );
}

/// Loads and mutates only through the domain repository contracts.
final class TodayController extends ChangeNotifier {
  TodayController({
    required this.habitRepository,
    required this.taskRepository,
    required this.routineRepository,
    required this.xpRepository,
    required this.clock,
    required this.deviceId,
  });

  final HabitRepository habitRepository;
  final TaskRepository taskRepository;
  final RoutineRepository routineRepository;
  final XpRepository xpRepository;
  final Clock clock;
  final String deviceId;

  TodaySnapshot? snapshot;
  Object? error;
  bool isLoading = false;
  _UndoRecord? _undoRecord;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final DateTime now = clock.now().toLocal();
      final LocalDate date = logicalDate(now, dayStartMinute: 240);
      final LocalDate rangeStart = date.addDays(-1);
      final LocalDate rangeEnd = date.addDays(1);
      final List<Object> records = await Future.wait<Object>(<Future<Object>>[
        habitRepository.getActiveHabits(),
        habitRepository.getHabitLogs(from: rangeStart, through: rangeEnd),
        taskRepository.getActiveTasks(),
        taskRepository.getCompletions(from: rangeStart, through: rangeEnd),
        routineRepository.getActiveBlocks(),
        xpRepository.getLedger(through: date),
      ]);
      final List<Habit> habits = records[0] as List<Habit>;
      final List<HabitLog> habitLogs = records[1] as List<HabitLog>;
      final List<Task> allTasks = records[2] as List<Task>;
      final List<TaskCompletion> completions =
          records[3] as List<TaskCompletion>;
      final List<RoutineBlock> blocks = records[4] as List<RoutineBlock>;
      final List<XpEvent> ledger = records[5] as List<XpEvent>;
      final List<Habit> scheduledHabits = habits
          .where((Habit habit) {
            final bool loggedToday = habitLogs.any(
              (HabitLog log) =>
                  log.habitId == habit.id && log.logicalDate == date,
            );
            return habit.recurrence.isWeeklyTarget
                ? loggedToday ||
                      isHabitPending(habit: habit, logs: habitLogs, date: date)
                : habit.recurrence.isScheduledOn(date);
          })
          .toList(growable: false);
      final List<Task> todayTasks = allTasks
          .where((Task task) => task.isScheduledOn(date))
          .toList(growable: false);
      final PlanningState state = PlanningState(
        habits: habits,
        habitLogs: habitLogs,
        tasks: allTasks,
        taskCompletions: completions,
        routineBlocks: blocks,
        activeModuleIds: const <String>{'habits', 'plan'},
      );
      final int completedHabits = scheduledHabits
          .where(
            (Habit habit) => habitLogs.any(
              (HabitLog log) =>
                  log.habitId == habit.id && log.logicalDate == date,
            ),
          )
          .length;
      final int completedTasks = todayTasks
          .where(
            (Task task) => isTaskCompleted(
              task: task,
              occurrenceDate: date,
              completions: completions,
            ),
          )
          .length;
      snapshot = TodaySnapshot(
        date: date,
        habits: scheduledHabits,
        habitLogs: habitLogs,
        tasks: todayTasks,
        taskCompletions: completions,
        routineBlocks: blocks,
        nextAction: nextAction(state, clock: clock),
        totalXp: totalActiveXp(ledger),
        completedCount: completedHabits + completedTasks,
        totalCount: scheduledHabits.length + todayTasks.length,
      );
    } on Object catch (caught) {
      error = caught;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeHabit(
    Habit habit, {
    HabitLogLevel level = HabitLogLevel.full,
  }) async {
    final TodaySnapshot? current = snapshot;
    if (current == null || current.isHabitComplete(habit)) return;
    final HabitLog log = HabitLog(
      metadata: RecordMetadata.create(clock: clock, deviceId: deviceId),
      habitId: habit.id,
      logicalDate: current.date,
      level: level,
    );
    await habitRepository.saveHabitLog(log);
    await _award(
      action: level == HabitLogLevel.minimum
          ? XpAction.habitMinimum
          : XpAction.habitFull,
      sourceId: habit.id,
      date: current.date,
      units: 1,
    );
    _undoRecord = _UndoRecord(
      kind: _UndoKind.habit,
      sourceId: habit.id,
      date: current.date,
      level: level,
      createdAt: clock.now().toUtc(),
    );
    await load();
  }

  Future<void> completeTask(Task task) async {
    final TodaySnapshot? current = snapshot;
    if (current == null ||
        isTaskCompleted(
          task: task,
          occurrenceDate: current.date,
          completions: current.taskCompletions,
        )) {
      return;
    }
    await taskRepository.saveCompletion(
      TaskCompletion(
        metadata: RecordMetadata.create(clock: clock, deviceId: deviceId),
        taskId: task.id,
        occurrenceDate: current.date,
      ),
    );
    await _award(
      action: XpAction.task,
      sourceId: task.id,
      date: current.date,
      units: 1,
    );
    _undoRecord = _UndoRecord(
      kind: _UndoKind.task,
      sourceId: task.id,
      date: current.date,
      createdAt: clock.now().toUtc(),
    );
    await load();
  }

  Future<void> undoLastCompletion() async {
    final _UndoRecord? record = _undoRecord;
    if (record == null ||
        clock.now().toUtc().difference(record.createdAt) >
            const Duration(seconds: 5)) {
      return;
    }
    final DateTime now = clock.now().toUtc();
    final RecordMetadata metadata = RecordMetadata(
      id: newId(),
      createdAt: now,
      updatedAt: now,
      deletedAt: now,
      deviceId: deviceId,
    );
    if (record.kind == _UndoKind.habit) {
      await habitRepository.saveHabitLog(
        HabitLog(
          metadata: metadata,
          habitId: record.sourceId,
          logicalDate: record.date,
          level: HabitLogLevel.skipped,
        ),
      );
    } else {
      await taskRepository.saveCompletion(
        TaskCompletion(
          metadata: metadata,
          taskId: record.sourceId,
          occurrenceDate: record.date,
        ),
      );
    }
    final XpAction action = record.kind == _UndoKind.habit
        ? record.level == HabitLogLevel.minimum
              ? XpAction.habitMinimum
              : XpAction.habitFull
        : XpAction.task;
    final List<XpEvent> ledger = await xpRepository.getLedger(
      through: record.date,
    );
    for (final XpEvent event in ledger) {
      if (event.action == action &&
          event.sourceId == record.sourceId &&
          event.logicalDate == record.date &&
          event.reversedAt == null) {
        await xpRepository.reverse(event.reverse(clock: clock));
      }
    }
    _undoRecord = null;
    await load();
  }

  Future<void> completeNextAction() async {
    final NextAction? action = snapshot?.nextAction;
    if (action == null) return;
    if (action.kind == NextActionKind.habit) {
      final TodaySnapshot? current = snapshot;
      if (current == null) return;
      for (final Habit habit in current.habits) {
        if (habit.id == action.id) return completeHabit(habit);
      }
    }
    if (action.kind == NextActionKind.task) {
      final TodaySnapshot? current = snapshot;
      if (current == null) return;
      for (final Task task in current.tasks) {
        if (task.id == action.id) return completeTask(task);
      }
    }
  }

  Future<void> _award({
    required XpAction action,
    required String sourceId,
    required LocalDate date,
    required int units,
  }) async {
    final List<XpEvent> ledger = await xpRepository.getLedger(through: date);
    final XpAwardResult result = awardXp(
      ledger: ledger,
      action: action,
      sourceId: sourceId,
      logicalDate: date,
      units: units,
      clock: clock,
      deviceId: deviceId,
    );
    if (!result.awarded) return;
    final XpEvent event = result.events.last;
    await xpRepository.insertIfAbsent(event);
  }
}

enum _UndoKind { habit, task }

final class _UndoRecord {
  const _UndoRecord({
    required this.kind,
    required this.sourceId,
    required this.date,
    required this.createdAt,
    this.level,
  });

  final _UndoKind kind;
  final String sourceId;
  final LocalDate date;
  final DateTime createdAt;
  final HabitLogLevel? level;
}
