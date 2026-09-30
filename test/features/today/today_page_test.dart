import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/design/theme.dart';
import 'package:flowstate/features/today/presentation/today_page.dart';

void main() {
  testWidgets('shows the Today composition with a hero and actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FlowTheme.light(),
        home: const Scaffold(body: TodayPage()),
      ),
    );

    expect(find.text('Feitos hoje'), findsOneWidget);
    expect(find.text('Próxima ação'), findsOneWidget);
    expect(find.text('Novo hábito'), findsOneWidget);
    expect(find.text('Hábitos de hoje'), findsOneWidget);
  });
}
