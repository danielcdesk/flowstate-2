import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import 'package:flowstate/core/logical_date.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/repositories/xp_repository.dart';
import 'package:flowstate/domain/repositories/workout_repository.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';
import 'package:flowstate/domain/workouts/workout.dart';

const List<WorkoutExercise> defaultWorkoutExercises = <WorkoutExercise>[
  WorkoutExercise(
    id: 'squat',
    name: 'Agachamento',
    muscle: 'Pernas',
    equipment: 'Peso corporal',
  ),
  WorkoutExercise(
    id: 'push_up',
    name: 'Flexão',
    muscle: 'Peito',
    equipment: 'Peso corporal',
  ),
  WorkoutExercise(
    id: 'row',
    name: 'Remada',
    muscle: 'Costas',
    equipment: 'Elástico',
  ),
];

final class WorkoutsController extends ChangeNotifier {
  WorkoutsController({
    required this.repository,
    required this.xpRepository,
    required this.clock,
    required this.deviceId,
    this.onDataChanged,
  });

  final WorkoutRepository repository;
  final XpRepository xpRepository;
  final Clock clock;
  final String deviceId;
  final Future<void> Function()? onDataChanged;

  List<WorkoutPlan> plans = const <WorkoutPlan>[];
  WorkoutSession? activeSession;
  List<WorkoutSet> activeSets = const <WorkoutSet>[];
  DateTime? restEndAtValue;
  bool isLoading = false;
  bool isSaving = false;
  Object? error;
  Timer? _watcher;

  Duration get restRemaining {
    final DateTime? endAt = restEndAtValue;
    if (endAt == null) return Duration.zero;
    final Duration remaining = endAt.difference(clock.now().toUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      plans = await repository.getPlans();
      final List<WorkoutSession> sessions = await repository.getSessions();
      final Iterable<WorkoutSession> activeSessions = sessions.where(
        (WorkoutSession session) =>
            session.endedAt == null && session.metadata.deletedAt == null,
      );
      activeSession = activeSessions.isEmpty ? null : activeSessions.first;
      final WorkoutSession? active = activeSession;
      activeSets = active == null
          ? const <WorkoutSet>[]
          : await repository.getSets(sessionId: active.id);
      _syncWatcher();
    } on Object catch (caught) {
      error = caught;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createStarterPlan({required String title}) async {
    if (isSaving) return;
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final WorkoutPlan plan = WorkoutPlan(
        metadata: RecordMetadata.create(clock: clock, deviceId: deviceId),
        title: title,
        exerciseIds: defaultWorkoutExercises.map(
          (WorkoutExercise item) => item.id,
        ),
      );
      await repository.savePlan(plan);
      plans = await repository.getPlans();
    } on Object catch (caught) {
      error = caught;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> startSession(WorkoutPlan plan) async {
    if (isSaving || activeSession != null) return;
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final WorkoutSession session = WorkoutSession(
        metadata: RecordMetadata.create(clock: clock, deviceId: deviceId),
        planId: plan.id,
        startedAt: clock.now().toUtc(),
      );
      await repository.saveSession(session);
      activeSession = session;
      activeSets = const <WorkoutSet>[];
      _syncWatcher();
    } on Object catch (caught) {
      error = caught;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> recordSet({
    required String exerciseId,
    required int repetitions,
    required double loadKg,
    required int restSeconds,
  }) async {
    final WorkoutSession? session = activeSession;
    if (session == null || isSaving) return;
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final WorkoutSet set = WorkoutSet(
        metadata: RecordMetadata.create(clock: clock, deviceId: deviceId),
        sessionId: session.id,
        exerciseId: exerciseId,
        setIndex: activeSets
            .where((WorkoutSet item) => item.exerciseId == exerciseId)
            .length,
        repetitions: repetitions,
        loadKg: loadKg,
        restSeconds: restSeconds,
      );
      await repository.saveSet(set);
      activeSets = await repository.getSets(sessionId: session.id);
      restEndAtValue = restEndAt(
        startedAt: clock.now().toUtc(),
        restSeconds: restSeconds,
      );
      _syncWatcher();
    } on Object catch (caught) {
      error = caught;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> finishSession() async {
    final WorkoutSession? session = activeSession;
    if (session == null || isSaving) return;
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final DateTime now = clock.now().toUtc();
      await repository.saveSession(
        WorkoutSession(
          metadata: RecordMetadata(
            id: session.metadata.id,
            createdAt: session.metadata.createdAt,
            updatedAt: now,
            deletedAt: session.metadata.deletedAt,
            deviceId: session.metadata.deviceId,
          ),
          planId: session.planId,
          startedAt: session.startedAt,
          endedAt: now,
        ),
      );
      final List<XpEvent> ledger = await xpRepository.getLedger();
      final XpAwardResult award = awardXp(
        ledger: ledger,
        action: XpAction.workout,
        sourceId: session.id,
        logicalDate: logicalDate(now.toLocal(), dayStartMinute: 240),
        units: 1,
        clock: clock,
        deviceId: deviceId,
      );
      if (award.awarded) await xpRepository.insertIfAbsent(award.events.last);
      activeSession = null;
      activeSets = const <WorkoutSet>[];
      restEndAtValue = null;
      _syncWatcher();
      await onDataChanged?.call();
    } on Object catch (caught) {
      error = caught;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void _syncWatcher() {
    if (activeSession == null && restEndAtValue == null) {
      _watcher?.cancel();
      _watcher = null;
      return;
    }
    _watcher ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _watcher?.cancel();
    super.dispose();
  }
}
