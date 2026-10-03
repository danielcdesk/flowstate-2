import 'package:clock/clock.dart';

import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/core/logical_date.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/routine/routine_block.dart';
import 'package:flowstate/domain/tasks/task.dart';
import 'package:flowstate/domain/planning/planning_state.dart';

enum NextActionKind { routineBlock, task, habit }

final class NextAction {
  const NextAction({
    required this.kind,
    required this.id,
    required this.title,
    required this.startsAt,
    this.endsAt,
  });

  final NextActionKind kind;
  final String id;
  final String title;
  final DateTime? startsAt;
  final DateTime? endsAt;
}

final class _TimedAction {
  const _TimedAction({
    required this.action,
    required this.startsAt,
    required this.endsAt,
  });

  final NextAction action;
  final DateTime startsAt;
  final DateTime endsAt;

  bool isInProgress(DateTime now) =>
      !startsAt.isAfter(now) && endsAt.isAfter(now);
}

NextAction? nextAction(PlanningState state, {required Clock clock}) {
  final DateTime now = clock.now().toLocal();
  final LocalDate today = logicalDate(
    now,
    dayStartMinute: state.dayStartMinute,
  );
  final List<_TimedAction> timedActions = <_TimedAction>[];
  final Set<LocalDate> candidateDates = <LocalDate>{
    today.addDays(-1),
    today,
    today.addDays(1),
  };

  if (state.activeModuleIds.contains('plan')) {
    for (final RoutineBlock block in state.routineBlocks) {
      if (block.metadata.deletedAt != null) continue;
      for (final LocalDate date in candidateDates) {
        if (!block.isScheduledOn(date)) continue;
        final DateTime start = _atLogicalMinute(
          date,
          block.startMinute,
          state.dayStartMinute,
        );
        final DateTime end = start.add(
          Duration(minutes: block.durationMinutes),
        );
        if (!end.isAfter(now)) continue;
        timedActions.add(
          _TimedAction(
            action: NextAction(
              kind: NextActionKind.routineBlock,
              id: block.id,
              title: block.title,
              startsAt: start,
              endsAt: end,
            ),
            startsAt: start,
            endsAt: end,
          ),
        );
      }
    }

    for (final Task task in state.tasks) {
      final int? minute = task.dueMinute;
      if (minute == null ||
          task.metadata.deletedAt != null ||
          !task.isScheduledOn(today) ||
          isTaskCompleted(
            task: task,
            occurrenceDate: today,
            completions: state.taskCompletions,
          )) {
        continue;
      }
      final DateTime start = _atLogicalMinute(
        today,
        minute,
        state.dayStartMinute,
      );
      final DateTime end = start.add(
        Duration(minutes: task.estimatedMinutes ?? 30),
      );
      if (!end.isAfter(now)) continue;
      timedActions.add(
        _TimedAction(
          action: NextAction(
            kind: NextActionKind.task,
            id: task.id,
            title: task.title,
            startsAt: start,
            endsAt: end,
          ),
          startsAt: start,
          endsAt: end,
        ),
      );
    }
  }

  if (timedActions.isNotEmpty) {
    timedActions.sort((_TimedAction a, _TimedAction b) {
      final bool aActive = a.isInProgress(now);
      final bool bActive = b.isInProgress(now);
      if (aActive != bActive) return aActive ? -1 : 1;
      return aActive
          ? a.endsAt.compareTo(b.endsAt)
          : a.startsAt.compareTo(b.startsAt);
    });
    return timedActions.first.action;
  }

  final List<Task> dueTasks =
      state.tasks
          .where(
            (Task task) =>
                state.activeModuleIds.contains('plan') &&
                task.metadata.deletedAt == null &&
                task.isScheduledOn(today) &&
                !isTaskCompleted(
                  task: task,
                  occurrenceDate: today,
                  completions: state.taskCompletions,
                ),
          )
          .toList()
        ..sort((_compareTasks));
  if (dueTasks.isNotEmpty) {
    final Task task = dueTasks.first;
    final int? minute = task.dueMinute;
    final DateTime? start = minute == null
        ? null
        : _atLogicalMinute(today, minute, state.dayStartMinute);
    return NextAction(
      kind: NextActionKind.task,
      id: task.id,
      title: task.title,
      startsAt: start,
      endsAt: start?.add(Duration(minutes: task.estimatedMinutes ?? 30)),
    );
  }

  final List<Habit> essentials =
      state.habits
          .where(
            (Habit habit) =>
                state.activeModuleIds.contains('habits') &&
                habit.isEssential &&
                isHabitPending(
                  habit: habit,
                  logs: state.habitLogs,
                  date: today,
                ),
          )
          .toList()
        ..sort((Habit a, Habit b) {
          final int aStreak = habitStreak(
            habit: a,
            logs: state.habitLogs,
            through: today,
          );
          final int bStreak = habitStreak(
            habit: b,
            logs: state.habitLogs,
            through: today,
          );
          final int streakOrder = bStreak.compareTo(aStreak);
          return streakOrder != 0 ? streakOrder : a.name.compareTo(b.name);
        });
  if (essentials.isEmpty) return null;
  return NextAction(
    kind: NextActionKind.habit,
    id: essentials.first.id,
    title: essentials.first.name,
    startsAt: null,
  );
}

DateTime _atLogicalMinute(LocalDate date, int minute, int dayStartMinute) {
  final LocalDate calendarDate = minute < dayStartMinute
      ? date.addDays(1)
      : date;
  return DateTime(
    calendarDate.year,
    calendarDate.month,
    calendarDate.day,
  ).add(Duration(minutes: minute));
}

int _compareTasks(Task a, Task b) {
  final int priorityOrder = b.priority.index.compareTo(a.priority.index);
  if (priorityOrder != 0) return priorityOrder;
  final int aMinute = a.dueMinute ?? 1440;
  final int bMinute = b.dueMinute ?? 1440;
  final int timeOrder = aMinute.compareTo(bMinute);
  return timeOrder != 0 ? timeOrder : a.title.compareTo(b.title);
}
