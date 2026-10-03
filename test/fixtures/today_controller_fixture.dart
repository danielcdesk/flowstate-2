import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flowstate/data/database/app_database.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/features/today/application/today_controller.dart';

final class TodayControllerFixture {
  const TodayControllerFixture({
    required this.database,
    required this.controller,
  });

  final AppDatabase database;
  final TodayController controller;

  Future<void> dispose() async {
    controller.dispose();
    await database.close();
  }
}

TodayControllerFixture createTodayControllerFixture() {
  final AppDatabase database = AppDatabase(NativeDatabase.memory());
  return TodayControllerFixture(
    database: database,
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
