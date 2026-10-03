import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';

void main() {
  group('daily recurrence', () {
    test('matches every date including year changes', () {
      final Recurrence rule = Recurrence.daily();
      expect(rule.isScheduledOn(LocalDate(2025, 12, 31)), isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 1, 1)), isTrue);
    });
  });

  group('weekday recurrence', () {
    test('uses ISO Monday through Sunday values', () {
      final Recurrence rule = Recurrence.weekdays(<int>{1, 3, 5});
      expect(rule.isScheduledOn(LocalDate(2026, 9, 28)), isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 9, 30)), isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 10, 1)), isFalse);
    });

    test('rejects empty and out-of-range weekdays', () {
      expect(() => Recurrence.weekdays(<int>{}), throwsArgumentError);
      expect(() => Recurrence.weekdays(<int>{0}), throwsArgumentError);
      expect(() => Recurrence.weekdays(<int>{8}), throwsArgumentError);
    });

    test('copies the caller set to keep the rule immutable', () {
      final Set<int> days = <int>{1, 2};
      final Recurrence rule = Recurrence.weekdays(days);
      days.add(3);
      expect(rule.weekdays, <int>{1, 2});
    });
  });

  group('every N days recurrence', () {
    test('uses an anchor and includes only matching days', () {
      final Recurrence rule = Recurrence.everyNDays(
        interval: 3,
        anchor: LocalDate(2026, 9, 28),
      );
      expect(rule.isScheduledOn(LocalDate(2026, 9, 27)), isFalse);
      expect(rule.isScheduledOn(LocalDate(2026, 9, 28)), isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 10, 1)), isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 10, 2)), isFalse);
    });

    test('rejects intervals shorter than one day', () {
      expect(
        () => Recurrence.everyNDays(interval: 0, anchor: LocalDate(2026, 1, 1)),
        throwsArgumentError,
      );
    });
  });

  group('weekly target recurrence', () {
    test('is a quota rather than a fixed weekday schedule', () {
      final Recurrence rule = Recurrence.weeklyTarget(3);
      expect(rule.isWeeklyTarget, isTrue);
      expect(rule.weeklyTarget, 3);
      expect(rule.isScheduledOn(LocalDate(2026, 9, 30)), isFalse);
    });

    test('accepts quotas from one through seven', () {
      expect(Recurrence.weeklyTarget(1).weeklyTarget, 1);
      expect(Recurrence.weeklyTarget(7).weeklyTarget, 7);
      expect(() => Recurrence.weeklyTarget(0), throwsArgumentError);
      expect(() => Recurrence.weeklyTarget(8), throwsArgumentError);
    });
  });

  group('monthly recurrence', () {
    test('uses the last calendar day for short months and leap years', () {
      final Recurrence rule = Recurrence.monthlyDay(31);
      expect(rule.isScheduledOn(LocalDate(2025, 2, 28)), isTrue);
      expect(rule.isScheduledOn(LocalDate(2024, 2, 29)), isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 4, 30)), isTrue);
      expect(rule.isScheduledOn(LocalDate(2026, 4, 29)), isFalse);
    });

    test('supports first and last valid day values', () {
      expect(
        Recurrence.monthlyDay(1).isScheduledOn(LocalDate(2026, 1, 1)),
        isTrue,
      );
      expect(() => Recurrence.monthlyDay(0), throwsArgumentError);
      expect(() => Recurrence.monthlyDay(32), throwsArgumentError);
    });
  });
}
