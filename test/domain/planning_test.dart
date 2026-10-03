import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/planning/next_action.dart';
import 'package:flowstate/domain/planning/plan_for_energy.dart';
import 'package:flowstate/domain/planning/planning_state.dart';
import 'package:flowstate/domain/routine/routine_block.dart';
import 'package:flowstate/domain/tasks/task.dart';

import '../fixtures/domain_fixtures.dart';

void main() {
  final LocalDate today = LocalDate(2026, 9, 30);

  group('planForEnergy', () {
    test(
      'caps low-energy plan at three with a task and light workout reserved',
      () {
        final state = PlanningState(
          habits: <Habit>[
            testHabit(id: 1),
            testHabit(id: 2),
            testHabit(id: 3),
            testHabit(id: 4),
          ],
          tasks: <Task>[
            testTask(id: 5, dueDate: today, priority: TaskPriority.high),
          ],
          scheduledWorkouts: <ScheduledWorkout>[
            ScheduledWorkout(
              metadata: testMetadata(6),
              title: 'Treino leve',
              date: today,
              isLight: true,
              durationMinutes: 20,
            ),
          ],
          activeModuleIds: const <String>{'habits', 'plan', 'workouts'},
        );

        final plan = planForEnergy(state, energy: 2, date: today);

        expect(plan.isLowEnergy, isTrue);
        expect(plan.items, hasLength(3));
        expect(
          plan.items.map((EnergyPlanItem item) => item.kind),
          containsAll(<EnergyPlanItemKind>[
            EnergyPlanItemKind.habit,
            EnergyPlanItemKind.task,
            EnergyPlanItemKind.lightWorkout,
          ]),
        );
      },
    );

    test(
      'selects higher streak essentials first and ignores inactive modules',
      () {
        final habit = testHabit(id: 10);
        final List<HabitLog> logs = <HabitLog>[
          for (int index = 1; index <= 3; index++)
            testHabitLog(
              id: 30 + index,
              habit: habit,
              date: today.addDays(-index),
              level: HabitLogLevel.full,
            ),
        ];
        final plan = planForEnergy(
          PlanningState(
            habits: <Habit>[habit, testHabit(id: 11, essential: false)],
            habitLogs: logs,
            tasks: <Task>[testTask(id: 12, dueDate: today)],
            activeModuleIds: const <String>{'habits'},
          ),
          energy: 1,
          date: today,
        );

        expect(plan.items, hasLength(1));
        expect(plan.items.single.id, habit.id);
        expect(plan.items.single.streak, 3);
      },
    );

    test(
      'includes all pending items at normal energy and validates energy',
      () {
        final state = PlanningState(
          habits: <Habit>[testHabit(id: 20)],
          tasks: <Task>[testTask(id: 21, dueDate: today)],
          activeModuleIds: const <String>{'habits', 'plan'},
        );
        expect(
          planForEnergy(state, energy: 3, date: today).items,
          hasLength(2),
        );
        expect(
          () => planForEnergy(state, energy: 0, date: today),
          throwsArgumentError,
        );
      },
    );
  });

  group('nextAction', () {
    test('prefers an in-progress block over an upcoming timed task', () {
      final state = PlanningState(
        routineBlocks: <RoutineBlock>[
          testBlock(
            startMinute: 8 * 60,
            durationMinutes: 120,
            weekdays: const <int>{3},
          ),
        ],
        tasks: <Task>[testTask(id: 40, dueDate: today, dueMinute: 10 * 60)],
        activeModuleIds: const <String>{'plan'},
      );

      final action = nextAction(state, clock: fixedClock);

      expect(action?.kind, NextActionKind.routineBlock);
    });

    test(
      'chooses due tasks before essential habits, then falls back to habits',
      () {
        final task = testTask(
          id: 50,
          dueDate: today,
          priority: TaskPriority.high,
        );
        final state = PlanningState(
          habits: <Habit>[testHabit(id: 51)],
          tasks: <Task>[task],
          activeModuleIds: const <String>{'habits', 'plan'},
        );
        expect(nextAction(state, clock: fixedClock)?.id, task.id);

        final habitsOnly = PlanningState(
          habits: <Habit>[testHabit(id: 52)],
          activeModuleIds: const <String>{'habits'},
        );
        expect(
          nextAction(habitsOnly, clock: fixedClock)?.kind,
          NextActionKind.habit,
        );
        expect(
          nextAction(
            PlanningState(activeModuleIds: const <String>{}),
            clock: fixedClock,
          ),
          isNull,
        );
      },
    );

    test('uses the logical-day boundary for early-morning scheduled items', () {
      final state = PlanningState(
        dayStartMinute: 240,
        tasks: <Task>[testTask(id: 60, dueDate: today, dueMinute: 180)],
        activeModuleIds: const <String>{'plan'},
      );

      final action = nextAction(state, clock: fixedClock);

      expect(action?.startsAt, DateTime(2026, 10, 1, 3));
    });
  });
}
