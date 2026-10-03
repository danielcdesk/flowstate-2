import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/design/components/skill_radar.dart';
import 'package:flowstate/design/theme.dart';

void main() {
  testWidgets('renders the radar and its accessible value list', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: FlowTheme.dark(),
        home: const Scaffold(
          body: SkillRadar(
            title: 'Radar de habilidades',
            metrics: <SkillRadarMetric>[
              SkillRadarMetric(label: 'Constância', value: 78),
              SkillRadarMetric(label: 'Foco', value: 64),
              SkillRadarMetric(label: 'Planejamento', value: 53),
              SkillRadarMetric(label: 'Energia', value: 71),
              SkillRadarMetric(label: 'Força', value: 42),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(SkillRadar), findsOneWidget);
    expect(find.bySemanticsLabel('Radar de habilidades'), findsOneWidget);
    expect(find.text('Constância 78%'), findsOneWidget);
    expect(find.text('Força 42%'), findsOneWidget);
    semantics.dispose();
  });

  test('clamps values to the visual scale', () {
    const SkillRadarMetric metric = SkillRadarMetric(label: 'Foco', value: 140);

    expect(metric.normalizedValue, 100);
  });
}
