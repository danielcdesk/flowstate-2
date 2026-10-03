import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';

abstract final class HabitCategoryId {
  static const String mind = 'mind';
  static const String body = 'body';
  static const String focus = 'focus';
}

final class Habit {
  Habit({
    required this.metadata,
    required this.name,
    required this.iconId,
    required this.categoryId,
    required this.recurrence,
    this.cue,
    this.minimumVersion,
    this.isEssential = false,
    this.reminderMinute,
  }) {
    if (name.trim().isEmpty) throw ArgumentError.value(name, 'name');
    if (iconId.trim().isEmpty) throw ArgumentError.value(iconId, 'iconId');
    if (categoryId.trim().isEmpty) {
      throw ArgumentError.value(categoryId, 'categoryId');
    }
    final int? reminder = reminderMinute;
    if (reminder != null && (reminder < 0 || reminder >= 1440)) {
      throw ArgumentError.value(reminder, 'reminderMinute');
    }
  }

  final RecordMetadata metadata;
  final String name;
  final String iconId;
  final String categoryId;
  final Recurrence recurrence;
  final String? cue;
  final String? minimumVersion;
  final bool isEssential;
  final int? reminderMinute;

  String get id => metadata.id;
}

enum HabitLogLevel { full, minimum, skipped }

final class HabitLog {
  HabitLog({
    required this.metadata,
    required this.habitId,
    required this.logicalDate,
    required this.level,
  });

  final RecordMetadata metadata;
  final String habitId;
  final LocalDate logicalDate;
  final HabitLogLevel level;
}

/// Counts successful scheduled days in the current tolerant streak.
int habitStreak({
  required Habit habit,
  required Iterable<HabitLog> logs,
  required LocalDate through,
}) {
  if (habit.metadata.deletedAt != null) return 0;
  final Map<LocalDate, HabitLog> selectedLogs = <LocalDate, HabitLog>{};
  for (final HabitLog log in logs) {
    if (log.habitId == habit.id &&
        log.metadata.deletedAt == null &&
        log.logicalDate.compareTo(through) <= 0) {
      final HabitLog? previous = selectedLogs[log.logicalDate];
      final int updateOrder = previous == null
          ? 1
          : log.metadata.updatedAt.compareTo(previous.metadata.updatedAt);
      if (previous == null ||
          updateOrder > 0 ||
          (updateOrder == 0 &&
              log.metadata.id.compareTo(previous.metadata.id) > 0)) {
        selectedLogs[log.logicalDate] = log;
      }
    }
  }
  final Map<LocalDate, HabitLogLevel> levels = <LocalDate, HabitLogLevel>{
    for (final MapEntry<LocalDate, HabitLog> entry in selectedLogs.entries)
      entry.key: entry.value.level,
  };
  if (levels.isEmpty) return 0;

  if (habit.recurrence.isWeeklyTarget) {
    return _weeklyTargetStreak(habit, levels, through);
  }

  LocalDate cursor = through;
  int successfulDays = 0;
  final Map<LocalDate, int> skipsPerWeek = <LocalDate, int>{};
  bool hasStarted = false;
  while (cursor.compareTo(_oldestDate(levels)) >= 0) {
    if (!habit.recurrence.isScheduledOn(cursor)) {
      cursor = cursor.addDays(-1);
      continue;
    }
    final HabitLogLevel? level = levels[cursor];
    if (level == null && cursor == through && !hasStarted) {
      cursor = cursor.addDays(-1);
      continue;
    }
    if (level == HabitLogLevel.full || level == HabitLogLevel.minimum) {
      successfulDays++;
      hasStarted = true;
    } else if (level == HabitLogLevel.skipped) {
      final LocalDate week = cursor.startOfIsoWeek;
      final int used = (skipsPerWeek[week] ?? 0) + 1;
      if (used > 2) break;
      skipsPerWeek[week] = used;
      hasStarted = true;
    } else {
      break;
    }
    cursor = cursor.addDays(-1);
  }
  return successfulDays;
}

LocalDate _oldestDate(Map<LocalDate, HabitLogLevel> levels) {
  return levels.keys.reduce(
    (LocalDate a, LocalDate b) => a.compareTo(b) < 0 ? a : b,
  );
}

int _weeklyTargetStreak(
  Habit habit,
  Map<LocalDate, HabitLogLevel> levels,
  LocalDate through,
) {
  final Map<LocalDate, Set<LocalDate>> completedByWeek =
      <LocalDate, Set<LocalDate>>{};
  for (final MapEntry<LocalDate, HabitLogLevel> entry in levels.entries) {
    if (entry.value == HabitLogLevel.full ||
        entry.value == HabitLogLevel.minimum) {
      completedByWeek
          .putIfAbsent(entry.key.startOfIsoWeek, () => <LocalDate>{})
          .add(entry.key);
    }
  }
  final int target =
      habit.recurrence.weeklyTarget ?? (throw StateError('Missing target.'));
  int streak = 0;
  LocalDate week = through.startOfIsoWeek;
  while (week.compareTo(_oldestDate(levels).startOfIsoWeek) >= 0) {
    final bool isCurrentWeek = week == through.startOfIsoWeek;
    final int completed = completedByWeek[week]?.length ?? 0;
    if (completed >= target) {
      streak++;
    } else if (isCurrentWeek) {
      // The current week remains open until its final day.
    } else {
      break;
    }
    week = week.addDays(-7);
  }
  return streak;
}
