import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/gamification/achievements.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/tasks/task.dart';

import '../fixtures/domain_fixtures.dart';

void main() {
  test('contains 30 stable, unique achievement proposals', () {
    expect(proposedAchievements, hasLength(30));
    expect(
      proposedAchievements.map((AchievementDefinition item) => item.id).toSet(),
      hasLength(30),
    );
    for (final AchievementTier tier in AchievementTier.values) {
      expect(
        proposedAchievements.where(
          (AchievementDefinition item) => item.tier == tier,
        ),
        hasLength(10),
      );
    }
  });

  test('evaluates thresholds inclusively and returns immutable results', () {
    const AchievementFacts facts = AchievementFacts(
      successfulHabitLogs: 10,
      fullHabitLogs: 8,
      minimumHabitLogs: 2,
      completedTasks: 0,
      routineBlocks: 0,
      focusSessions: 0,
      workouts: 0,
      energyCheckins: 0,
      totalXp: 50,
      bestStreakDays: 7,
      distinctHabitCategories: 2,
    );
    final achieved = evaluateAchievements(facts: facts);

    expect(
      achieved.map((AchievementDefinition item) => item.id),
      containsAll(<String>[
        'first_steps_bronze',
        'first_steps_silver',
        'steady_rhythm_bronze',
        'steady_rhythm_silver',
        'minimum_counts_bronze',
        'many_paths_bronze',
        'xp_journey_bronze',
      ]),
    );
    expect(() => achieved.clear(), throwsUnsupportedError);
  });

  test(
    'facts ignore deleted and future records and count active ledger events',
    () {
      final LocalDate through = LocalDate(2026, 9, 30);
      final Habit mind = testHabit(id: 1, categoryId: HabitCategoryId.mind);
      final Habit body = testHabit(id: 2, categoryId: HabitCategoryId.body);
      final List<HabitLog> logs = <HabitLog>[
        testHabitLog(
          id: 11,
          habit: mind,
          date: through.addDays(-1),
          level: HabitLogLevel.full,
        ),
        testHabitLog(
          id: 12,
          habit: body,
          date: through,
          level: HabitLogLevel.minimum,
        ),
        testHabitLog(
          id: 13,
          habit: mind,
          date: through.addDays(1),
          level: HabitLogLevel.full,
        ),
      ];
      final XpEvent routineAward = XpEvent(
        metadata: testMetadata(20),
        action: XpAction.routineBlock,
        sourceId: testUuid(21),
        logicalDate: through,
        units: 1,
        xp: 8,
      );
      final AchievementFacts facts = calculateAchievementFacts(
        habits: <Habit>[mind, body],
        habitLogs: logs,
        taskCompletions: <TaskCompletion>[
          TaskCompletion(
            metadata: testMetadata(30),
            taskId: testUuid(31),
            occurrenceDate: through,
          ),
          TaskCompletion(
            metadata: testMetadata(32, deletedAt: DateTime.utc(2026, 9, 30)),
            taskId: testUuid(33),
            occurrenceDate: through,
          ),
        ],
        ledger: <XpEvent>[routineAward],
        through: through,
      );

      expect(facts.successfulHabitLogs, 2);
      expect(facts.fullHabitLogs, 1);
      expect(facts.minimumHabitLogs, 1);
      expect(facts.completedTasks, 1);
      expect(facts.routineBlocks, 1);
      expect(facts.totalXp, 8);
      expect(facts.distinctHabitCategories, 2);
    },
  );
}
