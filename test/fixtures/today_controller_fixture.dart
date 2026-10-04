import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flowstate/data/database/app_database.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/features/today/application/today_controller.dart';
import 'package:flowstate/features/habits/application/habits_controller.dart';
import 'package:flowstate/features/plan/application/plan_controller.dart';
import 'package:flowstate/features/focus/application/focus_controller.dart';

final class TodayControllerFixture {
  const TodayControllerFixture({
    required this.database,
    required this.controller,
    required this.habitsController,
    required this.planController,
    required this.focusController,
  });

  final AppDatabase database;
  final TodayController controller;
  final HabitsController habitsController;
  final PlanController planController;
  final FocusController focusController;

  Future<void> dispose() async {
    controller.dispose();
    habitsController.dispose();
    planController.dispose();
    focusController.dispose();
    await database.close();
  }
}

TodayControllerFixture createTodayControllerFixture() {
  final AppDatabase database = AppDatabase(NativeDatabase.memory());
  final Clock clock = Clock(() => DateTime(2026, 9, 30, 10));
  final DriftTaskRepository taskRepository = DriftTaskRepository(database);
  final DriftRoutineRepository routineRepository = DriftRoutineRepository(
    database,
  );
  final DriftXpRepository xpRepository = DriftXpRepository(database);
  final HabitsController habitsController = HabitsController(
    habitRepository: DriftHabitRepository(database),
    xpRepository: xpRepository,
    clock: clock,
    deviceId: 'test-device',
  );
  final TodayController todayController = TodayController(
    habitRepository: DriftHabitRepository(database),
    taskRepository: taskRepository,
    routineRepository: routineRepository,
    xpRepository: xpRepository,
    clock: clock,
    deviceId: 'test-device',
  );
  final FocusController focusController = FocusController(
    focusRepository: DriftFocusRepository(database),
    taskRepository: taskRepository,
    xpRepository: xpRepository,
    clock: clock,
    deviceId: 'test-device',
    onDataChanged: todayController.load,
  );
  return TodayControllerFixture(
    database: database,
    habitsController: habitsController,
    planController: PlanController(
      taskRepository: taskRepository,
      routineRepository: routineRepository,
      xpRepository: xpRepository,
      clock: clock,
      deviceId: 'test-device',
      onDataChanged: todayController.load,
    ),
    focusController: focusController,
    controller: todayController,
  );
}
