import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/design/theme.dart';
import 'package:flowstate/features/today/presentation/today_page.dart';

import '../fixtures/today_controller_fixture.dart';

void main() {
  testWidgets('Today follows the accessibility guidelines', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: FlowTheme.light(),
        home: Scaffold(body: TodayPage(controller: fixture.controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester, meetsGuideline(textContrastGuideline));
    expect(tester, meetsGuideline(androidTapTargetGuideline));
    expect(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });
}
