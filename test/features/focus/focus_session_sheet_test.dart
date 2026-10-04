import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/design/theme.dart';
import 'package:flowstate/domain/focus/focus_session.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/repositories/focus_repository.dart';
import 'package:flowstate/domain/repositories/task_repository.dart';
import 'package:flowstate/domain/repositories/xp_repository.dart';
import 'package:flowstate/domain/tasks/task.dart';
import 'package:flowstate/features/focus/application/focus_controller.dart';
import 'package:flowstate/features/focus/presentation/focus_session_sheet.dart';
import 'package:flowstate/l10n/app_localizations.dart';

import '../../fixtures/domain_fixtures.dart';
import '../../fixtures/today_controller_fixture.dart';

void main() {
  testWidgets('starts a session linked to a chosen task', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await DriftTaskRepository(fixture.database)
        .saveTask(testTask(id: 951, title: 'Ler documentação'));
    await tester.pumpWidget(_app(fixture.focusController));
    await tester.pumpAndSettle();

    expect(find.text('Sessão de foco'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ler documentação').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar foco'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Seu foco está em andamento'), findsOneWidget);
    expect(find.text('Ler documentação'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(fixture.focusController.activeSession?.taskId, testUuid(951));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await fixture.focusController.stopSession();
  });

  testWidgets('meets accessibility guidelines', (WidgetTester tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await tester.pumpWidget(_app(fixture.focusController));
    await tester.pumpAndSettle();

    expect(tester, meetsGuideline(textContrastGuideline));
    expect(tester, meetsGuideline(androidTapTargetGuideline));
    expect(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('remains usable at 200 percent text scaling', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await tester.pumpWidget(_app(fixture.focusController, textScaleFactor: 2));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows loading and a recoverable storage error', (
    WidgetTester tester,
  ) async {
    final Completer<List<FocusSession>> gate = Completer<List<FocusSession>>();
    final FocusController loadingController = _controller(
      _FakeFocusRepository(sessions: gate.future),
    );
    addTearDown(loadingController.dispose);
    await tester.pumpWidget(_app(loadingController));
    await tester.pump();
    expect(
      find.bySemanticsLabel('Carregando sua sessão de foco'),
      findsOneWidget,
    );
    gate.complete(<FocusSession>[]);
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());

    final FocusController errorController = _controller(
      _FakeFocusRepository(shouldFail: true),
    );
    addTearDown(errorController.dispose);
    await tester.pumpWidget(_app(errorController));
    await tester.pumpAndSettle();
    expect(errorController.error, isNotNull);
    expect(
      find.text(
        'Não foi possível carregar seu foco. Seus dados continuam neste aparelho.',
      ),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}

Widget _app(FocusController controller, {double textScaleFactor = 1}) =>
    MaterialApp(
      theme: FlowTheme.dark(),
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: Scaffold(body: FocusSessionSheet(controller: controller)),
        ),
      ),
    );

FocusController _controller(FocusRepository focusRepository) => FocusController(
  focusRepository: focusRepository,
  taskRepository: _FakeTaskRepository(),
  xpRepository: _FakeXpRepository(),
  clock: Clock.fixed(DateTime(2026, 9, 30, 10)),
  deviceId: testDeviceId,
);

final class _FakeFocusRepository implements FocusRepository {
  _FakeFocusRepository({this.sessions, this.shouldFail = false});

  final Future<List<FocusSession>>? sessions;
  final bool shouldFail;

  @override
  Future<List<FocusSession>> getSessions() => shouldFail
      ? Future<List<FocusSession>>.error(StateError('local read failed'))
      : sessions ?? Future<List<FocusSession>>.value(<FocusSession>[]);

  @override
  Future<void> saveSession(FocusSession session) async {}
}

final class _FakeTaskRepository implements TaskRepository {
  @override
  Future<List<Task>> getActiveTasks() async => <Task>[];

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

final class _FakeXpRepository implements XpRepository {
  @override
  Future<List<XpEvent>> getLedger({LocalDate? through}) async => <XpEvent>[];

  @override
  Future<bool> insertIfAbsent(XpEvent event) async => true;

  @override
  Future<void> reverse(XpEvent event) async {}
}
