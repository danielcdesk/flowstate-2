import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/design/theme.dart';
import 'package:flowstate/app/shell.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/features/today/presentation/today_page.dart';

import '../../fixtures/today_controller_fixture.dart';
import '../../fixtures/domain_fixtures.dart';

void main() {
  testWidgets('shows the Today composition with a hero and actions', (
    WidgetTester tester,
  ) async {
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: FlowTheme.light(),
        home: Scaffold(body: TodayPage(controller: fixture.controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Feitos hoje'), findsOneWidget);
    expect(find.text('Próxima ação'), findsOneWidget);
    expect(find.text('Criar hábito'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Hábitos de hoje'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Hábitos de hoje'), findsOneWidget);
  });

  testWidgets('opens the focus session from the Today quick action', (
    WidgetTester tester,
  ) async {
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: FlowTheme.dark(),
        home: AdaptiveShell(
          todayController: fixture.controller,
          habitsController: fixture.habitsController,
          planController: fixture.planController,
          focusController: fixture.focusController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Iniciar foco'));
    await tester.pumpAndSettle();

    expect(find.text('Sessão de foco'), findsOneWidget);
    expect(find.text('Por quanto tempo?'), findsOneWidget);
  });

  testWidgets('opens focus with the selected task from the weekly plan', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    final LocalDate date = LocalDate(2026, 9, 30);
    await DriftTaskRepository(fixture.database).saveTask(
      testTask(
        id: 962,
        title: 'Preparar apresentação',
        dueDate: date,
        dueMinute: 600,
        estimatedMinutes: 25,
      ),
    );
    await fixture.planController.load(date: date);
    await tester.pumpWidget(
      MaterialApp(
        theme: FlowTheme.dark(),
        home: AdaptiveShell(
          todayController: fixture.controller,
          habitsController: fixture.habitsController,
          planController: fixture.planController,
          focusController: fixture.focusController,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plano'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Iniciar foco nesta tarefa'));
    await tester.pumpAndSettle();

    expect(fixture.focusController.activeSession, isNull);
    expect(find.text('Preparar apresentação'), findsWidgets);
    await tester.tap(find.text('Iniciar foco'));
    await tester.pump();
    await tester.pump();

    expect(fixture.focusController.activeSession?.taskId, testUuid(962));
    await tester.pumpWidget(const SizedBox());
    await fixture.focusController.stopSession();
  });
}
