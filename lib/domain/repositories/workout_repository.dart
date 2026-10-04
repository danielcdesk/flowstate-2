import 'package:flowstate/domain/workouts/workout.dart';

abstract interface class WorkoutRepository {
  Future<List<WorkoutPlan>> getPlans();

  Future<void> savePlan(WorkoutPlan plan);

  Future<List<WorkoutSession>> getSessions();

  Future<void> saveSession(WorkoutSession session);

  Future<List<WorkoutSet>> getSets({required String sessionId});

  Future<void> saveSet(WorkoutSet set);
}
