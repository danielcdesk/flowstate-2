import 'package:clock/clock.dart';

import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';

enum XpAction {
  habitFull,
  habitMinimum,
  task,
  routineBlock,
  focusSession,
  workout,
  energyCheckin,
}

extension XpActionId on XpAction {
  String get id => switch (this) {
    XpAction.habitFull => 'habit_full',
    XpAction.habitMinimum => 'habit_minimum',
    XpAction.task => 'task_completed',
    XpAction.routineBlock => 'routine_block_completed',
    XpAction.focusSession => 'focus_session_completed',
    XpAction.workout => 'workout_completed',
    XpAction.energyCheckin => 'energy_checkin',
  };
}

/// All XP awards and daily caps live here as the single source of truth.
abstract final class XpPolicy {
  static const int habitFull = 10;
  static const int habitMinimum = 5;
  static const int task = 5;
  static const int maxTaskAwardsPerDay = 10;
  static const int routineBlock = 8;
  static const int focusSession = 25;
  static const int minFocusMinutes = 15;
  static const int maxFocusAwardsPerDay = 6;
  static const int workout = 35;
  static const int energyCheckin = 3;
}

final class XpEvent {
  XpEvent({
    required this.metadata,
    required this.action,
    required this.sourceId,
    required this.logicalDate,
    required this.units,
    required this.xp,
    this.reversedAt,
  }) {
    if (sourceId.trim().isEmpty) {
      throw ArgumentError.value(sourceId, 'sourceId');
    }
    if (units < 1) throw ArgumentError.value(units, 'units');
    if (xp < 1) throw ArgumentError.value(xp, 'xp');
    final DateTime? reversed = reversedAt;
    if (reversed != null && !reversed.isUtc) {
      throw ArgumentError('reversedAt must be UTC.');
    }
  }

  final RecordMetadata metadata;
  final XpAction action;
  final String sourceId;
  final LocalDate logicalDate;
  final int units;
  final int xp;
  final DateTime? reversedAt;

  bool get isActive => reversedAt == null && metadata.deletedAt == null;

  XpEvent reverse({required Clock clock}) {
    final DateTime? previous = reversedAt;
    if (previous != null) return this;
    final DateTime now = clock.now().toUtc();
    return XpEvent(
      metadata: RecordMetadata(
        id: metadata.id,
        createdAt: metadata.createdAt,
        updatedAt: now,
        deletedAt: metadata.deletedAt,
        deviceId: metadata.deviceId,
      ),
      action: action,
      sourceId: sourceId,
      logicalDate: logicalDate,
      units: units,
      xp: xp,
      reversedAt: now,
    );
  }
}

final class XpAwardResult {
  XpAwardResult({required Iterable<XpEvent> events, required this.awarded})
    : events = List<XpEvent>.unmodifiable(events);

  final List<XpEvent> events;
  final bool awarded;
}

XpAwardResult awardXp({
  required Iterable<XpEvent> ledger,
  required XpAction action,
  required String sourceId,
  required LocalDate logicalDate,
  required int units,
  required Clock clock,
  required String deviceId,
}) {
  if (sourceId.trim().isEmpty) throw ArgumentError.value(sourceId, 'sourceId');
  if (units < 1) throw ArgumentError.value(units, 'units');
  if (action != XpAction.focusSession && units != 1) {
    throw ArgumentError.value(units, 'units', 'This action accepts one unit.');
  }
  final List<XpEvent> events = List<XpEvent>.of(ledger);
  final bool alreadyAwarded = events.any(
    (XpEvent event) =>
        event.action == action &&
        event.sourceId == sourceId &&
        event.logicalDate == logicalDate,
  );
  if (alreadyAwarded) return XpAwardResult(events: events, awarded: false);

  final int activeAwardsToday = events
      .where(
        (XpEvent event) =>
            event.action == action &&
            event.logicalDate == logicalDate &&
            event.isActive,
      )
      .length;
  final int xp = _calculateXp(action, units, activeAwardsToday);
  if (xp == 0) return XpAwardResult(events: events, awarded: false);

  events.add(
    XpEvent(
      metadata: RecordMetadata.create(clock: clock, deviceId: deviceId),
      action: action,
      sourceId: sourceId,
      logicalDate: logicalDate,
      units: units,
      xp: xp,
    ),
  );
  return XpAwardResult(events: events, awarded: true);
}

int _calculateXp(XpAction action, int units, int awardsToday) {
  switch (action) {
    case XpAction.habitFull:
      return XpPolicy.habitFull;
    case XpAction.habitMinimum:
      return XpPolicy.habitMinimum;
    case XpAction.task:
      return awardsToday < XpPolicy.maxTaskAwardsPerDay ? XpPolicy.task : 0;
    case XpAction.routineBlock:
      return XpPolicy.routineBlock;
    case XpAction.focusSession:
      if (units < XpPolicy.minFocusMinutes ||
          awardsToday >= XpPolicy.maxFocusAwardsPerDay) {
        return 0;
      }
      return XpPolicy.focusSession;
    case XpAction.workout:
      return XpPolicy.workout;
    case XpAction.energyCheckin:
      return awardsToday == 0 ? XpPolicy.energyCheckin : 0;
  }
}

int totalActiveXp(Iterable<XpEvent> ledger) {
  return ledger
      .where((XpEvent event) => event.isActive)
      .fold<int>(0, (int total, XpEvent event) => total + event.xp);
}

int levelForXp(int xp) {
  if (xp < 0) throw ArgumentError.value(xp, 'xp');
  final BigInt xpValue = BigInt.from(xp);
  bool thresholdFits(int level) {
    final BigInt value = BigInt.from(level);
    return BigInt.from(50) * value * (value - BigInt.one) <= xpValue;
  }

  int low = 1;
  int high = 2;
  while (thresholdFits(high)) {
    low = high;
    high *= 2;
  }
  while (high - low > 1) {
    final int middle = low + ((high - low) ~/ 2);
    if (thresholdFits(middle)) {
      low = middle;
    } else {
      high = middle;
    }
  }
  return low;
}

BigInt xpRequiredForLevel(int level) {
  if (level < 1) throw ArgumentError.value(level, 'level');
  final BigInt value = BigInt.from(level);
  return BigInt.from(50) * value * (value - BigInt.one);
}
