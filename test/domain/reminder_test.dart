import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/notifications/reminder.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/tasks/task.dart';

void main() {
  final RecordMetadata metadata = RecordMetadata(
    id: '00000000-0000-4000-8000-000000000010',
    createdAt: DateTime.utc(2026, 10, 1),
    updatedAt: DateTime.utc(2026, 10, 1),
    deviceId: 'test-device',
  );

  test('finds the next scheduled habit reminder after an edit', () {
    final Habit habit = Habit(
      metadata: metadata,
      name: 'Leitura',
      iconId: 'book',
      categoryId: HabitCategoryId.mind,
      recurrence: Recurrence.weekdays(<int>{1, 3}),
      reminderMinute: 540,
    );
    final ReminderOccurrence? occurrence = nextHabitReminder(
      habit: habit,
      from: LocalDate(2026, 10, 2),
    );

    expect(occurrence?.date, LocalDate(2026, 10, 5));
    expect(occurrence?.minute, 540);
  });

  test('does not schedule a task reminder in the past', () {
    final Task task = Task(
      metadata: metadata,
      title: 'Revisar agenda',
      dueDate: LocalDate(2026, 10, 1),
      dueMinute: 600,
    );
    expect(taskReminder(task: task, from: LocalDate(2026, 10, 2)), isNull);
  });
}
