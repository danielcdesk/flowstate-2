import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/domain/planning/next_action.dart';

import '../../fixtures/domain_fixtures.dart';
import '../../fixtures/today_controller_fixture.dart';

void main() {
  test('loads local records and persists completion with ledger XP', () async {
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    final DriftHabitRepository habits = DriftHabitRepository(fixture.database);
    final DriftTaskRepository tasks = DriftTaskRepository(fixture.database);
    final habit = testHabit(id: 71);
    final task = testTask(id: 72, dueDate: testDate(2026, 9, 30));
    await habits.saveHabit(habit);
    await tasks.saveTask(task);

    await fixture.controller.load();
    expect(fixture.controller.snapshot?.totalCount, 2);
    expect(fixture.controller.snapshot?.nextAction?.kind, NextActionKind.task);

    await fixture.controller.completeNextAction();
    expect(fixture.controller.snapshot?.completedCount, 1);
    await fixture.controller.completeHabit(habit);

    expect(fixture.controller.snapshot?.completedCount, 2);
    expect(fixture.controller.snapshot?.progress, 1);
    expect(fixture.controller.snapshot?.totalXp, 15);

    await fixture.controller.undoLastCompletion();
    expect(fixture.controller.snapshot?.completedCount, 1);
    expect(fixture.controller.snapshot?.totalXp, 5);
  });
}
