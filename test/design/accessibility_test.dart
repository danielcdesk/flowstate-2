import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/design/theme.dart';
import 'package:flowstate/features/today/presentation/today_page.dart';

void main() {
  testWidgets('Today follows the accessibility guidelines', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: FlowTheme.light(),
        home: const TodayPage(),
      ),
    );

    expect(await meetsGuideline(tester, textContrastGuideline), isTrue);
    expect(await meetsGuideline(tester, androidTapTargetGuideline), isTrue);
    expect(await meetsGuideline(tester, labeledTapTargetGuideline), isTrue);
    semantics.dispose();
  });
}
