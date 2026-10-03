import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/design/components/flow_ring.dart';
import 'package:flowstate/design/theme.dart';
import 'package:flowstate/features/welcome/presentation/welcome_page.dart';

void main() {
  testWidgets('shows the calm welcome composition', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: FlowTheme.light(), home: const WelcomePage()),
    );

    expect(find.text('Seu dia em um só lugar.'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
    expect(find.byType(FlowRing), findsOneWidget);
    expect(find.text('Seus dados ficam neste aparelho.'), findsOneWidget);
  });
}
