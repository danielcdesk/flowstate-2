import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/insights/weekly_review.dart';

void main() {
  final LocalDate through = LocalDate(2026, 9, 30);
  final List<DailyReviewSnapshot> fullWindow =
      List<DailyReviewSnapshot>.generate(
        14,
        (int index) => DailyReviewSnapshot(
          date: through.addDays(index - 13),
          scheduledHabits: 2,
          completedHabits: index.isEven ? 2 : 1,
          focusMinutes: 0,
          workoutCompleted: index == 2,
          recoveryDay: index == 3,
        ),
      );

  test('stays unavailable until all 14 daily snapshots exist', () {
    final review = calculateWeeklyReview(
      dailyData: fullWindow.take(13),
      habitEvents: const <HabitReviewEvent>[],
      focusSessions: const <FocusReviewSession>[],
      through: through,
    );

    expect(review.isReady, isFalse);
    expect(review.insights, isEmpty);
  });

  test('calculates deterministic habit, focus and recovery insights', () {
    final review = calculateWeeklyReview(
      dailyData: fullWindow,
      habitEvents: <HabitReviewEvent>[
        for (int index = 0; index < 14; index++)
          HabitReviewEvent(
            habitId: 'habit-a',
            date: through.addDays(index - 13),
            wasScheduled: true,
            wasCompleted: index % 3 == 0,
            performedAtMinute: index % 3 == 0 ? 600 + index : null,
          ),
      ],
      focusSessions: <FocusReviewSession>[
        FocusReviewSession(
          date: through.addDays(-2),
          startMinute: 9 * 60,
          durationMinutes: 50,
        ),
        FocusReviewSession(
          date: through.addDays(-1),
          startMinute: 9 * 60 + 15,
          durationMinutes: 25,
        ),
        FocusReviewSession(
          date: through,
          startMinute: 14 * 60,
          durationMinutes: 20,
        ),
      ],
      through: through,
    );

    expect(review.isReady, isTrue);
    final Map<WeeklyInsightKind, WeeklyInsight> byKind =
        <WeeklyInsightKind, WeeklyInsight>{
          for (final WeeklyInsight insight in review.insights)
            insight.kind: insight,
        };
    expect(
      byKind[WeeklyInsightKind.strongestWeekday]?.sampleSize,
      greaterThan(0),
    );
    expect(byKind[WeeklyInsightKind.mostMissedHabit]?.value, 'habit-a');
    expect(byKind[WeeklyInsightKind.typicalHabitTime]?.sampleSize, 5);
    expect(byKind[WeeklyInsightKind.bestFocusHour]?.value, '9');
    expect(byKind[WeeklyInsightKind.bestFocusHour]?.secondaryValue, 75);
    expect(byKind[WeeklyInsightKind.workoutRecoveryBalance]?.value, '1');
    expect(byKind[WeeklyInsightKind.workoutRecoveryBalance]?.secondaryValue, 1);
  });

  test(
    'returns readiness with no fabricated habit insights when there is no data',
    () {
      final review = calculateWeeklyReview(
        dailyData: fullWindow.map(
          (DailyReviewSnapshot day) => DailyReviewSnapshot(
            date: day.date,
            scheduledHabits: 0,
            completedHabits: 0,
            focusMinutes: 0,
            workoutCompleted: false,
            recoveryDay: false,
          ),
        ),
        habitEvents: const <HabitReviewEvent>[],
        focusSessions: const <FocusReviewSession>[],
        through: through,
      );
      expect(review.isReady, isTrue);
      expect(review.insights, isEmpty);
    },
  );

  test('rejects invalid metric values', () {
    expect(
      () => calculateWeeklyReview(
        dailyData: <DailyReviewSnapshot>[
          DailyReviewSnapshot(
            date: through,
            scheduledHabits: 1,
            completedHabits: 2,
            focusMinutes: 0,
            workoutCompleted: false,
            recoveryDay: false,
          ),
        ],
        habitEvents: const <HabitReviewEvent>[],
        focusSessions: const <FocusReviewSession>[],
        through: through,
      ),
      throwsArgumentError,
    );
    expect(
      () => calculateWeeklyReview(
        dailyData: fullWindow,
        habitEvents: <HabitReviewEvent>[
          HabitReviewEvent(
            habitId: 'x',
            date: LocalDate(2026, 9, 30),
            wasScheduled: true,
            wasCompleted: false,
            performedAtMinute: 1440,
          ),
        ],
        focusSessions: const <FocusReviewSession>[],
        through: through,
      ),
      throwsArgumentError,
    );
  });

  test(
    'rejects duplicate daily snapshots instead of choosing by input order',
    () {
      expect(
        () => calculateWeeklyReview(
          dailyData: <DailyReviewSnapshot>[...fullWindow, fullWindow.last],
          habitEvents: const <HabitReviewEvent>[],
          focusSessions: const <FocusReviewSession>[],
          through: through,
        ),
        throwsArgumentError,
      );
    },
  );
}
