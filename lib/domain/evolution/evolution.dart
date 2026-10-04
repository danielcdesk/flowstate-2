import 'package:flowstate/core/local_date.dart';

enum EvolutionEventKind { habit, task, focus, milestone }

final class EvolutionTimelineEvent {
  const EvolutionTimelineEvent({
    required this.date,
    required this.kind,
    required this.title,
    required this.detail,
    this.value,
  });

  final LocalDate date;
  final EvolutionEventKind kind;
  final String title;
  final String detail;
  final int? value;
}

final class AnnualRetrospective {
  AnnualRetrospective({
    required this.year,
    required this.isUnlocked,
    required Iterable<EvolutionTimelineEvent> events,
  }) : events = List<EvolutionTimelineEvent>.unmodifiable(events);

  final int year;
  final bool isUnlocked;
  final List<EvolutionTimelineEvent> events;
}

AnnualRetrospective calculateAnnualRetrospective({
  required int year,
  required LocalDate through,
  required Iterable<EvolutionTimelineEvent> events,
}) {
  if (year < 1 || year > 9999) throw ArgumentError.value(year, 'year');
  final LocalDate start = LocalDate(year, 1, 1);
  final LocalDate end = LocalDate(year, 12, 31);
  final List<EvolutionTimelineEvent> selected =
      events
          .where(
            (EvolutionTimelineEvent event) =>
                event.date.compareTo(start) >= 0 &&
                event.date.compareTo(end) <= 0,
          )
          .toList()
        ..sort((EvolutionTimelineEvent a, EvolutionTimelineEvent b) {
          final int dateOrder = a.date.compareTo(b.date);
          return dateOrder != 0 ? dateOrder : a.title.compareTo(b.title);
        });
  return AnnualRetrospective(
    year: year,
    isUnlocked: through.year > year,
    events: selected,
  );
}
