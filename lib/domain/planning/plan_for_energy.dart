import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/tasks/task.dart';
import 'package:flowstate/domain/planning/planning_state.dart';

enum EnergyPlanItemKind { habit, task, lightWorkout }

final class EnergyPlanItem {
  const EnergyPlanItem({
    required this.kind,
    required this.id,
    required this.title,
    this.streak = 0,
    this.durationMinutes,
  });

  final EnergyPlanItemKind kind;
  final String id;
  final String title;
  final int streak;
  final int? durationMinutes;
}

final class EnergyPlan {
  EnergyPlan({required this.energy, required Iterable<EnergyPlanItem> items})
    : items = List<EnergyPlanItem>.unmodifiable(items),
      isLowEnergy = energy <= 2 {
    if (energy < 1 || energy > 5) throw ArgumentError.value(energy, 'energy');
  }

  final int energy;
  final bool isLowEnergy;
  final List<EnergyPlanItem> items;
}

EnergyPlan planForEnergy(
  PlanningState state, {
  required int energy,
  required LocalDate date,
}) {
  if (energy < 1 || energy > 5) throw ArgumentError.value(energy, 'energy');

  final List<Habit> pendingHabits =
      state.habits
          .where(
            (Habit habit) =>
                state.activeModuleIds.contains('habits') &&
                isHabitPending(
                  habit: habit,
                  logs: state.habitLogs,
                  date: date,
                ) &&
                (!energyIsLow(energy) || habit.isEssential),
          )
          .toList()
        ..sort((Habit a, Habit b) {
          final int aStreak = habitStreak(
            habit: a,
            logs: state.habitLogs,
            through: date,
          );
          final int bStreak = habitStreak(
            habit: b,
            logs: state.habitLogs,
            through: date,
          );
          final int streakOrder = bStreak.compareTo(aStreak);
          return streakOrder != 0 ? streakOrder : a.name.compareTo(b.name);
        });

  final List<Task> pendingTasks =
      state.tasks
          .where(
            (Task task) =>
                state.activeModuleIds.contains('plan') &&
                task.metadata.deletedAt == null &&
                task.isScheduledOn(date) &&
                !isTaskCompleted(
                  task: task,
                  occurrenceDate: date,
                  completions: state.taskCompletions,
                ),
          )
          .toList()
        ..sort(_compareTasks);

  final List<ScheduledWorkout> workouts = state.scheduledWorkouts
      .where(
        (ScheduledWorkout workout) =>
            state.activeModuleIds.contains('workouts') &&
            workout.date == date &&
            workout.isLight,
      )
      .toList();

  final List<EnergyPlanItem> items = <EnergyPlanItem>[];
  if (energyIsLow(energy)) {
    final Task? selectedTask = pendingTasks.isEmpty ? null : pendingTasks.first;
    final ScheduledWorkout? selectedWorkout = workouts.isEmpty
        ? null
        : workouts.first;
    final int reserved =
        (selectedTask == null ? 0 : 1) + (selectedWorkout == null ? 0 : 1);
    final int habitLimit = 3 - reserved;
    for (final Habit habit in pendingHabits.take(habitLimit)) {
      items.add(
        EnergyPlanItem(
          kind: EnergyPlanItemKind.habit,
          id: habit.id,
          title: habit.name,
          streak: habitStreak(
            habit: habit,
            logs: state.habitLogs,
            through: date,
          ),
        ),
      );
    }
    if (selectedTask != null) {
      items.add(
        EnergyPlanItem(
          kind: EnergyPlanItemKind.task,
          id: selectedTask.id,
          title: selectedTask.title,
          durationMinutes: selectedTask.estimatedMinutes,
        ),
      );
    }
    if (selectedWorkout != null) {
      items.add(
        EnergyPlanItem(
          kind: EnergyPlanItemKind.lightWorkout,
          id: selectedWorkout.metadata.id,
          title: selectedWorkout.title,
          durationMinutes: selectedWorkout.durationMinutes,
        ),
      );
    }
  } else {
    for (final Habit habit in pendingHabits) {
      items.add(
        EnergyPlanItem(
          kind: EnergyPlanItemKind.habit,
          id: habit.id,
          title: habit.name,
          streak: habitStreak(
            habit: habit,
            logs: state.habitLogs,
            through: date,
          ),
        ),
      );
    }
    for (final Task task in pendingTasks) {
      items.add(
        EnergyPlanItem(
          kind: EnergyPlanItemKind.task,
          id: task.id,
          title: task.title,
          durationMinutes: task.estimatedMinutes,
        ),
      );
    }
    for (final ScheduledWorkout workout in workouts) {
      items.add(
        EnergyPlanItem(
          kind: EnergyPlanItemKind.lightWorkout,
          id: workout.metadata.id,
          title: workout.title,
          durationMinutes: workout.durationMinutes,
        ),
      );
    }
  }
  return EnergyPlan(energy: energy, items: items);
}

bool energyIsLow(int energy) => energy <= 2;

int _compareTasks(Task a, Task b) {
  final int priorityOrder = b.priority.index.compareTo(a.priority.index);
  if (priorityOrder != 0) return priorityOrder;
  final int aMinute = a.dueMinute ?? 1440;
  final int bMinute = b.dueMinute ?? 1440;
  final int timeOrder = aMinute.compareTo(bMinute);
  return timeOrder != 0 ? timeOrder : a.title.compareTo(b.title);
}
