import 'package:flowstate/core/local_date.dart';

enum RecurrenceKind { daily, weekdays, everyNDays, weeklyTarget, monthlyDay }

/// A rule for calendar occurrences. ISO weekdays use Monday=1 through Sunday=7.
final class Recurrence {
  Recurrence._({
    required this.kind,
    this.weekdays = const <int>{},
    this.intervalDays,
    this.anchorDate,
    this.weeklyTarget,
    this.monthlyDay,
  });

  factory Recurrence.daily() => Recurrence._(kind: RecurrenceKind.daily);

  factory Recurrence.weekdays(Set<int> values) {
    if (values.isEmpty || values.any((int day) => day < 1 || day > 7)) {
      throw ArgumentError.value(values, 'values');
    }
    return Recurrence._(
      kind: RecurrenceKind.weekdays,
      weekdays: Set<int>.unmodifiable(values),
    );
  }

  factory Recurrence.everyNDays({
    required int interval,
    required LocalDate anchor,
  }) {
    if (interval < 1) throw ArgumentError.value(interval, 'interval');
    return Recurrence._(
      kind: RecurrenceKind.everyNDays,
      intervalDays: interval,
      anchorDate: anchor,
    );
  }

  factory Recurrence.weeklyTarget(int timesPerWeek) {
    if (timesPerWeek < 1 || timesPerWeek > 7) {
      throw ArgumentError.value(timesPerWeek, 'timesPerWeek');
    }
    return Recurrence._(
      kind: RecurrenceKind.weeklyTarget,
      weeklyTarget: timesPerWeek,
    );
  }

  factory Recurrence.monthlyDay(int day) {
    if (day < 1 || day > 31) throw ArgumentError.value(day, 'day');
    return Recurrence._(kind: RecurrenceKind.monthlyDay, monthlyDay: day);
  }

  final RecurrenceKind kind;
  final Set<int> weekdays;
  final int? intervalDays;
  final LocalDate? anchorDate;
  final int? weeklyTarget;
  final int? monthlyDay;

  int get _interval => intervalDays ?? (throw StateError('Missing interval.'));
  LocalDate get _anchor => anchorDate ?? (throw StateError('Missing anchor.'));
  int get _monthDay => monthlyDay ?? (throw StateError('Missing month day.'));

  bool get isWeeklyTarget => kind == RecurrenceKind.weeklyTarget;

  bool isScheduledOn(LocalDate date) {
    switch (kind) {
      case RecurrenceKind.daily:
        return true;
      case RecurrenceKind.weekdays:
        return weekdays.contains(date.weekday);
      case RecurrenceKind.everyNDays:
        final int difference = date.differenceInDays(_anchor);
        return difference >= 0 && difference % _interval == 0;
      case RecurrenceKind.weeklyTarget:
        return false;
      case RecurrenceKind.monthlyDay:
        final int lastDay = DateTime.utc(date.year, date.month + 1, 0).day;
        return date.day == (_monthDay > lastDay ? lastDay : _monthDay);
    }
  }
}
