import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flowstate/data/database/app_database.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/features/today/application/today_controller.dart';
import 'package:flowstate/features/habits/application/habits_controller.dart';

final class TodayControllerFixture {
  const TodayControllerFixture({
    required this.database,
    required this.controller,
    required this.habitsController,
  });

  final AppDatabase database;
  final TodayController controller;
  final HabitsController habitsController;

  Future<void> dispose() async {
    controller.dispose();
    habitsController.dispose();
    await database.close();
  }
}

TodayControllerFixture createTodayControllerFixture() {
  final AppDatabase database = AppDatabase(NativeDatabase.memory());
  final HabitsController habitsController = HabitsController(
    habitRepository: DriftHabitRepository(database),
    xpRepository: DriftXpRepository(database),
    clock: Clock(() => DateTime(2026, 9, 30, 10)),
    deviceId: 'test-device',
  );
  return TodayControllerFixture(
    database: database,
    habitsController: habitsController,
    controller: TodayController(
      habitRepository: DriftHabitRepository(database),
      taskRepository: DriftTaskRepository(database),
      routineRepository: DriftRoutineRepository(database),
      xpRepository: DriftXpRepository(database),
      clock: Clock(() => DateTime(2026, 9, 30, 10)),
      deviceId: 'test-device',
    ),
  );
}
