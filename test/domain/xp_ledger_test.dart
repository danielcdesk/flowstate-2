import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';

import '../fixtures/domain_fixtures.dart';

void main() {
  final LocalDate day = LocalDate(2026, 9, 30);

  group('awardXp', () {
    test('is idempotent for the same action, source and logical date', () {
      final first = awardXp(
        ledger: const <XpEvent>[],
        action: XpAction.habitFull,
        sourceId: testUuid(1),
        logicalDate: day,
        units: 1,
        clock: fixedClock,
        deviceId: testDeviceId,
      );
      final second = awardXp(
        ledger: first.events,
        action: XpAction.habitFull,
        sourceId: testUuid(1),
        logicalDate: day,
        units: 1,
        clock: fixedClock,
        deviceId: testDeviceId,
      );

      expect(first.awarded, isTrue);
      expect(second.awarded, isFalse);
      expect(second.events, hasLength(1));
      expect(totalActiveXp(second.events), 10);
    });

    test('applies all configured awards and per-day caps', () {
      expect(_award(XpAction.habitMinimum).events.single.xp, 5);
      expect(_award(XpAction.routineBlock).events.single.xp, 8);
      expect(_award(XpAction.workout).events.single.xp, 35);

      List<XpEvent> taskLedger = <XpEvent>[];
      for (int index = 0; index < 11; index++) {
        taskLedger = awardXp(
          ledger: taskLedger,
          action: XpAction.task,
          sourceId: testUuid(index + 10),
          logicalDate: day,
          units: 1,
          clock: fixedClock,
          deviceId: testDeviceId,
        ).events;
      }
      expect(taskLedger, hasLength(10));
      expect(totalActiveXp(taskLedger), 50);
    });

    test('limits focus awards and energy check-ins per day', () {
      expect(_award(XpAction.focusSession, units: 14).awarded, isFalse);
      List<XpEvent> focusLedger = <XpEvent>[];
      for (int index = 0; index < 7; index++) {
        focusLedger = awardXp(
          ledger: focusLedger,
          action: XpAction.focusSession,
          sourceId: testUuid(index + 40),
          logicalDate: day,
          units: 25,
          clock: fixedClock,
          deviceId: testDeviceId,
        ).events;
      }
      expect(focusLedger, hasLength(6));
      expect(totalActiveXp(focusLedger), 150);

      final first = _award(XpAction.energyCheckin);
      final second = awardXp(
        ledger: first.events,
        action: XpAction.energyCheckin,
        sourceId: testUuid(99),
        logicalDate: day,
        units: 1,
        clock: fixedClock,
        deviceId: testDeviceId,
      );
      expect(first.events.single.xp, 3);
      expect(second.awarded, isFalse);
    });

    test('reversing an event removes its XP and is idempotent', () {
      final XpEvent event = _award(XpAction.task).events.single;
      final XpEvent reversed = event.reverse(clock: fixedClock);

      expect(totalActiveXp(<XpEvent>[reversed]), 0);
      expect(reversed.reverse(clock: fixedClock), same(reversed));
      expect(reversed.reversedAt?.isUtc, isTrue);
    });

    test('rejects invalid sources, units and units for non-focus actions', () {
      expect(() => _award(XpAction.task, sourceId: '  '), throwsArgumentError);
      expect(() => _award(XpAction.task, units: 2), throwsArgumentError);
      expect(
        () => _award(XpAction.focusSession, units: 0),
        throwsArgumentError,
      );
    });
  });

  group('levelForXp', () {
    test('matches exact level boundaries', () {
      expect(levelForXp(0), 1);
      expect(levelForXp(99), 1);
      expect(levelForXp(100), 2);
      expect(levelForXp(299), 2);
      expect(levelForXp(300), 3);
      expect(levelForXp(600), 4);
      expect(levelForXp(1 << 62), greaterThan(1));
      expect(xpRequiredForLevel(4), BigInt.from(600));
    });

    test('rejects negative XP and invalid levels', () {
      expect(() => levelForXp(-1), throwsArgumentError);
      expect(() => xpRequiredForLevel(0), throwsArgumentError);
    });
  });
}

XpAwardResult _award(XpAction action, {int units = 1, String? sourceId}) =>
    awardXp(
      ledger: const <XpEvent>[],
      action: action,
      sourceId: sourceId ?? testUuid(2),
      logicalDate: LocalDate(2026, 9, 30),
      units: units,
      clock: fixedClock,
      deviceId: testDeviceId,
    );
