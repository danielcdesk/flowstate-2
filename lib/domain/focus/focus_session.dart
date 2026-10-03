import 'package:clock/clock.dart';

import 'package:flowstate/domain/shared/record_metadata.dart';

/// A focus interval persisted by absolute UTC timestamps, never by timer ticks.
final class FocusSession {
  FocusSession({
    required this.metadata,
    required this.startedAt,
    required this.endAt,
    this.taskId,
  }) {
    if (!startedAt.isUtc || !endAt.isUtc) {
      throw ArgumentError('Focus session moments must be UTC.');
    }
    final Duration duration = endAt.difference(startedAt);
    if (duration.inSeconds < 60 ||
        duration.inSeconds % 60 != 0 ||
        duration.inMinutes > maxFocusDurationMinutes) {
      throw ArgumentError('Focus session duration is outside valid ranges.');
    }
    final String? linkedTaskId = taskId;
    if (linkedTaskId != null && linkedTaskId.trim().isEmpty) {
      throw ArgumentError.value(linkedTaskId, 'taskId');
    }
  }

  static const int maxFocusDurationMinutes = 480;

  final RecordMetadata metadata;
  final DateTime startedAt;
  final DateTime endAt;
  final String? taskId;

  int get durationMinutes => endAt.difference(startedAt).inMinutes;
}

FocusSession startFocusSession({
  required Clock clock,
  required String deviceId,
  required int durationMinutes,
  String? taskId,
}) {
  if (durationMinutes < 1 ||
      durationMinutes > FocusSession.maxFocusDurationMinutes) {
    throw ArgumentError.value(durationMinutes, 'durationMinutes');
  }
  final DateTime startedAt = clock.now().toUtc();
  return FocusSession(
    metadata: RecordMetadata.create(clock: clock, deviceId: deviceId),
    startedAt: startedAt,
    endAt: startedAt.add(Duration(minutes: durationMinutes)),
    taskId: taskId,
  );
}

bool isFocusSessionComplete(FocusSession session, {required Clock clock}) =>
    !clock.now().toUtc().isBefore(session.endAt);

Duration remainingFocusDuration(FocusSession session, {required Clock clock}) {
  final Duration remaining = session.endAt.difference(clock.now().toUtc());
  return remaining.isNegative ? Duration.zero : remaining;
}
