import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/features/focus/application/focus_controller.dart';

import '../../fixtures/domain_fixtures.dart';
import '../../fixtures/today_controller_fixture.dart';

void main() {
  testWidgets('finishes from the saved deadline without an open focus sheet', (
    WidgetTester tester,
  ) async {
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    DateTime now = DateTime(2026, 9, 30, 10);
    final FocusController controller = FocusController(
      focusRepository: DriftFocusRepository(fixture.database),
      taskRepository: DriftTaskRepository(fixture.database),
      xpRepository: DriftXpRepository(fixture.database),
      clock: Clock(() => now),
      deviceId: testDeviceId,
    );
    addTearDown(controller.dispose);
    await controller.load();
    await controller.startSession(durationMinutes: 1);

    now = now.add(const Duration(minutes: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(controller.activeSession, isNull);
    expect(controller.completedSession?.durationMinutes, 1);
  });

  test(
    'restores an active session from its persisted absolute deadline',
    () async {
      final fixture = createTodayControllerFixture();
      addTearDown(fixture.dispose);
      final DriftTaskRepository tasks = DriftTaskRepository(fixture.database);
      await tasks.saveTask(testTask(id: 940, title: 'Ler capítulo'));
      await fixture.focusController.load();
      await fixture.focusController.startSession(
        durationMinutes: 25,
        taskId: testUuid(940),
      );

      final FocusController resumed = FocusController(
        focusRepository: DriftFocusRepository(fixture.database),
        taskRepository: tasks,
        xpRepository: DriftXpRepository(fixture.database),
        clock: Clock.fixed(DateTime(2026, 9, 30, 10, 20)),
        deviceId: testDeviceId,
      );
      addTearDown(resumed.dispose);
      await resumed.load();

      expect(resumed.activeSession?.taskId, testUuid(940));
      expect(resumed.remaining, const Duration(minutes: 5));
    },
  );

  test('awards focus XP once when a session expires', () async {
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await fixture.focusController.load();
    await fixture.focusController.startSession(durationMinutes: 25);

    final FocusController resumed = FocusController(
      focusRepository: DriftFocusRepository(fixture.database),
      taskRepository: DriftTaskRepository(fixture.database),
      xpRepository: DriftXpRepository(fixture.database),
      clock: Clock.fixed(DateTime(2026, 9, 30, 10, 25)),
      deviceId: testDeviceId,
    );
    addTearDown(resumed.dispose);
    await resumed.load();
    await resumed.load();

    final List<XpEvent> ledger = await DriftXpRepository(fixture.database)
        .getLedger();
    expect(ledger, hasLength(1));
    expect(ledger.single.action, XpAction.focusSession);
    expect(ledger.single.xp, XpPolicy.focusSession);
    expect(ledger.single.logicalDate, LocalDate(2026, 9, 30));
    expect(resumed.completedSession?.durationMinutes, 25);
    expect(resumed.completedSessionXp, XpPolicy.focusSession);
  });

  test('completes short sessions without awarding XP', () async {
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await fixture.focusController.load();
    await fixture.focusController.startSession(durationMinutes: 10);

    final FocusController resumed = FocusController(
      focusRepository: DriftFocusRepository(fixture.database),
      taskRepository: DriftTaskRepository(fixture.database),
      xpRepository: DriftXpRepository(fixture.database),
      clock: Clock.fixed(DateTime(2026, 9, 30, 10, 10)),
      deviceId: testDeviceId,
    );
    addTearDown(resumed.dispose);
    await resumed.load();

    expect(resumed.completedSession?.durationMinutes, 10);
    expect(resumed.completedSessionXp, 0);
    expect(await DriftXpRepository(fixture.database).getLedger(), isEmpty);
  });

  test('stopping early soft-deletes the session without XP', () async {
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await fixture.focusController.load();
    await fixture.focusController.startSession(durationMinutes: 25);
    await fixture.focusController.stopSession();

    expect(fixture.focusController.activeSession, isNull);
    expect(await DriftFocusRepository(fixture.database).getSessions(), isEmpty);
    expect(await DriftXpRepository(fixture.database).getLedger(), isEmpty);
  });
}
