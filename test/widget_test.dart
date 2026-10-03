import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:flowstate/app/app.dart';
import 'package:flowstate/data/database/app_database.dart';

void main() {
  testWidgets('opens a blank shell', (WidgetTester tester) async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(FlowStateApp(database: database));
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
