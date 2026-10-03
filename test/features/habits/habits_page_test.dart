import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/design/theme.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/repositories/habit_repository.dart';
import 'package:flowstate/domain/repositories/xp_repository.dart';
import 'package:flowstate/features/habits/presentation/habits_page.dart';
import 'package:flowstate/features/habits/application/habits_controller.dart';
import 'package:flowstate/l10n/app_localizations.dart';

import '../../fixtures/domain_fixtures.dart';
import '../../fixtures/today_controller_fixture.dart';

void main() {
  testWidgets('creates a habit and records today completion', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(900, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await fixture.habitsController.load();
    await tester.pumpWidget(_app(fixture));
    await tester.pumpAndSettle();

    expect(find.text('Comece com um passo pequeno'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Criar hábito').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'Ler todos os dias',
    );
    await tester.ensureVisible(find.text('Salvar hábito'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar hábito'));
    await tester.pumpAndSettle();

    expect(find.text('Ler todos os dias'), findsOneWidget);
    await tester.tap(find.byTooltip('Marcar como feito'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Feito hoje'), findsOneWidget);
    expect(
      find.text('Concluído. Seu progresso foi atualizado.'),
      findsOneWidget,
    );
  });

  testWidgets('habit page meets accessibility guidelines with history', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await DriftHabitRepository(fixture.database).saveHabit(testHabit(id: 901));
    await fixture.habitsController.load();
    await tester.pumpWidget(_app(fixture));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hábito 901'));
    await tester.pumpAndSettle();

    expect(tester, meetsGuideline(textContrastGuideline));
    expect(tester, meetsGuideline(androidTapTargetGuideline));
    expect(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('shows loading while local habits are being read', (
    WidgetTester tester,
  ) async {
    final Completer<List<Habit>> gate = Completer<List<Habit>>();
    final HabitsController controller = _controller(
      _TestHabitRepository(activeHabits: gate.future),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(_controllerApp(controller));
    await tester.pump();

    expect(find.text('Carregando seus hábitos'), findsOneWidget);
    gate.complete(<Habit>[]);
    await tester.pumpAndSettle();
    expect(find.text('Comece com um passo pequeno'), findsOneWidget);
  });

  testWidgets('shows a recoverable message when local loading fails', (
    WidgetTester tester,
  ) async {
    final HabitsController controller = _controller(
      _TestHabitRepository(shouldFail: true),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(_controllerApp(controller));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não foi possível carregar seus hábitos. Seus dados continuam neste aparelho.',
      ),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('keeps the compact header usable with 200 percent text', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await DriftHabitRepository(fixture.database).saveHabit(testHabit(id: 902));
    await fixture.habitsController.load();
    await tester.pumpWidget(_app(fixture, textScaleFactor: 2));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

Widget _app(TodayControllerFixture fixture, {double textScaleFactor = 1}) =>
    MaterialApp(
      theme: FlowTheme.light(),
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
    );

Widget _controllerApp(HabitsController controller) => MaterialApp(
  theme: FlowTheme.light(),
  locale: const Locale('pt', 'BR'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: HabitsPage(controller: controller)),
);

HabitsController _controller(HabitRepository repository) => HabitsController(
  habitRepository: repository,
  xpRepository: _TestXpRepository(),
  clock: Clock.fixed(DateTime(2026, 9, 30, 10)),
  deviceId: 'test-device',
);

final class _TestHabitRepository implements HabitRepository {
  _TestHabitRepository({this.activeHabits, this.shouldFail = false});

  final Future<List<Habit>>? activeHabits;
  final bool shouldFail;

  @override
  Future<List<Habit>> getActiveHabits() {
    if (shouldFail) {
      return Future<List<Habit>>.error(StateError('local read failed'));
    }
    return activeHabits ?? Future<List<Habit>>.value(<Habit>[]);
  }

  @override
  Future<List<HabitLog>> getHabitLogs({
    required LocalDate from,
    required LocalDate through,
  }) async => <HabitLog>[];

  @override
  Future<void> saveHabit(Habit habit) async {}

  @override
  Future<void> saveHabitLog(HabitLog log) async {}
}

final class _TestXpRepository implements XpRepository {
  @override
  Future<List<XpEvent>> getLedger({LocalDate? through}) async => <XpEvent>[];

  @override
  Future<bool> insertIfAbsent(XpEvent event) async => false;

  @override
  Future<void> reverse(XpEvent event) async {}
}
