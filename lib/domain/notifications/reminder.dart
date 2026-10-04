import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/tasks/task.dart';

enum ReminderTarget { habit, task }

final class ReminderOccurrence {
  const ReminderOccurrence({
    required this.target,
    required this.sourceId,
    required this.date,
    required this.minute,
  });

  final ReminderTarget target;
  final String sourceId;
  final LocalDate date;
  final int minute;
}

ReminderOccurrence? nextHabitReminder({
  required Habit habit,
  required LocalDate from,
}) {
  final int? minute = habit.reminderMinute;
  if (minute == null || habit.metadata.deletedAt != null) return null;
  for (int offset = 0; offset < 366; offset++) {
    final LocalDate date = from.addDays(offset);
    if (habit.recurrence.isScheduledOn(date)) {
      return ReminderOccurrence(
        target: ReminderTarget.habit,
        sourceId: habit.id,
        date: date,
        minute: minute,
      );
    }
  }
  return null;
}

ReminderOccurrence? taskReminder({
  required Task task,
  required LocalDate from,
}) {
  final LocalDate? date = task.dueDate;
  final int? minute = task.dueMinute;
  if (date == null ||
      minute == null ||
      date.compareTo(from) < 0 ||
      task.metadata.deletedAt != null) {
    return null;
  }
  return ReminderOccurrence(
    target: ReminderTarget.task,
    sourceId: task.id,
    date: date,
    minute: minute,
  );
}
