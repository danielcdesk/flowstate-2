import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/data/database/app_database.dart' as db;
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/features/workouts/application/workouts_controller.dart';
import 'package:flowstate/features/workouts/presentation/workouts_page.dart';
import 'package:flowstate/l10n/app_localizations.dart';

void main() {
  testWidgets('offers a starter workout when local plans are empty', (
    WidgetTester tester,
  ) async {
    final db.AppDatabase database = db.AppDatabase(NativeDatabase.memory());
    final WorkoutsController controller = WorkoutsController(
      repository: DriftWorkoutRepository(database),
      xpRepository: DriftXpRepository(database),
      clock: Clock(() => DateTime.utc(2026, 10, 4, 12)),
      deviceId: 'test-device',
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: WorkoutsPage(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create starter workout'), findsOneWidget);
    await tester.tap(find.text('Create starter workout'));
    await tester.pumpAndSettle();
    expect(find.text('Essential strength'), findsOneWidget);

    controller.dispose();
    await database.close();
  });
}
