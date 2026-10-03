import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/routine/routine_block.dart';
import 'package:flowstate/domain/tasks/task.dart';

final class ScheduleConflict {
  const ScheduleConflict({required this.firstId, required this.secondId});

  final String firstId;
  final String secondId;
}

final class FreeSlot {
  const FreeSlot({required this.startMinute, required this.endMinute});

  final int startMinute;
  final int endMinute;
  int get durationMinutes => endMinute - startMinute;
}

final class _Interval {
  const _Interval(this.start, this.end, this.id);

  final int start;
  final int end;
  final String id;
}

int _dayIndex(LocalDate date) {
  return DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime.utc(1970)).inDays;
}

List<_Interval> _intervalsForDate({
  required Iterable<RoutineBlock> blocks,
  required Iterable<Task> tasks,
  required LocalDate date,
}) {
  final int targetStart = _dayIndex(date) * 1440;
  final int targetEnd = targetStart + 1440;
  final List<_Interval> intervals = <_Interval>[];

  for (final RoutineBlock block in blocks) {
    for (int offset = -2; offset <= 0; offset++) {
      final LocalDate occurrenceDate = date.addDays(offset);
      if (!block.isScheduledOn(occurrenceDate)) continue;
      final int start = _dayIndex(occurrenceDate) * 1440 + block.startMinute;
      final int end = start + block.durationMinutes;
      final int clippedStart = start > targetStart ? start : targetStart;
      final int clippedEnd = end < targetEnd ? end : targetEnd;
      if (clippedStart < clippedEnd) {
        intervals.add(_Interval(clippedStart, clippedEnd, block.id));
      }
    }
  }

  for (final Task task in tasks) {
    final int? startMinute = task.dueMinute;
    final int? duration = task.estimatedMinutes;
    if (startMinute == null || duration == null || !task.isScheduledOn(date)) {
      continue;
    }
    final int start = targetStart + startMinute;
    intervals.add(_Interval(start, start + duration, task.id));
  }
  return intervals;
}

/// Returns every pair of scheduled, timed items that overlap on [date].
List<ScheduleConflict> detectConflicts({
  required Iterable<RoutineBlock> blocks,
  required Iterable<Task> tasks,
  required LocalDate date,
}) {
  final List<_Interval> intervals = _intervalsForDate(
    blocks: blocks,
    tasks: tasks,
    date: date,
  )..sort((_Interval a, _Interval b) => a.start.compareTo(b.start));
  final List<ScheduleConflict> conflicts = <ScheduleConflict>[];
  for (int first = 0; first < intervals.length; first++) {
    final _Interval left = intervals[first];
    for (int second = first + 1; second < intervals.length; second++) {
      final _Interval right = intervals[second];
      if (right.start >= left.end) break;
      if (left.id != right.id && left.start < right.end) {
        conflicts.add(ScheduleConflict(firstId: left.id, secondId: right.id));
      }
    }
  }
  return List<ScheduleConflict>.unmodifiable(conflicts);
}

/// Finds free intervals inside a same-day window that fit [durationMinutes].
List<FreeSlot> findFreeSlots({
  required Iterable<RoutineBlock> blocks,
  required Iterable<Task> tasks,
  required LocalDate date,
  required int durationMinutes,
  required int windowStartMinute,
  required int windowEndMinute,
}) {
  if (durationMinutes < 1) {
    throw ArgumentError.value(durationMinutes, 'durationMinutes');
  }
  if (windowStartMinute < 0 ||
      windowEndMinute > 1440 ||
      windowStartMinute >= windowEndMinute) {
    throw ArgumentError('The search window must be within one calendar day.');
  }
  final int dayStart = _dayIndex(date) * 1440;
  final int searchStart = dayStart + windowStartMinute;
  final int searchEnd = dayStart + windowEndMinute;
  final List<_Interval> occupied = _intervalsForDate(
    blocks: blocks,
    tasks: tasks,
    date: date,
  )..sort((_Interval a, _Interval b) => a.start.compareTo(b.start));

  final List<FreeSlot> results = <FreeSlot>[];
  int cursor = searchStart;
  for (final _Interval interval in occupied) {
    if (interval.end <= cursor || interval.start >= searchEnd) continue;
    final int freeUntil = interval.start < searchEnd
        ? interval.start
        : searchEnd;
    if (freeUntil - cursor >= durationMinutes) {
      results.add(
        FreeSlot(
          startMinute: cursor - dayStart,
          endMinute: freeUntil - dayStart,
        ),
      );
    }
    if (interval.end > cursor) cursor = interval.end;
    if (cursor >= searchEnd) break;
  }
  if (searchEnd - cursor >= durationMinutes) {
    results.add(
      FreeSlot(startMinute: cursor - dayStart, endMinute: searchEnd - dayStart),
    );
  }
  return List<FreeSlot>.unmodifiable(results);
}
