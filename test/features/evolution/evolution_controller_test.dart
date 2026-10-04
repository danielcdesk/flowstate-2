import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/data/database/app_database.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/features/evolution/application/evolution_controller.dart';

void main() {
  test('loads an empty local history into a locked annual review', () async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    final EvolutionController controller = EvolutionController(
      habitRepository: DriftHabitRepository(database),
      taskRepository: DriftTaskRepository(database),
      focusRepository: DriftFocusRepository(database),
      xpRepository: DriftXpRepository(database),
      clock: Clock(() => DateTime(2026, 10, 4, 10)),
    );

    await controller.load();

    expect(controller.failedToLoad, isFalse);
    expect(controller.radar, hasLength(3));
    expect(controller.weeklyReview.isReady, isTrue);
    expect(controller.annual.isUnlocked, isFalse);
    expect(controller.totalXp, 0);

    controller.dispose();
    await database.close();
  });
}
