import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/domain/focus/focus_session.dart';

import '../fixtures/domain_fixtures.dart';

void main() {
  test(
    'persists an absolute UTC end time and derives completion from the clock',
    () {
      final FocusSession session = startFocusSession(
        clock: fixedClock,
        deviceId: testDeviceId,
        durationMinutes: 25,
        taskId: testUuid(90),
      );

      expect(session.startedAt.isUtc, isTrue);
      expect(session.endAt, session.startedAt.add(const Duration(minutes: 25)));
      expect(session.durationMinutes, 25);
      expect(session.taskId, testUuid(90));
      expect(isFocusSessionComplete(session, clock: fixedClock), isFalse);
      expect(
        remainingFocusDuration(session, clock: fixedClock),
        const Duration(minutes: 25),
      );

      final Clock afterDeadline = Clock.fixed(session.endAt);
      expect(isFocusSessionComplete(session, clock: afterDeadline), isTrue);
      expect(
        remainingFocusDuration(session, clock: afterDeadline),
        Duration.zero,
      );
    },
  );

  test('accepts presets and a custom duration within the supported range', () {
    for (final int minutes in <int>[25, 50, 37, 480]) {
      expect(
        startFocusSession(
          clock: fixedClock,
          deviceId: testDeviceId,
          durationMinutes: minutes,
        ).durationMinutes,
        minutes,
      );
    }
  });

  test('rejects non-UTC, sub-minute, overlong and invalid-task sessions', () {
    final DateTime start = DateTime.utc(2026, 9, 30, 9);
    expect(
      () => FocusSession(
        metadata: testMetadata(91),
        startedAt: DateTime(2026, 9, 30, 9),
        endAt: DateTime(2026, 9, 30, 9, 25),
      ),
      throwsArgumentError,
    );
    expect(
      () => FocusSession(
        metadata: testMetadata(92),
        startedAt: start,
        endAt: start.add(const Duration(seconds: 30)),
      ),
      throwsArgumentError,
    );
    expect(
      () => startFocusSession(
        clock: fixedClock,
        deviceId: testDeviceId,
        durationMinutes: 481,
      ),
      throwsArgumentError,
    );
    expect(
      () => FocusSession(
        metadata: testMetadata(93),
        startedAt: start,
        endAt: start.add(const Duration(minutes: 25)),
        taskId: ' ',
      ),
      throwsArgumentError,
    );
  });
}
