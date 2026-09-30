import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/app/app.dart';

void main() {
  testWidgets('opens a blank shell', (WidgetTester tester) async {
    await tester.pumpWidget(const FlowStateApp());

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
