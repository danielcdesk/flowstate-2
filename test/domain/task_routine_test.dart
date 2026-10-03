import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/domain/routine/routine_block.dart';
import 'package:flowstate/domain/tasks/task.dart';

import '../fixtures/domain_fixtures.dart';

void main() {
  group('Task', () {
    test('validates title, time, estimate and recurrence anchor', () {
      expect(() => testTask(title: ' '), throwsArgumentError);
      expect(
        () => testTask(dueDate: LocalDate(2026, 1, 1), dueMinute: 1440),
        throwsArgumentError,
      );
      expect(() => testTask(estimatedMinutes: 0), throwsArgumentError);
      expect(
        () => Task(
          metadata: testMetadata(40),
          title: 'Recorrente',
          recurrence: Recurrence.daily(),
        ),
        throwsArgumentError,
      );
    });

    test('matches a one-off date and recurring anchor rule', () {
      final Task once = testTask(dueDate: LocalDate(2026, 9, 30));
      expect(once.isScheduledOn(LocalDate(2026, 9, 30)), isTrue);
      expect(once.isScheduledOn(LocalDate(2026, 10, 1)), isFalse);
      final Task recurring = testTask(
        id: 41,
        dueDate: LocalDate(2026, 9, 30),
        recurrence: Recurrence.weekdays(<int>{3}),
      );
      expect(recurring.isScheduledOn(LocalDate(2026, 10, 7)), isTrue);
      expect(recurring.isScheduledOn(LocalDate(2026, 10, 1)), isFalse);
      expect(testTask(id: 42).isScheduledOn(LocalDate(2026, 9, 30)), isFalse);
    });

    test(
      'completion is tied to a task occurrence and excludes deleted rows',
      () {
        final Task task = testTask(dueDate: LocalDate(2026, 9, 30));
        final TaskCompletion completion = TaskCompletion(
          metadata: testMetadata(43),
          taskId: task.id,
          occurrenceDate: LocalDate(2026, 9, 30),
        );
        expect(
          isTaskCompleted(
            task: task,
            occurrenceDate: LocalDate(2026, 9, 30),
            completions: <TaskCompletion>[completion],
          ),
          isTrue,
        );
        expect(
          isTaskCompleted(
            task: task,
            occurrenceDate: LocalDate(2026, 10, 1),
            completions: <TaskCompletion>[completion],
          ),
          isFalse,
        );
        final TaskCompletion deleted = TaskCompletion(
          metadata: testMetadata(44, deletedAt: DateTime.utc(2026, 10, 1)),
          taskId: task.id,
          occurrenceDate: LocalDate(2026, 9, 30),
        );
        expect(
          isTaskCompleted(
            task: task,
            occurrenceDate: LocalDate(2026, 9, 30),
            completions: <TaskCompletion>[deleted],
          ),
          isFalse,
        );
      },
    );
  });

  group('RoutineBlock', () {
    test('validates its title, range, duration, category and weekdays', () {
      expect(() => testBlock(title: ' '), throwsArgumentError);
      expect(() => testBlock(startMinute: 1440), throwsArgumentError);
      expect(() => testBlock(durationMinutes: 0), throwsArgumentError);
      expect(() => testBlock(durationMinutes: 2881), throwsArgumentError);
      expect(
        () => RoutineBlock(
          metadata: testMetadata(45),
          title: 'Bloco',
          startMinute: 0,
          durationMinutes: 10,
          categoryId: ' ',
          weekdays: const <int>{1},
        ),
        throwsArgumentError,
      );
      expect(() => testBlock(weekdays: const <int>{}), throwsArgumentError);
      expect(() => testBlock(weekdays: const <int>{8}), throwsArgumentError);
    });

    test('copies weekdays and matches ISO weekday', () {
      final Set<int> weekdays = <int>{3};
      final RoutineBlock block = testBlock(weekdays: weekdays);
      weekdays.add(4);
      expect(block.weekdays, <int>{3});
      expect(block.isScheduledOn(LocalDate(2026, 9, 30)), isTrue);
      expect(block.isScheduledOn(LocalDate(2026, 10, 1)), isFalse);
    });
  });
}
