import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/data/database/app_database.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/features/evolution/application/evolution_controller.dart';
import 'package:flowstate/features/evolution/presentation/evolution_page.dart';
import 'package:flowstate/l10n/app_localizations.dart';

void main() {
  testWidgets('shows radar and locked annual retrospective', (
    WidgetTester tester,
  ) async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    final EvolutionController controller = EvolutionController(
      habitRepository: DriftHabitRepository(database),
      taskRepository: DriftTaskRepository(database),
      focusRepository: DriftFocusRepository(database),
      xpRepository: DriftXpRepository(database),
      clock: Clock(() => DateTime(2026, 10, 4, 10)),
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: EvolutionPage(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Skill radar'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Your story is still unfolding'),
      400,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Your story is still unfolding'), findsOneWidget);

    controller.dispose();
    await database.close();
  });
}
