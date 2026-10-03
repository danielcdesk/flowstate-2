import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';

final class RoutineBlock {
  RoutineBlock({
    required this.metadata,
    required this.title,
    required this.startMinute,
    required this.durationMinutes,
    required this.categoryId,
    required Set<int> weekdays,
  }) : weekdays = Set<int>.unmodifiable(weekdays) {
    if (title.trim().isEmpty) throw ArgumentError.value(title, 'title');
    if (startMinute < 0 || startMinute >= 1440) {
      throw ArgumentError.value(startMinute, 'startMinute');
    }
    if (durationMinutes < 1 || durationMinutes > 2880) {
      throw ArgumentError.value(durationMinutes, 'durationMinutes');
    }
    if (categoryId.trim().isEmpty) {
      throw ArgumentError.value(categoryId, 'categoryId');
    }
    if (this.weekdays.isEmpty ||
        this.weekdays.any((int day) => day < 1 || day > 7)) {
      throw ArgumentError.value(weekdays, 'weekdays');
    }
  }

  final RecordMetadata metadata;
  final String title;
  final int startMinute;
  final int durationMinutes;
  final String categoryId;
  final Set<int> weekdays;

  String get id => metadata.id;

  bool isScheduledOn(LocalDate date) => weekdays.contains(date.weekday);
}
