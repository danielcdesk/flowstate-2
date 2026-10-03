import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flowstate/core/ids.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/core/logical_date.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/domain/repositories/habit_repository.dart';
import 'package:flowstate/domain/repositories/xp_repository.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';

final class HabitsController extends ChangeNotifier {
  HabitsController({
    required this.habitRepository,
    required this.xpRepository,
    required this.clock,
    required this.deviceId,
    this.onDataChanged,
  });

  final HabitRepository habitRepository;
  final XpRepository xpRepository;
  final Clock clock;
  final String deviceId;
  final Future<void> Function()? onDataChanged;

  List<Habit> habits = const <Habit>[];
  List<HabitLog> logs = const <HabitLog>[];
  LocalDate? date;
  Object? error;
  bool isLoading = false;
  String? busyHabitId;
  _UndoHabitLog? _undo;

  LocalDate get currentDate =>
      date ?? (throw StateError('Habits have not loaded.'));

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final LocalDate today = logicalDate(
        clock.now().toLocal(),
        dayStartMinute: 240,
      );
      final List<Object> result = await Future.wait<Object>(<Future<Object>>[
        habitRepository.getActiveHabits(),
        habitRepository.getHabitLogs(from: LocalDate(1, 1, 1), through: today),
      ]);
      habits = result[0] as List<Habit>;
      logs = result[1] as List<HabitLog>;
      date = today;
    } on Object catch (caught) {
      error = caught;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isCompletedToday(Habit habit) {
    final LocalDate? today = date;
    if (today == null) return false;
    return logs.any(
      (HabitLog log) =>
          log.habitId == habit.id &&
          log.logicalDate == today &&
          log.metadata.deletedAt == null,
    );
  }

  bool isScheduledToday(Habit habit) {
    if (habit.recurrence.isWeeklyTarget) return true;
    return habit.recurrence.isScheduledOn(currentDate);
  }

  HabitLogLevel? levelToday(Habit habit) {
    final LocalDate? today = date;
    if (today == null) return null;
    for (final HabitLog log in logs) {
      if (log.habitId == habit.id &&
          log.logicalDate == today &&
          log.metadata.deletedAt == null) {
        return log.level;
      }
    }
    return null;
  }

  int streakFor(Habit habit) => habitStreak(
    habit: habit,
    logs: logs,
    through: date ?? (throw StateError('Habits have not loaded.')),
  );

  int completedInCurrentWeek(Habit habit) {
    final LocalDate today =
        date ?? (throw StateError('Habits have not loaded.'));
    return logs
        .where(
          (HabitLog log) =>
              log.habitId == habit.id &&
              log.metadata.deletedAt == null &&
              (log.level == HabitLogLevel.full ||
                  log.level == HabitLogLevel.minimum) &&
              log.logicalDate.compareTo(today.startOfIsoWeek) >= 0 &&
              log.logicalDate.compareTo(today.startOfIsoWeek.addDays(7)) < 0,
        )
        .map((HabitLog log) => log.logicalDate)
        .toSet()
        .length;
  }

  Future<void> saveHabit({
    Habit? existing,
    required String name,
    required String iconId,
    required String categoryId,
    required Recurrence recurrence,
    String? cue,
    String? minimumVersion,
    required bool isEssential,
    int? reminderMinute,
  }) async {
    final DateTime now = clock.now().toUtc();
    final Habit habit = Habit(
      metadata: existing == null
          ? RecordMetadata.create(clock: clock, deviceId: deviceId)
          : RecordMetadata(
              id: existing.id,
              createdAt: existing.metadata.createdAt,
              updatedAt: now,
              deletedAt: null,
              deviceId: existing.metadata.deviceId,
            ),
      name: name.trim(),
      iconId: iconId,
      categoryId: categoryId,
      recurrence: recurrence,
      cue: _cleanOptional(cue),
      minimumVersion: _cleanOptional(minimumVersion),
      isEssential: isEssential,
      reminderMinute: reminderMinute,
    );
    await habitRepository.saveHabit(habit);
    await load();
    await onDataChanged?.call();
  }

  Future<void> archive(Habit habit) async {
    final DateTime now = clock.now().toUtc();
    await habitRepository.saveHabit(
      Habit(
        metadata: RecordMetadata(
          id: habit.id,
          createdAt: habit.metadata.createdAt,
          updatedAt: now,
          deletedAt: now,
          deviceId: habit.metadata.deviceId,
        ),
        name: habit.name,
        iconId: habit.iconId,
        categoryId: habit.categoryId,
        recurrence: habit.recurrence,
        cue: habit.cue,
        minimumVersion: habit.minimumVersion,
        isEssential: habit.isEssential,
        reminderMinute: habit.reminderMinute,
      ),
    );
    await load();
    await onDataChanged?.call();
  }

  Future<void> logToday(Habit habit, HabitLogLevel level) async {
    final LocalDate? today = date;
    if (today == null || busyHabitId != null) return;
    busyHabitId = habit.id;
    notifyListeners();
    try {
      await habitRepository.saveHabitLog(
        HabitLog(
          metadata: RecordMetadata.create(clock: clock, deviceId: deviceId),
          habitId: habit.id,
          logicalDate: today,
          level: level,
        ),
      );
      if (level != HabitLogLevel.skipped) {
        final XpAction action = level == HabitLogLevel.minimum
            ? XpAction.habitMinimum
            : XpAction.habitFull;
        final List<XpEvent> ledger = await xpRepository.getLedger(
          through: today,
        );
        final XpAwardResult award = awardXp(
          ledger: ledger,
          action: action,
          sourceId: habit.id,
          logicalDate: today,
          units: 1,
          clock: clock,
          deviceId: deviceId,
        );
        if (award.awarded) {
          await xpRepository.insertIfAbsent(award.events.last);
        }
      }
      _undo = _UndoHabitLog(
        habitId: habit.id,
        date: today,
        level: level,
        createdAt: clock.now().toUtc(),
      );
      await load();
      await onDataChanged?.call();
    } finally {
      busyHabitId = null;
      notifyListeners();
    }
  }

  Future<void> undoLastLog() async {
    final _UndoHabitLog? undo = _undo;
    if (undo == null ||
        clock.now().toUtc().difference(undo.createdAt) >
            const Duration(seconds: 5)) {
      return;
    }
    final DateTime now = clock.now().toUtc();
    await habitRepository.saveHabitLog(
      HabitLog(
        metadata: RecordMetadata(
          id: newId(),
          createdAt: now,
          updatedAt: now,
          deletedAt: now,
          deviceId: deviceId,
        ),
        habitId: undo.habitId,
        logicalDate: undo.date,
        level: HabitLogLevel.skipped,
      ),
    );
    if (undo.level != HabitLogLevel.skipped) {
      final XpAction action = undo.level == HabitLogLevel.minimum
          ? XpAction.habitMinimum
          : XpAction.habitFull;
      final List<XpEvent> ledger = await xpRepository.getLedger(
        through: undo.date,
      );
      for (final XpEvent event in ledger) {
        if (event.action == action &&
            event.sourceId == undo.habitId &&
            event.logicalDate == undo.date &&
            event.reversedAt == null) {
          await xpRepository.reverse(event.reverse(clock: clock));
        }
      }
    }
    _undo = null;
    await load();
    await onDataChanged?.call();
  }
}

String? _cleanOptional(String? value) {
  final String cleaned = value?.trim() ?? '';
  return cleaned.isEmpty ? null : cleaned;
}

final class _UndoHabitLog {
  const _UndoHabitLog({
    required this.habitId,
    required this.date,
    required this.level,
    required this.createdAt,
  });

  final String habitId;
  final LocalDate date;
  final HabitLogLevel level;
  final DateTime createdAt;
}
