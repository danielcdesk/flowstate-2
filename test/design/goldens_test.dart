import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/app/shell.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/design/theme.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/features/habits/presentation/habits_page.dart';
import 'package:flowstate/features/plan/presentation/plan_page.dart';
import 'package:flowstate/features/focus/presentation/focus_session_sheet.dart';
import 'package:flowstate/domain/tasks/task.dart';
import 'package:flowstate/l10n/app_localizations.dart';

import '../fixtures/domain_fixtures.dart';
import '../fixtures/today_controller_fixture.dart';

const Size _compactViewport = Size(390, 844);
const Size _expandedViewport = Size(1440, 900);

void main() {
  testWidgets('Flow State compact light golden', (WidgetTester tester) async {
    await _pumpFlow(tester, _compactViewport, FlowTheme.light());
    await expectLater(
      find.byType(AdaptiveShell),
      matchesGoldenFile('goldens/flow-state-compact-light.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Flow State compact dark golden', (WidgetTester tester) async {
    await _pumpFlow(tester, _compactViewport, FlowTheme.dark());
    await expectLater(
      find.byType(AdaptiveShell),
      matchesGoldenFile('goldens/flow-state-compact-dark.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Flow State expanded light golden', (WidgetTester tester) async {
    await _pumpFlow(tester, _expandedViewport, FlowTheme.light());
    await expectLater(
      find.byType(AdaptiveShell),
      matchesGoldenFile('goldens/flow-state-expanded-light.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Flow State expanded dark golden', (WidgetTester tester) async {
    await _pumpFlow(tester, _expandedViewport, FlowTheme.dark());
    await expectLater(
      find.byType(AdaptiveShell),
      matchesGoldenFile('goldens/flow-state-expanded-dark.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Flow State compact light at 200 percent text', (
    WidgetTester tester,
  ) async {
    await _pumpFlow(
      tester,
      _compactViewport,
      FlowTheme.light(),
      textScaleFactor: 2,
    );
    await expectLater(
      find.byType(AdaptiveShell),
      matchesGoldenFile('goldens/flow-state-compact-light-text-200.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Habits compact light golden', (WidgetTester tester) async {
    await _pumpHabits(tester, _compactViewport, FlowTheme.light());
    await expectLater(
      find.byType(HabitsPage),
      matchesGoldenFile('goldens/habits-compact-light.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Habits compact dark golden', (WidgetTester tester) async {
    await _pumpHabits(tester, _compactViewport, FlowTheme.dark());
    await expectLater(
      find.byType(HabitsPage),
      matchesGoldenFile('goldens/habits-compact-dark.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Habits expanded light golden', (WidgetTester tester) async {
    await _pumpHabits(tester, _expandedViewport, FlowTheme.light());
    await expectLater(
      find.byType(HabitsPage),
      matchesGoldenFile('goldens/habits-expanded-light.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Habits expanded dark golden', (WidgetTester tester) async {
    await _pumpHabits(tester, _expandedViewport, FlowTheme.dark());
    await expectLater(
      find.byType(HabitsPage),
      matchesGoldenFile('goldens/habits-expanded-dark.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Habits compact light at 200 percent text', (
    WidgetTester tester,
  ) async {
    await _pumpHabits(
      tester,
      _compactViewport,
      FlowTheme.light(),
      textScaleFactor: 2,
    );
    await expectLater(
      find.byType(HabitsPage),
      matchesGoldenFile('goldens/habits-compact-light-text-200.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Plan compact light golden', (WidgetTester tester) async {
    await _pumpPlan(tester, _compactViewport, FlowTheme.light());
    await expectLater(
      find.byType(PlanPage),
      matchesGoldenFile('goldens/plan-compact-light.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Plan compact dark golden', (WidgetTester tester) async {
    await _pumpPlan(tester, _compactViewport, FlowTheme.dark());
    await expectLater(
      find.byType(PlanPage),
      matchesGoldenFile('goldens/plan-compact-dark.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Plan expanded light golden', (WidgetTester tester) async {
    await _pumpPlan(tester, _expandedViewport, FlowTheme.light());
    await expectLater(
      find.byType(PlanPage),
      matchesGoldenFile('goldens/plan-expanded-light.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Plan expanded dark golden', (WidgetTester tester) async {
    await _pumpPlan(tester, _expandedViewport, FlowTheme.dark());
    await expectLater(
      find.byType(PlanPage),
      matchesGoldenFile('goldens/plan-expanded-dark.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Plan compact light at 200 percent text', (
    WidgetTester tester,
  ) async {
    await _pumpPlan(
      tester,
      _compactViewport,
      FlowTheme.light(),
      textScaleFactor: 2,
    );
    await expectLater(
      find.byType(PlanPage),
      matchesGoldenFile('goldens/plan-compact-light-text-200.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Focus compact light golden', (WidgetTester tester) async {
    await _pumpFocus(tester, _compactViewport, FlowTheme.light());
    await expectLater(
      find.byType(FocusSessionSheet),
      matchesGoldenFile('goldens/focus-compact-light.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Focus compact dark golden', (WidgetTester tester) async {
    await _pumpFocus(tester, _compactViewport, FlowTheme.dark());
    await expectLater(
      find.byType(FocusSessionSheet),
      matchesGoldenFile('goldens/focus-compact-dark.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Focus expanded light golden', (WidgetTester tester) async {
    await _pumpFocus(tester, _expandedViewport, FlowTheme.light());
    await expectLater(
      find.byType(FocusSessionSheet),
      matchesGoldenFile('goldens/focus-expanded-light.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Focus expanded dark golden', (WidgetTester tester) async {
    await _pumpFocus(tester, _expandedViewport, FlowTheme.dark());
    await expectLater(
      find.byType(FocusSessionSheet),
      matchesGoldenFile('goldens/focus-expanded-dark.png'),
    );
  }, skip: Platform.isWindows);

  testWidgets('Focus compact light at 200 percent text', (
    WidgetTester tester,
  ) async {
    await _pumpFocus(
      tester,
      _compactViewport,
      FlowTheme.light(),
      textScaleFactor: 2,
    );
    await expectLater(
      find.byType(FocusSessionSheet),
      matchesGoldenFile('goldens/focus-compact-light-text-200.png'),
    );
  }, skip: Platform.isWindows);
}

Future<void> _pumpFlow(
  WidgetTester tester,
  Size viewport,
  ThemeData theme, {
  double textScaleFactor = 1,
}) async {
  tester.view
    ..physicalSize = viewport
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final fixture = createTodayControllerFixture();
  addTearDown(fixture.dispose);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (BuildContext context) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScaleFactor)),
            child: AdaptiveShell(
              todayController: fixture.controller,
              habitsController: fixture.habitsController,
              planController: fixture.planController,
            ),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpHabits(
  WidgetTester tester,
  Size viewport,
  ThemeData theme, {
  double textScaleFactor = 1,
}) async {
  tester.view
    ..physicalSize = viewport
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final fixture = createTodayControllerFixture();
  addTearDown(fixture.dispose);
  final DriftHabitRepository repository = DriftHabitRepository(
    fixture.database,
  );
  final List<Habit> examples = <Habit>[
    Habit(
      metadata: testMetadata(801),
      name: 'Ler dez minutos',
      iconId: 'reading',
      categoryId: HabitCategoryId.mind,
      recurrence: Recurrence.daily(),
      cue: 'Depois do café',
      minimumVersion: 'Uma página',
      isEssential: true,
    ),
    Habit(
      metadata: testMetadata(802),
      name: 'Movimento leve',
      iconId: 'movement',
      categoryId: HabitCategoryId.body,
      recurrence: Recurrence.weeklyTarget(3),
      cue: 'No intervalo da tarde',
    ),
  ];
  for (final Habit habit in examples) {
    await repository.saveHabit(habit);
  }
  await fixture.habitsController.load();
  await fixture.habitsController.logToday(
    fixture.habitsController.habits.first,
    HabitLogLevel.minimum,
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: Scaffold(
            body: HabitsPage(controller: fixture.habitsController),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpPlan(
  WidgetTester tester,
  Size viewport,
  ThemeData theme, {
  double textScaleFactor = 1,
}) async {
  tester.view
    ..physicalSize = viewport
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final fixture = createTodayControllerFixture();
  addTearDown(fixture.dispose);
  final LocalDate date = LocalDate(2026, 9, 30);
  await DriftTaskRepository(fixture.database).saveTask(
    Task(
      metadata: testMetadata(901),
      title: 'Revisar prioridades',
      dueDate: date,
      dueMinute: 600,
      estimatedMinutes: 45,
      priority: TaskPriority.high,
    ),
  );
  await DriftRoutineRepository(fixture.database).saveBlock(
    testBlock(
      id: 902,
      title: 'Pausa para caminhar',
      startMinute: 720,
      durationMinutes: 30,
      weekdays: <int>{date.weekday},
    ),
  );
  await fixture.planController.load(date: date);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: Scaffold(body: PlanPage(controller: fixture.planController)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpFocus(
  WidgetTester tester,
  Size viewport,
  ThemeData theme, {
  double textScaleFactor = 1,
}) async {
  tester.view
    ..physicalSize = viewport
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final fixture = createTodayControllerFixture();
  addTearDown(fixture.dispose);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: Scaffold(
            body: FocusSessionSheet(controller: fixture.focusController),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
