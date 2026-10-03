import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';

import '../fixtures/domain_fixtures.dart';

void main() {
  group('habit validation', () {
    test('requires a name, stable icon and category identifiers', () {
      expect(
        () => Habit(
          metadata: testMetadata(1),
          name: ' ',
          iconId: 'icon',
          categoryId: 'mind',
          recurrence: Recurrence.daily(),
        ),
        throwsArgumentError,
      );
      expect(
        () => Habit(
          metadata: testMetadata(2),
          name: 'Nome',
          iconId: '',
          categoryId: 'mind',
          recurrence: Recurrence.daily(),
        ),
        throwsArgumentError,
      );
      expect(
        () => Habit(
          metadata: testMetadata(3),
          name: 'Nome',
          iconId: 'book',
          categoryId: ' ',
          recurrence: Recurrence.daily(),
        ),
        throwsArgumentError,
      );
      expect(
        () => Habit(
          metadata: testMetadata(4),
          name: 'Nome',
          iconId: 'book',
          categoryId: 'mind',
          recurrence: Recurrence.daily(),
          reminderMinute: 1440,
        ),
        throwsArgumentError,
      );
    });
  });

  group('daily habit streak', () {
    final Habit habit = testHabit();
    final LocalDate today = LocalDate(2026, 9, 30);

    test(
      'counts full and minimum logs and tolerates an uncompleted current day',
      () {
        final List<HabitLog> logs = <HabitLog>[
          testHabitLog(
            id: 1,
            habit: habit,
            date: LocalDate(2026, 9, 27),
            level: HabitLogLevel.full,
          ),
          testHabitLog(
            id: 2,
            habit: habit,
            date: LocalDate(2026, 9, 28),
            level: HabitLogLevel.minimum,
          ),
          testHabitLog(
            id: 3,
            habit: habit,
            date: LocalDate(2026, 9, 29),
            level: HabitLogLevel.full,
          ),
        ];
        expect(habitStreak(habit: habit, logs: logs, through: today), 3);
      },
    );

    test('a past scheduled day without a log breaks the streak', () {
      final List<HabitLog> logs = <HabitLog>[
        testHabitLog(
          id: 1,
          habit: habit,
          date: LocalDate(2026, 9, 28),
          level: HabitLogLevel.full,
        ),
        testHabitLog(
          id: 2,
          habit: habit,
          date: LocalDate(2026, 9, 30),
          level: HabitLogLevel.full,
        ),
      ];
      expect(habitStreak(habit: habit, logs: logs, through: today), 1);
    });

    test('allows up to two skipped days in an ISO week, but not a third', () {
      final List<HabitLog> twoSkips = <HabitLog>[
        testHabitLog(
          id: 1,
          habit: habit,
          date: LocalDate(2026, 9, 28),
          level: HabitLogLevel.full,
        ),
        testHabitLog(
          id: 2,
          habit: habit,
          date: LocalDate(2026, 9, 29),
          level: HabitLogLevel.skipped,
        ),
        testHabitLog(
          id: 3,
          habit: habit,
          date: LocalDate(2026, 9, 30),
          level: HabitLogLevel.skipped,
        ),
      ];
      expect(habitStreak(habit: habit, logs: twoSkips, through: today), 1);
      final List<HabitLog> threeSkips = <HabitLog>[
        ...twoSkips,
        testHabitLog(
          id: 4,
          habit: habit,
          date: LocalDate(2026, 10, 1),
          level: HabitLogLevel.skipped,
        ),
      ];
      expect(
        habitStreak(
          habit: habit,
          logs: threeSkips,
          through: LocalDate(2026, 10, 1),
        ),
        0,
      );
    });

    test('ignores unscheduled weekdays and deleted logs', () {
      final Habit weekdays = testHabit(
        recurrence: Recurrence.weekdays(<int>{1, 3, 5}),
      );
      final List<HabitLog> logs = <HabitLog>[
        testHabitLog(
          id: 1,
          habit: weekdays,
          date: LocalDate(2026, 9, 28),
          level: HabitLogLevel.full,
        ),
        testHabitLog(
          id: 2,
          habit: weekdays,
          date: LocalDate(2026, 9, 29),
          level: HabitLogLevel.skipped,
        ),
        testHabitLog(
          id: 3,
          habit: weekdays,
          date: LocalDate(2026, 9, 30),
          level: HabitLogLevel.full,
          deletedAt: DateTime.utc(2026, 10, 1),
        ),
      ];
      expect(habitStreak(habit: weekdays, logs: logs, through: today), 1);
      expect(
        habitStreak(
          habit: weekdays,
          logs: <HabitLog>[
            testHabitLog(
              id: 4,
              habit: weekdays,
              date: LocalDate(2026, 9, 30),
              level: HabitLogLevel.full,
              deletedAt: DateTime.utc(2026, 10, 1),
            ),
          ],
          through: today,
        ),
        0,
      );
    });

    test('returns zero for a deleted habit', () {
      final Habit deleted = Habit(
        metadata: testMetadata(9, deletedAt: DateTime.utc(2026, 9, 30)),
        name: 'Excluído',
        iconId: 'icon',
        categoryId: HabitCategoryId.mind,
        recurrence: Recurrence.daily(),
      );
      expect(
        habitStreak(habit: deleted, logs: const <HabitLog>[], through: today),
        0,
      );
    });

    test(
      'uses a stable ID tie-breaker for duplicate logs with equal timestamps',
      () {
        final List<HabitLog> duplicates = <HabitLog>[
          testHabitLog(
            id: 2,
            habit: habit,
            date: LocalDate(2026, 9, 29),
            level: HabitLogLevel.full,
          ),
          testHabitLog(
            id: 1,
            habit: habit,
            date: LocalDate(2026, 9, 29),
            level: HabitLogLevel.skipped,
          ),
        ];

        expect(habitStreak(habit: habit, logs: duplicates, through: today), 1);
        expect(
          habitStreak(habit: habit, logs: duplicates.reversed, through: today),
          1,
        );
      },
    );
  });

  group('weekly target streak', () {
    final Habit habit = testHabit(recurrence: Recurrence.weeklyTarget(3));

    test('keeps a completed prior week while the current week is open', () {
      final List<HabitLog> logs = <HabitLog>[
        for (int day = 21; day <= 23; day++)
          testHabitLog(
            id: day,
            habit: habit,
            date: LocalDate(2026, 9, day),
            level: HabitLogLevel.full,
          ),
      ];
      expect(
        habitStreak(habit: habit, logs: logs, through: LocalDate(2026, 9, 30)),
        1,
      );
    });

    test('counts consecutive completed weeks and stops at a missed week', () {
      final List<HabitLog> logs = <HabitLog>[
        for (final int day in <int>[14, 15, 16, 21, 22, 23, 28, 29, 30])
          testHabitLog(
            id: day,
            habit: habit,
            date: LocalDate(2026, 9, day),
            level: HabitLogLevel.minimum,
          ),
      ];
      expect(
        habitStreak(habit: habit, logs: logs, through: LocalDate(2026, 9, 30)),
        3,
      );
      final List<HabitLog> withGap = logs
          .where((HabitLog log) => log.logicalDate.day < 21)
          .toList();
      expect(
        habitStreak(
          habit: habit,
          logs: withGap,
          through: LocalDate(2026, 9, 30),
        ),
        0,
      );
    });
  });
}
