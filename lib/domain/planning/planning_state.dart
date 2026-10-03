import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/routine/routine_block.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';
import 'package:flowstate/domain/tasks/task.dart';

final class ScheduledWorkout {
  ScheduledWorkout({
    required this.metadata,
    required this.title,
    required this.date,
    required this.isLight,
    required this.durationMinutes,
  }) {
    if (title.trim().isEmpty) throw ArgumentError.value(title, 'title');
    if (durationMinutes < 1) {
      throw ArgumentError.value(durationMinutes, 'durationMinutes');
    }
  }

  final RecordMetadata metadata;
  final String title;
  final LocalDate date;
  final bool isLight;
  final int durationMinutes;
}

final class PlanningState {
  PlanningState({
    Iterable<Habit> habits = const <Habit>[],
    Iterable<HabitLog> habitLogs = const <HabitLog>[],
    Iterable<Task> tasks = const <Task>[],
    Iterable<TaskCompletion> taskCompletions = const <TaskCompletion>[],
    Iterable<RoutineBlock> routineBlocks = const <RoutineBlock>[],
    Iterable<ScheduledWorkout> scheduledWorkouts = const <ScheduledWorkout>[],
    Set<String> activeModuleIds = const <String>{},
    this.dayStartMinute = 240,
  }) : habits = List<Habit>.unmodifiable(habits),
       habitLogs = List<HabitLog>.unmodifiable(habitLogs),
       tasks = List<Task>.unmodifiable(tasks),
       taskCompletions = List<TaskCompletion>.unmodifiable(taskCompletions),
       routineBlocks = List<RoutineBlock>.unmodifiable(routineBlocks),
       scheduledWorkouts = List<ScheduledWorkout>.unmodifiable(
         scheduledWorkouts,
       ),
       activeModuleIds = Set<String>.unmodifiable(activeModuleIds) {
    if (dayStartMinute < 0 || dayStartMinute >= 1440) {
      throw ArgumentError.value(dayStartMinute, 'dayStartMinute');
    }
  }

  final List<Habit> habits;
  final List<HabitLog> habitLogs;
  final List<Task> tasks;
  final List<TaskCompletion> taskCompletions;
  final List<RoutineBlock> routineBlocks;
  final List<ScheduledWorkout> scheduledWorkouts;
  final Set<String> activeModuleIds;
  final int dayStartMinute;
}

bool isHabitPending({
  required Habit habit,
  required Iterable<HabitLog> logs,
  required LocalDate date,
}) {
  if (habit.metadata.deletedAt != null) return false;
  final List<HabitLog> activeLogs = logs
      .where(
        (HabitLog log) =>
            log.habitId == habit.id && log.metadata.deletedAt == null,
      )
      .toList();
  if (activeLogs.any((HabitLog log) => log.logicalDate == date)) return false;
  if (!habit.recurrence.isWeeklyTarget) {
    return habit.recurrence.isScheduledOn(date);
  }
  final int target =
      habit.recurrence.weeklyTarget ?? (throw StateError('Missing target.'));
  final LocalDate weekStart = date.startOfIsoWeek;
  final int completions = activeLogs
      .where(
        (HabitLog log) =>
            (log.level == HabitLogLevel.full ||
                log.level == HabitLogLevel.minimum) &&
            log.logicalDate.compareTo(weekStart) >= 0 &&
            log.logicalDate.compareTo(weekStart.addDays(7)) < 0,
      )
      .map((HabitLog log) => log.logicalDate)
      .toSet()
      .length;
  return completions < target;
}
