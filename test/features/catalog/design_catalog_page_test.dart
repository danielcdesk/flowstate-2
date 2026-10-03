import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/design/components/skill_radar.dart';
import 'package:flowstate/design/theme.dart';
import 'package:flowstate/features/catalog/presentation/design_catalog_page.dart';

void main() {
  testWidgets('shows the debug catalog radar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: FlowTheme.dark(), home: const DesignCatalogPage()),
    );

    expect(find.byType(SkillRadar), findsOneWidget);
    expect(find.text('Radar de habilidades'), findsOneWidget);
  });
}
