import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/design/theme.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/repositories/routine_repository.dart';
import 'package:flowstate/domain/repositories/task_repository.dart';
import 'package:flowstate/domain/repositories/xp_repository.dart';
import 'package:flowstate/domain/routine/routine_block.dart';
import 'package:flowstate/domain/tasks/task.dart';
import 'package:flowstate/features/plan/application/plan_controller.dart';
import 'package:flowstate/features/plan/presentation/plan_page.dart';
import 'package:flowstate/l10n/app_localizations.dart';

import '../../fixtures/today_controller_fixture.dart';
import '../../fixtures/domain_fixtures.dart';

void main() {
  testWidgets('shows a useful empty plan and creates a task', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await tester.pumpWidget(_app(fixture.planController));
    await tester.pumpAndSettle();

    expect(find.text('Um dia aberto'), findsOneWidget);
    await tester.tap(find.text('Criar tarefa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Estudar Dart');
    await tester.ensureVisible(find.text('Salvar tarefa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar tarefa'));
    await tester.pumpAndSettle();

    expect(find.text('Estudar Dart'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creates a recurring routine block and announces a conflict', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(900, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    final date = fixture.planController.selectedDate ?? LocalDate(2026, 9, 30);
    await fixture.planController.load(date: date);
    await fixture.planController.saveTask(
      title: 'Consulta',
      date: date,
      dueMinute: 540,
      estimatedMinutes: 60,
      priority: TaskPriority.normal,
      recurrence: null,
    );
    await tester.pumpWidget(_app(fixture.planController));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Criar bloco'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Pausa');
    await tester.ensureVisible(find.text('Salvar bloco'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar bloco'));
    await tester.pumpAndSettle();

    expect(find.text('Pausa'), findsOneWidget);
    expect(find.text('Há horários sobrepostos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('plan page meets accessibility guidelines', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await tester.pumpWidget(_app(fixture.planController));
    await tester.pumpAndSettle();

    expect(tester, meetsGuideline(textContrastGuideline));
    expect(tester, meetsGuideline(androidTapTargetGuideline));
    expect(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('keeps plan usable at 200 percent text scaling', (
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
      testTask(id: 811, title: 'Revisar semana', dueDate: date, dueMinute: 600),
    );
    await DriftRoutineRepository(fixture.database).saveBlock(
      testBlock(id: 812, title: 'Pausa ativa', weekdays: <int>{date.weekday}),
    );
    await fixture.planController.load(date: date);
    await tester.pumpWidget(_app(fixture.planController, textScaleFactor: 2));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows loading and a recoverable load error', (
    WidgetTester tester,
  ) async {
    final Completer<List<Task>> gate = Completer<List<Task>>();
    final PlanController loadingController = _controller(
      _FakeTaskRepository(tasks: gate.future),
    );
    addTearDown(loadingController.dispose);
    await tester.pumpWidget(_app(loadingController));
    await tester.pump();
    expect(find.bySemanticsLabel('Carregando seu plano'), findsOneWidget);
    gate.complete(<Task>[]);
    await tester.pumpAndSettle();

    final PlanController errorController = _controller(
      _FakeTaskRepository(shouldFail: true),
    );
    addTearDown(errorController.dispose);
    await tester.pumpWidget(_app(errorController));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Não foi possível carregar seu plano. Seus dados continuam neste aparelho.',
      ),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}

Widget _app(PlanController controller, {double textScaleFactor = 1}) =>
    MaterialApp(
      theme: FlowTheme.light(),
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: Scaffold(body: PlanPage(controller: controller)),
        ),
      ),
    );

PlanController _controller(TaskRepository taskRepository) => PlanController(
  taskRepository: taskRepository,
  routineRepository: _FakeRoutineRepository(),
  xpRepository: _FakeXpRepository(),
  clock: Clock.fixed(DateTime(2026, 9, 30, 10)),
  deviceId: 'test-device',
);

final class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository({this.tasks, this.shouldFail = false});

  final Future<List<Task>>? tasks;
  final bool shouldFail;

  @override
  Future<List<Task>> getActiveTasks() => shouldFail
      ? Future<List<Task>>.error(StateError('local read failed'))
      : tasks ?? Future<List<Task>>.value(<Task>[]);

  @override
  Future<List<TaskCompletion>> getCompletions({
    required LocalDate from,
    required LocalDate through,
  }) async => <TaskCompletion>[];

  @override
  Future<void> saveCompletion(TaskCompletion completion) async {}

  @override
  Future<void> saveTask(Task task) async {}
}

final class _FakeRoutineRepository implements RoutineRepository {
  @override
  Future<List<RoutineBlock>> getActiveBlocks() async => <RoutineBlock>[];

  @override
  Future<void> saveBlock(RoutineBlock block) async {}
}

final class _FakeXpRepository implements XpRepository {
  @override
  Future<List<XpEvent>> getLedger({LocalDate? through}) async => <XpEvent>[];

  @override
  Future<bool> insertIfAbsent(XpEvent event) async => false;

  @override
  Future<void> reverse(XpEvent event) async {}
}
