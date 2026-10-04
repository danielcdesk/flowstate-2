import 'package:clock/clock.dart';

import 'package:flowstate/domain/shared/record_metadata.dart';

final class WorkoutExercise {
  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.muscle,
    required this.equipment,
  });

  final String id;
  final String name;
  final String muscle;
  final String equipment;
}

final class WorkoutPlan {
  WorkoutPlan({
    required this.metadata,
    required this.title,
    required Iterable<String> exerciseIds,
  }) : exerciseIds = List<String>.unmodifiable(exerciseIds) {
    if (title.trim().isEmpty) throw ArgumentError.value(title, 'title');
    if (this.exerciseIds.isEmpty) {
      throw ArgumentError.value(exerciseIds, 'exerciseIds');
    }
  }

  final RecordMetadata metadata;
  final String title;
  final List<String> exerciseIds;

  String get id => metadata.id;
}

final class WorkoutSession {
  WorkoutSession({
    required this.metadata,
    required this.planId,
    required this.startedAt,
    this.endedAt,
  }) {
    final DateTime? ending = endedAt;
    if (!startedAt.isUtc || (ending != null && !ending.isUtc)) {
      throw ArgumentError('Workout session moments must be UTC.');
    }
    if (ending != null && ending.isBefore(startedAt)) {
      throw ArgumentError('Workout session cannot end before it starts.');
    }
  }

  final RecordMetadata metadata;
  final String planId;
  final DateTime startedAt;
  final DateTime? endedAt;

  String get id => metadata.id;
}

final class WorkoutSet {
  WorkoutSet({
    required this.metadata,
    required this.sessionId,
    required this.exerciseId,
    required this.setIndex,
    required this.repetitions,
    required this.loadKg,
    required this.restSeconds,
  }) {
    if (setIndex < 0) throw ArgumentError.value(setIndex, 'setIndex');
    if (repetitions < 1) throw ArgumentError.value(repetitions, 'repetitions');
    if (loadKg < 0) throw ArgumentError.value(loadKg, 'loadKg');
    if (restSeconds < 0) throw ArgumentError.value(restSeconds, 'restSeconds');
  }

  final RecordMetadata metadata;
  final String sessionId;
  final String exerciseId;
  final int setIndex;
  final int repetitions;
  final double loadKg;
  final int restSeconds;
}

double estimatedOneRepMax({required int repetitions, required double loadKg}) {
  if (repetitions < 1) throw ArgumentError.value(repetitions, 'repetitions');
  if (loadKg < 0) throw ArgumentError.value(loadKg, 'loadKg');
  return loadKg * (1 + repetitions / 30);
}

double suggestedNextLoad({
  required double currentLoadKg,
  required int completedRepetitions,
  required int targetRepetitions,
  double incrementKg = 2.5,
}) {
  if (currentLoadKg < 0) {
    throw ArgumentError.value(currentLoadKg, 'currentLoadKg');
  }
  if (completedRepetitions < 0 || targetRepetitions < 1) {
    throw ArgumentError('Repetition targets are outside valid ranges.');
  }
  if (incrementKg <= 0) throw ArgumentError.value(incrementKg, 'incrementKg');
  return completedRepetitions >= targetRepetitions
      ? currentLoadKg + incrementKg
      : currentLoadKg;
}

DateTime restEndAt({required DateTime startedAt, required int restSeconds}) {
  if (!startedAt.isUtc) throw ArgumentError('startedAt must be UTC.');
  if (restSeconds < 0) throw ArgumentError.value(restSeconds, 'restSeconds');
  return startedAt.add(Duration(seconds: restSeconds));
}

bool isRestComplete({required DateTime endAt, required Clock clock}) {
  if (!endAt.isUtc) throw ArgumentError('endAt must be UTC.');
  return !clock.now().toUtc().isBefore(endAt);
}
