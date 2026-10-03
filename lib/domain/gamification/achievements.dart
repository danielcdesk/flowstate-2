import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/tasks/task.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';

enum AchievementTier { bronze, silver, gold }

enum AchievementMetric {
  successfulHabitLogs,
  fullHabitLogs,
  minimumHabitLogs,
  completedTasks,
  routineBlocks,
  focusSessions,
  workouts,
  energyCheckins,
  totalXp,
  bestStreakDays,
  distinctHabitCategories,
}

final class AchievementCondition {
  const AchievementCondition({required this.metric, required this.threshold});

  final AchievementMetric metric;
  final int threshold;
}

final class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.tier,
    required this.condition,
  });

  final String id;
  final AchievementTier tier;
  final AchievementCondition condition;
}

const List<AchievementDefinition> proposedAchievements =
    <AchievementDefinition>[
      AchievementDefinition(
        id: 'first_steps_bronze',
        tier: AchievementTier.bronze,
        condition: AchievementCondition(
          metric: AchievementMetric.successfulHabitLogs,
          threshold: 1,
        ),
      ),
      AchievementDefinition(
        id: 'first_steps_silver',
        tier: AchievementTier.silver,
        condition: AchievementCondition(
          metric: AchievementMetric.successfulHabitLogs,
          threshold: 10,
        ),
      ),
      AchievementDefinition(
        id: 'first_steps_gold',
        tier: AchievementTier.gold,
        condition: AchievementCondition(
          metric: AchievementMetric.successfulHabitLogs,
          threshold: 50,
        ),
      ),
      AchievementDefinition(
        id: 'steady_rhythm_bronze',
        tier: AchievementTier.bronze,
        condition: AchievementCondition(
          metric: AchievementMetric.bestStreakDays,
          threshold: 3,
        ),
      ),
      AchievementDefinition(
        id: 'steady_rhythm_silver',
        tier: AchievementTier.silver,
        condition: AchievementCondition(
          metric: AchievementMetric.bestStreakDays,
          threshold: 7,
        ),
      ),
      AchievementDefinition(
        id: 'steady_rhythm_gold',
        tier: AchievementTier.gold,
        condition: AchievementCondition(
          metric: AchievementMetric.bestStreakDays,
          threshold: 30,
        ),
      ),
      AchievementDefinition(
        id: 'minimum_counts_bronze',
        tier: AchievementTier.bronze,
        condition: AchievementCondition(
          metric: AchievementMetric.minimumHabitLogs,
          threshold: 1,
        ),
      ),
      AchievementDefinition(
        id: 'minimum_counts_silver',
        tier: AchievementTier.silver,
        condition: AchievementCondition(
          metric: AchievementMetric.minimumHabitLogs,
          threshold: 10,
        ),
      ),
      AchievementDefinition(
        id: 'minimum_counts_gold',
        tier: AchievementTier.gold,
        condition: AchievementCondition(
          metric: AchievementMetric.minimumHabitLogs,
          threshold: 50,
        ),
      ),
      AchievementDefinition(
        id: 'task_momentum_bronze',
        tier: AchievementTier.bronze,
        condition: AchievementCondition(
          metric: AchievementMetric.completedTasks,
          threshold: 1,
        ),
      ),
      AchievementDefinition(
        id: 'task_momentum_silver',
        tier: AchievementTier.silver,
        condition: AchievementCondition(
          metric: AchievementMetric.completedTasks,
          threshold: 20,
        ),
      ),
      AchievementDefinition(
        id: 'task_momentum_gold',
        tier: AchievementTier.gold,
        condition: AchievementCondition(
          metric: AchievementMetric.completedTasks,
          threshold: 100,
        ),
      ),
      AchievementDefinition(
        id: 'routine_flow_bronze',
        tier: AchievementTier.bronze,
        condition: AchievementCondition(
          metric: AchievementMetric.routineBlocks,
          threshold: 1,
        ),
      ),
      AchievementDefinition(
        id: 'routine_flow_silver',
        tier: AchievementTier.silver,
        condition: AchievementCondition(
          metric: AchievementMetric.routineBlocks,
          threshold: 20,
        ),
      ),
      AchievementDefinition(
        id: 'routine_flow_gold',
        tier: AchievementTier.gold,
        condition: AchievementCondition(
          metric: AchievementMetric.routineBlocks,
          threshold: 100,
        ),
      ),
      AchievementDefinition(
        id: 'focus_time_bronze',
        tier: AchievementTier.bronze,
        condition: AchievementCondition(
          metric: AchievementMetric.focusSessions,
          threshold: 1,
        ),
      ),
      AchievementDefinition(
        id: 'focus_time_silver',
        tier: AchievementTier.silver,
        condition: AchievementCondition(
          metric: AchievementMetric.focusSessions,
          threshold: 10,
        ),
      ),
      AchievementDefinition(
        id: 'focus_time_gold',
        tier: AchievementTier.gold,
        condition: AchievementCondition(
          metric: AchievementMetric.focusSessions,
          threshold: 50,
        ),
      ),
      AchievementDefinition(
        id: 'body_in_motion_bronze',
        tier: AchievementTier.bronze,
        condition: AchievementCondition(
          metric: AchievementMetric.workouts,
          threshold: 1,
        ),
      ),
      AchievementDefinition(
        id: 'body_in_motion_silver',
        tier: AchievementTier.silver,
        condition: AchievementCondition(
          metric: AchievementMetric.workouts,
          threshold: 8,
        ),
      ),
      AchievementDefinition(
        id: 'body_in_motion_gold',
        tier: AchievementTier.gold,
        condition: AchievementCondition(
          metric: AchievementMetric.workouts,
          threshold: 30,
        ),
      ),
      AchievementDefinition(
        id: 'self_check_bronze',
        tier: AchievementTier.bronze,
        condition: AchievementCondition(
          metric: AchievementMetric.energyCheckins,
          threshold: 1,
        ),
      ),
      AchievementDefinition(
        id: 'self_check_silver',
        tier: AchievementTier.silver,
        condition: AchievementCondition(
          metric: AchievementMetric.energyCheckins,
          threshold: 7,
        ),
      ),
      AchievementDefinition(
        id: 'self_check_gold',
        tier: AchievementTier.gold,
        condition: AchievementCondition(
          metric: AchievementMetric.energyCheckins,
          threshold: 30,
        ),
      ),
      AchievementDefinition(
        id: 'xp_journey_bronze',
        tier: AchievementTier.bronze,
        condition: AchievementCondition(
          metric: AchievementMetric.totalXp,
          threshold: 50,
        ),
      ),
      AchievementDefinition(
        id: 'xp_journey_silver',
        tier: AchievementTier.silver,
        condition: AchievementCondition(
          metric: AchievementMetric.totalXp,
          threshold: 300,
        ),
      ),
      AchievementDefinition(
        id: 'xp_journey_gold',
        tier: AchievementTier.gold,
        condition: AchievementCondition(
          metric: AchievementMetric.totalXp,
          threshold: 1000,
        ),
      ),
      AchievementDefinition(
        id: 'many_paths_bronze',
        tier: AchievementTier.bronze,
        condition: AchievementCondition(
          metric: AchievementMetric.distinctHabitCategories,
          threshold: 2,
        ),
      ),
      AchievementDefinition(
        id: 'many_paths_silver',
        tier: AchievementTier.silver,
        condition: AchievementCondition(
          metric: AchievementMetric.distinctHabitCategories,
          threshold: 3,
        ),
      ),
      AchievementDefinition(
        id: 'many_paths_gold',
        tier: AchievementTier.gold,
        condition: AchievementCondition(
          metric: AchievementMetric.distinctHabitCategories,
          threshold: 4,
        ),
      ),
    ];

final class AchievementFacts {
  const AchievementFacts({
    required this.successfulHabitLogs,
    required this.fullHabitLogs,
    required this.minimumHabitLogs,
    required this.completedTasks,
    required this.routineBlocks,
    required this.focusSessions,
    required this.workouts,
    required this.energyCheckins,
    required this.totalXp,
    required this.bestStreakDays,
    required this.distinctHabitCategories,
  });

  final int successfulHabitLogs;
  final int fullHabitLogs;
  final int minimumHabitLogs;
  final int completedTasks;
  final int routineBlocks;
  final int focusSessions;
  final int workouts;
  final int energyCheckins;
  final int totalXp;
  final int bestStreakDays;
  final int distinctHabitCategories;

  int valueFor(AchievementMetric metric) => switch (metric) {
    AchievementMetric.successfulHabitLogs => successfulHabitLogs,
    AchievementMetric.fullHabitLogs => fullHabitLogs,
    AchievementMetric.minimumHabitLogs => minimumHabitLogs,
    AchievementMetric.completedTasks => completedTasks,
    AchievementMetric.routineBlocks => routineBlocks,
    AchievementMetric.focusSessions => focusSessions,
    AchievementMetric.workouts => workouts,
    AchievementMetric.energyCheckins => energyCheckins,
    AchievementMetric.totalXp => totalXp,
    AchievementMetric.bestStreakDays => bestStreakDays,
    AchievementMetric.distinctHabitCategories => distinctHabitCategories,
  };
}

AchievementFacts calculateAchievementFacts({
  required Iterable<Habit> habits,
  required Iterable<HabitLog> habitLogs,
  required Iterable<TaskCompletion> taskCompletions,
  required Iterable<XpEvent> ledger,
  required LocalDate through,
}) {
  final List<Habit> activeHabits = habits
      .where((Habit habit) => habit.metadata.deletedAt == null)
      .toList();
  final Map<String, Habit> habitsById = <String, Habit>{
    for (final Habit habit in activeHabits) habit.id: habit,
  };
  final List<HabitLog> activeLogs = habitLogs
      .where(
        (HabitLog log) =>
            log.metadata.deletedAt == null &&
            log.logicalDate.compareTo(through) <= 0 &&
            habitsById.containsKey(log.habitId),
      )
      .toList();
  final List<HabitLog> successfulLogs = activeLogs
      .where(
        (HabitLog log) =>
            log.level == HabitLogLevel.full ||
            log.level == HabitLogLevel.minimum,
      )
      .toList();
  final List<XpEvent> activeEvents = ledger
      .where(
        (XpEvent event) =>
            event.isActive && event.logicalDate.compareTo(through) <= 0,
      )
      .toList();

  int bestStreak = 0;
  for (final Habit habit in activeHabits) {
    final Iterable<HabitLog> relatedLogs = activeLogs.where(
      (HabitLog log) => log.habitId == habit.id,
    );
    for (final HabitLog log in relatedLogs) {
      final int streak = habitStreak(
        habit: habit,
        logs: activeLogs,
        through: log.logicalDate,
      );
      if (streak > bestStreak) bestStreak = streak;
    }
  }

  final Set<String> categories = <String>{};
  for (final HabitLog log in successfulLogs) {
    final Habit? habit = habitsById[log.habitId];
    if (habit != null) categories.add(habit.categoryId);
  }
  final int activeXp = activeEvents.fold<int>(
    0,
    (int total, XpEvent event) => total + event.xp,
  );
  return AchievementFacts(
    successfulHabitLogs: successfulLogs.length,
    fullHabitLogs: activeLogs
        .where((HabitLog log) => log.level == HabitLogLevel.full)
        .length,
    minimumHabitLogs: activeLogs
        .where((HabitLog log) => log.level == HabitLogLevel.minimum)
        .length,
    completedTasks: taskCompletions
        .where(
          (TaskCompletion completion) =>
              completion.metadata.deletedAt == null &&
              completion.occurrenceDate.compareTo(through) <= 0,
        )
        .length,
    routineBlocks: activeEvents
        .where((XpEvent event) => event.action == XpAction.routineBlock)
        .length,
    focusSessions: activeEvents
        .where((XpEvent event) => event.action == XpAction.focusSession)
        .length,
    workouts: activeEvents
        .where((XpEvent event) => event.action == XpAction.workout)
        .length,
    energyCheckins: activeEvents
        .where((XpEvent event) => event.action == XpAction.energyCheckin)
        .length,
    totalXp: activeXp,
    bestStreakDays: bestStreak,
    distinctHabitCategories: categories.length,
  );
}

List<AchievementDefinition> evaluateAchievements({
  required AchievementFacts facts,
  Iterable<AchievementDefinition> definitions = proposedAchievements,
}) {
  return List<AchievementDefinition>.unmodifiable(
    definitions.where(
      (AchievementDefinition definition) =>
          facts.valueFor(definition.condition.metric) >=
          definition.condition.threshold,
    ),
  );
}
