import 'package:flowstate/core/local_date.dart';

final class DailyReviewSnapshot {
  const DailyReviewSnapshot({
    required this.date,
    required this.scheduledHabits,
    required this.completedHabits,
    required this.focusMinutes,
    required this.workoutCompleted,
    required this.recoveryDay,
  });

  final LocalDate date;
  final int scheduledHabits;
  final int completedHabits;
  final int focusMinutes;
  final bool workoutCompleted;
  final bool recoveryDay;
}

final class HabitReviewEvent {
  const HabitReviewEvent({
    required this.habitId,
    required this.date,
    required this.wasScheduled,
    required this.wasCompleted,
    this.performedAtMinute,
  });

  final String habitId;
  final LocalDate date;
  final bool wasScheduled;
  final bool wasCompleted;
  final int? performedAtMinute;
}

final class FocusReviewSession {
  const FocusReviewSession({
    required this.date,
    required this.startMinute,
    required this.durationMinutes,
  });

  final LocalDate date;
  final int startMinute;
  final int durationMinutes;
}

enum WeeklyInsightKind {
  strongestWeekday,
  mostMissedHabit,
  typicalHabitTime,
  bestFocusHour,
  workoutRecoveryBalance,
}

final class WeeklyInsight {
  const WeeklyInsight({
    required this.kind,
    required this.value,
    required this.sampleSize,
    this.secondaryValue,
    this.ratio,
  });

  final WeeklyInsightKind kind;
  final String value;
  final int sampleSize;
  final int? secondaryValue;
  final double? ratio;
}

final class WeeklyReview {
  WeeklyReview({
    required this.isReady,
    required Iterable<WeeklyInsight> insights,
  }) : insights = List<WeeklyInsight>.unmodifiable(insights);

  final bool isReady;
  final List<WeeklyInsight> insights;
}

WeeklyReview calculateWeeklyReview({
  required Iterable<DailyReviewSnapshot> dailyData,
  required Iterable<HabitReviewEvent> habitEvents,
  required Iterable<FocusReviewSession> focusSessions,
  required LocalDate through,
}) {
  final List<DailyReviewSnapshot> allDays = List<DailyReviewSnapshot>.of(
    dailyData,
  );
  final List<HabitReviewEvent> allHabitEvents = List<HabitReviewEvent>.of(
    habitEvents,
  );
  final List<FocusReviewSession> allFocusSessions = List<FocusReviewSession>.of(
    focusSessions,
  );
  for (final DailyReviewSnapshot day in allDays) {
    if (day.scheduledHabits < 0 ||
        day.completedHabits < 0 ||
        day.completedHabits > day.scheduledHabits ||
        day.focusMinutes < 0) {
      throw ArgumentError('Daily review metrics are outside valid ranges.');
    }
  }
  for (final HabitReviewEvent event in allHabitEvents) {
    final int? minute = event.performedAtMinute;
    if (minute != null && (minute < 0 || minute >= 1440)) {
      throw ArgumentError.value(minute, 'performedAtMinute');
    }
  }
  for (final FocusReviewSession session in allFocusSessions) {
    if (session.startMinute < 0 ||
        session.startMinute >= 1440 ||
        session.durationMinutes < 1) {
      throw ArgumentError('Focus review session is outside valid ranges.');
    }
  }
  final LocalDate periodStart = through.addDays(-13);
  final Map<LocalDate, DailyReviewSnapshot> snapshots =
      <LocalDate, DailyReviewSnapshot>{};
  for (final DailyReviewSnapshot day in allDays) {
    if (day.date.compareTo(periodStart) < 0 ||
        day.date.compareTo(through) > 0) {
      continue;
    }
    if (snapshots.containsKey(day.date)) {
      throw ArgumentError.value(day.date, 'dailyData', 'Duplicate date.');
    }
    snapshots[day.date] = day;
  }
  final bool hasFullWindow = List<LocalDate>.generate(
    14,
    (int index) => periodStart.addDays(index),
  ).every(snapshots.containsKey);
  if (!hasFullWindow) {
    return WeeklyReview(isReady: false, insights: const <WeeklyInsight>[]);
  }

  final List<DailyReviewSnapshot> days = snapshots.values.toList()
    ..sort(
      (DailyReviewSnapshot a, DailyReviewSnapshot b) =>
          a.date.compareTo(b.date),
    );
  final List<WeeklyInsight> insights = <WeeklyInsight>[];

  final Map<int, List<DailyReviewSnapshot>> byWeekday =
      <int, List<DailyReviewSnapshot>>{};
  for (final DailyReviewSnapshot day in days) {
    if (day.scheduledHabits == 0) continue;
    byWeekday
        .putIfAbsent(day.date.weekday, () => <DailyReviewSnapshot>[])
        .add(day);
  }
  final List<int> weekdays = byWeekday.keys.toList()
    ..sort((int a, int b) {
      final double rateA = _completionRate(
        byWeekday[a] ?? <DailyReviewSnapshot>[],
      );
      final double rateB = _completionRate(
        byWeekday[b] ?? <DailyReviewSnapshot>[],
      );
      final int rateOrder = rateB.compareTo(rateA);
      return rateOrder != 0 ? rateOrder : a.compareTo(b);
    });
  if (weekdays.isNotEmpty) {
    final int weekday = weekdays.first;
    final List<DailyReviewSnapshot> weekdaySamples =
        byWeekday[weekday] ?? <DailyReviewSnapshot>[];
    insights.add(
      WeeklyInsight(
        kind: WeeklyInsightKind.strongestWeekday,
        value: weekday.toString(),
        sampleSize: weekdaySamples.length,
        ratio: _completionRate(weekdaySamples),
      ),
    );
  }

  final Map<String, List<HabitReviewEvent>> outcomes =
      <String, List<HabitReviewEvent>>{};
  for (final HabitReviewEvent event in allHabitEvents) {
    if (event.date.compareTo(periodStart) >= 0 &&
        event.date.compareTo(through) <= 0 &&
        event.wasScheduled) {
      outcomes
          .putIfAbsent(event.habitId, () => <HabitReviewEvent>[])
          .add(event);
    }
  }
  String? leastConsistentHabit;
  double leastConsistentRate = 2;
  int leastConsistentMisses = 0;
  for (final MapEntry<String, List<HabitReviewEvent>> entry
      in outcomes.entries) {
    final int completed = entry.value
        .where((HabitReviewEvent event) => event.wasCompleted)
        .length;
    final int misses = entry.value.length - completed;
    final double rate = completed / entry.value.length;
    if (rate < leastConsistentRate ||
        (rate == leastConsistentRate && misses > leastConsistentMisses)) {
      leastConsistentHabit = entry.key;
      leastConsistentRate = rate;
      leastConsistentMisses = misses;
    }
  }
  if (leastConsistentHabit != null) {
    final List<HabitReviewEvent> habitSamples =
        outcomes[leastConsistentHabit] ?? <HabitReviewEvent>[];
    insights.add(
      WeeklyInsight(
        kind: WeeklyInsightKind.mostMissedHabit,
        value: leastConsistentHabit,
        sampleSize: habitSamples.length,
        secondaryValue: leastConsistentMisses,
        ratio: leastConsistentRate,
      ),
    );
    final List<int> completionTimes =
        habitSamples
            .where((HabitReviewEvent event) => event.wasCompleted)
            .map((HabitReviewEvent event) => event.performedAtMinute)
            .whereType<int>()
            .toList()
          ..sort();
    if (completionTimes.isNotEmpty) {
      insights.add(
        WeeklyInsight(
          kind: WeeklyInsightKind.typicalHabitTime,
          value: _median(completionTimes).toString(),
          sampleSize: completionTimes.length,
        ),
      );
    }
  }

  final Map<int, int> focusMinutesByHour = <int, int>{};
  for (final FocusReviewSession session in allFocusSessions) {
    if (session.date.compareTo(periodStart) >= 0 &&
        session.date.compareTo(through) <= 0) {
      final int hour = session.startMinute ~/ 60;
      focusMinutesByHour[hour] =
          (focusMinutesByHour[hour] ?? 0) + session.durationMinutes;
    }
  }
  final List<int> focusHours = focusMinutesByHour.keys.toList()
    ..sort((int a, int b) {
      final int minutesA = focusMinutesByHour[a] ?? 0;
      final int minutesB = focusMinutesByHour[b] ?? 0;
      final int minuteOrder = minutesB.compareTo(minutesA);
      return minuteOrder != 0 ? minuteOrder : a.compareTo(b);
    });
  if (focusHours.isNotEmpty) {
    final int hour = focusHours.first;
    insights.add(
      WeeklyInsight(
        kind: WeeklyInsightKind.bestFocusHour,
        value: hour.toString(),
        secondaryValue: focusMinutesByHour[hour],
        sampleSize: allFocusSessions
            .where(
              (FocusReviewSession session) =>
                  session.date.compareTo(periodStart) >= 0 &&
                  session.date.compareTo(through) <= 0 &&
                  session.startMinute ~/ 60 == hour,
            )
            .length,
      ),
    );
  }

  final int workoutDays = days
      .where((DailyReviewSnapshot day) => day.workoutCompleted)
      .length;
  final int recoveryDays = days
      .where((DailyReviewSnapshot day) => day.recoveryDay)
      .length;
  if (workoutDays + recoveryDays > 0) {
    insights.add(
      WeeklyInsight(
        kind: WeeklyInsightKind.workoutRecoveryBalance,
        value: workoutDays.toString(),
        secondaryValue: recoveryDays,
        sampleSize: 14,
      ),
    );
  }

  return WeeklyReview(isReady: true, insights: insights);
}

double _completionRate(List<DailyReviewSnapshot> days) {
  final int scheduled = days.fold<int>(
    0,
    (int total, DailyReviewSnapshot day) => total + day.scheduledHabits,
  );
  final int completed = days.fold<int>(
    0,
    (int total, DailyReviewSnapshot day) => total + day.completedHabits,
  );
  return completed / scheduled;
}

int _median(List<int> sortedValues) {
  final int middle = sortedValues.length ~/ 2;
  if (sortedValues.length.isOdd) return sortedValues[middle];
  return ((sortedValues[middle - 1] + sortedValues[middle]) / 2).round();
}
