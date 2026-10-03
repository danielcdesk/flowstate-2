import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/routine/routine_block.dart';
import 'package:flowstate/domain/tasks/task.dart';
import 'package:flowstate/domain/planning/schedule.dart';

import '../fixtures/domain_fixtures.dart';

void main() {
  final LocalDate wednesday = LocalDate(2026, 9, 30);

  group('detectConflicts', () {
    test('finds overlapping block, task and block pairs', () {
      final List<RoutineBlock> blocks = <RoutineBlock>[
        testBlock(
          id: 20,
          startMinute: 540,
          durationMinutes: 60,
          weekdays: const <int>{3},
        ),
        testBlock(
          id: 21,
          startMinute: 570,
          durationMinutes: 60,
          weekdays: const <int>{3},
        ),
      ];
      final Task task = testTask(
        id: 22,
        dueDate: wednesday,
        dueMinute: 585,
        estimatedMinutes: 30,
      );

      final List<ScheduleConflict> conflicts = detectConflicts(
        blocks: blocks.cast(),
        tasks: <Task>[task],
        date: wednesday,
      );

      expect(conflicts, hasLength(3));
      expect(
        conflicts.map(
          (conflict) => <String>{conflict.firstId, conflict.secondId},
        ),
        containsAll(<Set<String>>[
          <String>{testUuid(20), testUuid(21)},
          <String>{testUuid(20), testUuid(22)},
          <String>{testUuid(21), testUuid(22)},
        ]),
      );
    });

    test('treats adjacent intervals as conflict-free', () {
      expect(
        detectConflicts(
          blocks: <RoutineBlock>[
            testBlock(
              startMinute: 540,
              durationMinutes: 60,
              weekdays: const <int>{3},
            ),
          ],
          tasks: <Task>[
            testTask(
              id: 23,
              dueDate: wednesday,
              dueMinute: 600,
              estimatedMinutes: 30,
            ),
          ],
          date: wednesday,
        ),
        isEmpty,
      );
    });

    test('includes a prior-day block that crosses midnight', () {
      final conflicts = detectConflicts(
        blocks: <RoutineBlock>[
          testBlock(
            id: 24,
            startMinute: 1380,
            durationMinutes: 120,
            weekdays: const <int>{2},
          ),
          testBlock(
            id: 25,
            startMinute: 30,
            durationMinutes: 60,
            weekdays: const <int>{3},
          ),
        ],
        tasks: const <Task>[],
        date: wednesday,
      );
      expect(conflicts, hasLength(1));
      expect(conflicts.single.firstId, testUuid(24));
      expect(conflicts.single.secondId, testUuid(25));
    });

    test('ignores undated tasks and tasks without an estimated duration', () {
      expect(
        detectConflicts(
          blocks: const <RoutineBlock>[],
          tasks: <Task>[
            testTask(id: 26, dueDate: wednesday, dueMinute: 600),
            testTask(id: 27, dueMinute: 600, estimatedMinutes: 30),
          ],
          date: wednesday,
        ),
        isEmpty,
      );
    });
  });

  group('findFreeSlots', () {
    test('returns only intervals long enough for the requested task', () {
      final slots = findFreeSlots(
        blocks: <RoutineBlock>[
          testBlock(
            startMinute: 540,
            durationMinutes: 60,
            weekdays: const <int>{3},
          ),
        ],
        tasks: <Task>[
          testTask(
            id: 28,
            dueDate: wednesday,
            dueMinute: 630,
            estimatedMinutes: 30,
          ),
        ],
        date: wednesday,
        durationMinutes: 60,
        windowStartMinute: 480,
        windowEndMinute: 720,
      );
      expect(
        slots.map((slot) => <int>[slot.startMinute, slot.endMinute]),
        <List<int>>[
          <int>[480, 540],
          <int>[660, 720],
        ],
      );
    });

    test('clips overnight routine blocks to the selected date', () {
      final slots = findFreeSlots(
        blocks: <RoutineBlock>[
          testBlock(
            id: 29,
            startMinute: 1380,
            durationMinutes: 120,
            weekdays: const <int>{2},
          ),
        ],
        tasks: const <Task>[],
        date: wednesday,
        durationMinutes: 60,
        windowStartMinute: 0,
        windowEndMinute: 180,
      );
      expect(slots, hasLength(1));
      expect(slots.single.startMinute, 60);
      expect(slots.single.endMinute, 180);
    });

    test(
      'returns the whole search range when there are no scheduled items',
      () {
        final slots = findFreeSlots(
          blocks: const <RoutineBlock>[],
          tasks: const <Task>[],
          date: wednesday,
          durationMinutes: 30,
          windowStartMinute: 420,
          windowEndMinute: 480,
        );
        expect(slots.single.durationMinutes, 60);
      },
    );

    test('rejects invalid duration and same-day windows', () {
      expect(
        () => findFreeSlots(
          blocks: const <RoutineBlock>[],
          tasks: const <Task>[],
          date: wednesday,
          durationMinutes: 0,
          windowStartMinute: 0,
          windowEndMinute: 60,
        ),
        throwsArgumentError,
      );
      expect(
        () => findFreeSlots(
          blocks: const <RoutineBlock>[],
          tasks: const <Task>[],
          date: wednesday,
          durationMinutes: 10,
          windowStartMinute: 1440,
          windowEndMinute: 1500,
        ),
        throwsArgumentError,
      );
    });
  });
}
