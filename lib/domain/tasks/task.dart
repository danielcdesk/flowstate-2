import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';

enum TaskPriority { low, normal, high }

final class Task {
  Task({
    required this.metadata,
    required this.title,
    this.notes,
    this.dueDate,
    this.dueMinute,
    this.estimatedMinutes,
    this.priority = TaskPriority.normal,
    this.projectId,
    this.recurrence,
  }) {
    if (title.trim().isEmpty) throw ArgumentError.value(title, 'title');
    final int? minute = dueMinute;
    if (minute != null && (minute < 0 || minute >= 1440)) {
      throw ArgumentError.value(minute, 'dueMinute');
    }
    final int? estimate = estimatedMinutes;
    if (estimate != null && estimate < 1) {
      throw ArgumentError.value(estimate, 'estimatedMinutes');
    }
    if (recurrence != null && dueDate == null) {
      throw ArgumentError('Recurring tasks require an anchor date.');
    }
  }

  final RecordMetadata metadata;
  final String title;
  final String? notes;
  final LocalDate? dueDate;
  final int? dueMinute;
  final int? estimatedMinutes;
  final TaskPriority priority;
  final String? projectId;
  final Recurrence? recurrence;

  String get id => metadata.id;

  bool isScheduledOn(LocalDate date) {
    final LocalDate? anchor = dueDate;
    if (anchor == null) return false;
    final Recurrence? rule = recurrence;
    return rule == null ? anchor == date : rule.isScheduledOn(date);
  }
}

final class TaskCompletion {
  TaskCompletion({
    required this.metadata,
    required this.taskId,
    required this.occurrenceDate,
  });

  final RecordMetadata metadata;
  final String taskId;
  final LocalDate occurrenceDate;
}

bool isTaskCompleted({
  required Task task,
  required LocalDate occurrenceDate,
  required Iterable<TaskCompletion> completions,
}) {
  return completions.any(
    (TaskCompletion completion) =>
        completion.taskId == task.id &&
        completion.occurrenceDate == occurrenceDate &&
        completion.metadata.deletedAt == null,
  );
}
