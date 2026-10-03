import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/design/theme.dart';
import 'package:flowstate/features/today/presentation/today_page.dart';

import '../../fixtures/today_controller_fixture.dart';

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
}
