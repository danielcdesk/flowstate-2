import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/data/database/app_database.dart' as db;
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/features/workouts/application/workouts_controller.dart';

void main() {
  test(
    'persists a starter workout, sets and idempotent completion XP',
    () async {
      final db.AppDatabase database = db.AppDatabase(NativeDatabase.memory());
      final Clock clock = Clock(() => DateTime.utc(2026, 10, 4, 12));
      final WorkoutsController controller = WorkoutsController(
        repository: DriftWorkoutRepository(database),
        xpRepository: DriftXpRepository(database),
        clock: clock,
        deviceId: 'test-device',
      );

      await controller.load();
      await controller.createStarterPlan(title: 'Teste');
      expect(controller.plans, hasLength(1));
      await controller.startSession(controller.plans.single);
      await controller.recordSet(
        exerciseId: defaultWorkoutExercises.first.id,
        repetitions: 8,
        loadKg: 10,
        restSeconds: 90,
      );
      expect(controller.activeSets, hasLength(1));
      await controller.finishSession();
      expect(controller.activeSession, isNull);
      final List<XpEvent> ledger = await DriftXpRepository(database)
          .getLedger();
      expect(ledger.single.action, XpAction.workout);
      expect(ledger.single.xp, XpPolicy.workout);

      controller.dispose();
      await database.close();
    },
  );
}
