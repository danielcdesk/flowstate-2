import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/evolution/evolution.dart';

void main() {
  test('annual retrospective stays locked during the selected year', () {
    final AnnualRetrospective result = calculateAnnualRetrospective(
      year: 2026,
      through: LocalDate(2026, 10, 4),
      events: <EvolutionTimelineEvent>[
        EvolutionTimelineEvent(
          date: LocalDate(2026, 1, 2),
          kind: EvolutionEventKind.habit,
          title: 'Respirar',
          detail: '',
        ),
      ],
    );

    expect(result.isUnlocked, isFalse);
    expect(result.events, hasLength(1));
  });

  test('annual retrospective unlocks next year and sorts events', () {
    final AnnualRetrospective result = calculateAnnualRetrospective(
      year: 2025,
      through: LocalDate(2026, 1, 1),
      events: <EvolutionTimelineEvent>[
        EvolutionTimelineEvent(
          date: LocalDate(2025, 12, 10),
          kind: EvolutionEventKind.task,
          title: 'Tarde',
          detail: '',
        ),
        EvolutionTimelineEvent(
          date: LocalDate(2024, 12, 10),
          kind: EvolutionEventKind.focus,
          title: 'Fora do período',
          detail: '',
        ),
        EvolutionTimelineEvent(
          date: LocalDate(2025, 2, 10),
          kind: EvolutionEventKind.habit,
          title: 'Primeiro',
          detail: '',
        ),
      ],
    );

    expect(result.isUnlocked, isTrue);
    expect(
      result.events.map((EvolutionTimelineEvent event) => event.title),
      <String>['Primeiro', 'Tarde'],
    );
  });
}
