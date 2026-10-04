import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/core/logical_date.dart';
import 'package:flowstate/domain/focus/focus_session.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/repositories/focus_repository.dart';
import 'package:flowstate/domain/repositories/task_repository.dart';
import 'package:flowstate/domain/repositories/xp_repository.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';
import 'package:flowstate/domain/tasks/task.dart';

/// Coordinates persisted focus intervals and their idempotent XP awards.
final class FocusController extends ChangeNotifier {
  FocusController({
    required this.focusRepository,
    required this.taskRepository,
    required this.xpRepository,
    required this.clock,
    required this.deviceId,
    this.onDataChanged,
  });

  final FocusRepository focusRepository;
  final TaskRepository taskRepository;
  final XpRepository xpRepository;
  final Clock clock;
  final String deviceId;
  final Future<void> Function()? onDataChanged;

  List<Task> tasks = <Task>[];
  FocusSession? activeSession;
  FocusSession? completedSession;
  int completedSessionXp = 0;
  Object? error;
  bool isLoading = false;
  bool isSaving = false;
  bool failedToLoad = false;
  bool _isFinalizing = false;
  Timer? _deadlineWatcher;

  Duration get remaining {
    final FocusSession? session = activeSession;
    return session == null
        ? Duration.zero
        : remainingFocusDuration(session, clock: clock);
  }

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    failedToLoad = false;
    notifyListeners();
    try {
      final List<Object> records = await Future.wait<Object>(<Future<Object>>[
        focusRepository.getSessions(),
        taskRepository.getActiveTasks(),
        xpRepository.getLedger(),
      ]);
      final List<FocusSession> sessions = records[0] as List<FocusSession>;
      tasks = List<Task>.unmodifiable(records[1] as List<Task>);
      List<XpEvent> ledger = records[2] as List<XpEvent>;
      final DateTime now = clock.now().toUtc();
      final List<FocusSession> expired =
          sessions
              .where(
                (FocusSession session) =>
                    session.metadata.deletedAt == null &&
                    !now.isBefore(session.endAt),
              )
              .toList()
            ..sort(
              (FocusSession a, FocusSession b) =>
                  a.startedAt.compareTo(b.startedAt),
            );
      bool awardedAny = false;
      for (final FocusSession session in expired) {
        final LocalDate date = _logicalDateFor(session.startedAt);
        final XpAwardResult result = awardXp(
          ledger: ledger,
          action: XpAction.focusSession,
          sourceId: session.metadata.id,
          logicalDate: date,
          units: session.durationMinutes,
          clock: clock,
          deviceId: deviceId,
        );
        ledger = result.events;
        if (result.awarded) {
          final bool inserted = await xpRepository.insertIfAbsent(
            result.events.last,
          );
          awardedAny = awardedAny || inserted;
        }
      }
      final List<FocusSession> active =
          sessions
              .where(
                (FocusSession session) =>
                    session.metadata.deletedAt == null &&
                    !session.startedAt.isAfter(now) &&
                    now.isBefore(session.endAt),
              )
              .toList()
            ..sort(
              (FocusSession a, FocusSession b) =>
                  b.startedAt.compareTo(a.startedAt),
            );
      activeSession = active.isEmpty ? null : active.first;
      _syncDeadlineWatcher();
      final LocalDate today = logicalDate(
        clock.now().toLocal(),
        dayStartMinute: 240,
      );
      final List<FocusSession> completedToday =
          sessions
              .where(
                (FocusSession session) =>
                    session.metadata.deletedAt == null &&
                    !now.isBefore(session.endAt) &&
                    _logicalDateFor(session.startedAt) == today,
              )
              .toList()
            ..sort(
              (FocusSession a, FocusSession b) =>
                  b.startedAt.compareTo(a.startedAt),
            );
      completedSession = completedToday.isEmpty ? null : completedToday.first;
      final FocusSession? completed = completedSession;
      completedSessionXp = completed == null
          ? 0
          : _xpForSession(ledger, completed.metadata.id);
      if (awardedAny) await onDataChanged?.call();
    } on Object catch (caught) {
      error = caught;
      failedToLoad = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshRemaining() async {
    final FocusSession? session = activeSession;
    if (session == null || _isFinalizing) return;
    if (!isFocusSessionComplete(session, clock: clock)) {
      notifyListeners();
      return;
    }
    _isFinalizing = true;
    error = null;
    failedToLoad = false;
    try {
      final LocalDate date = _logicalDateFor(session.startedAt);
      final List<XpEvent> ledger = await xpRepository.getLedger();
      final XpAwardResult result = awardXp(
        ledger: ledger,
        action: XpAction.focusSession,
        sourceId: session.metadata.id,
        logicalDate: date,
        units: session.durationMinutes,
        clock: clock,
        deviceId: deviceId,
      );
      bool awarded = false;
      if (result.awarded) {
        awarded = await xpRepository.insertIfAbsent(result.events.last);
      }
      activeSession = null;
      completedSession = session;
      completedSessionXp = _xpForSession(result.events, session.metadata.id);
      _syncDeadlineWatcher();
      if (awarded) await onDataChanged?.call();
    } on Object catch (caught) {
      error = caught;
      failedToLoad = false;
    } finally {
      _isFinalizing = false;
      notifyListeners();
    }
  }

  Future<void> startSession({
    required int durationMinutes,
    String? taskId,
  }) async {
    if (isSaving || activeSession != null) return;
    isSaving = true;
    error = null;
    failedToLoad = false;
    notifyListeners();
    try {
      if (taskId != null && !tasks.any((Task task) => task.id == taskId)) {
        throw ArgumentError.value(taskId, 'taskId', 'Task is not available.');
      }
      final FocusSession session = startFocusSession(
        clock: clock,
        deviceId: deviceId,
        durationMinutes: durationMinutes,
        taskId: taskId,
      );
      await focusRepository.saveSession(session);
      activeSession = session;
      completedSession = null;
      completedSessionXp = 0;
      _syncDeadlineWatcher();
    } on Object catch (caught) {
      error = caught;
      failedToLoad = false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> stopSession() async {
    final FocusSession? session = activeSession;
    if (session == null || isSaving) return;
    if (isFocusSessionComplete(session, clock: clock)) {
      await refreshRemaining();
      return;
    }
    isSaving = true;
    error = null;
    failedToLoad = false;
    notifyListeners();
    try {
      final DateTime now = clock.now().toUtc();
      await focusRepository.saveSession(
        FocusSession(
          metadata: RecordMetadata(
            id: session.metadata.id,
            createdAt: session.metadata.createdAt,
            updatedAt: now,
            deletedAt: now,
            deviceId: session.metadata.deviceId,
          ),
          startedAt: session.startedAt,
          endAt: session.endAt,
          taskId: session.taskId,
        ),
      );
      activeSession = null;
      completedSession = null;
      completedSessionXp = 0;
      _syncDeadlineWatcher();
    } on Object catch (caught) {
      error = caught;
      failedToLoad = false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  LocalDate _logicalDateFor(DateTime utcMoment) =>
      logicalDate(utcMoment.toLocal(), dayStartMinute: 240);

  int _xpForSession(Iterable<XpEvent> ledger, String sessionId) {
    for (final XpEvent event in ledger) {
      if (event.action == XpAction.focusSession &&
          event.sourceId == sessionId &&
          event.isActive) {
        return event.xp;
      }
    }
    return 0;
  }

  void _syncDeadlineWatcher() {
    if (activeSession == null) {
      _deadlineWatcher?.cancel();
      _deadlineWatcher = null;
      return;
    }
    // This only wakes the controller; remaining time always comes from endAt.
    _deadlineWatcher ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => unawaited(refreshRemaining()),
    );
  }

  @override
  void dispose() {
    _deadlineWatcher?.cancel();
    super.dispose();
  }
}
