import 'dart:convert';
import 'dart:io';

import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/tasks/task.dart';

String exportHabitsCsv(Iterable<Habit> habits) {
  return _csv(<List<String>>[
    <String>['id', 'name', 'category', 'cue', 'minimum_version', 'essential'],
    for (final Habit habit in habits)
      <String>[
        habit.id,
        habit.name,
        habit.categoryId,
        habit.cue ?? '',
        habit.minimumVersion ?? '',
        habit.isEssential ? 'true' : 'false',
      ],
  ]);
}

String exportTasksCsv(Iterable<Task> tasks) {
  return _csv(<List<String>>[
    <String>['id', 'title', 'notes', 'due_date', 'due_minute', 'priority'],
    for (final Task task in tasks)
      <String>[
        task.id,
        task.title,
        task.notes ?? '',
        task.dueDate?.toString() ?? '',
        task.dueMinute?.toString() ?? '',
        task.priority.name,
      ],
  ]);
}

Future<File> writeCsv(File destination, String csv) async {
  await destination.parent.create(recursive: true);
  return destination.writeAsString('\uFEFF$csv', encoding: utf8, flush: true);
}

String _csv(List<List<String>> rows) =>
    rows.map((List<String> row) => row.map(_cell).join(',')).join('\r\n');

String _cell(String input) {
  final String value = _isFormula(input) ? "'$input" : input;
  final String escaped = value.replaceAll('"', '""');
  if (escaped.contains(',') ||
      escaped.contains('"') ||
      escaped.contains('\r') ||
      escaped.contains('\n')) {
    return '"$escaped"';
  }
  return escaped;
}

bool _isFormula(String value) {
  final String candidate = value.replaceFirst(
    RegExp(r'^[\s\u0000-\u001f]+'),
    '',
  );
  return candidate.startsWith('=') ||
      candidate.startsWith('+') ||
      candidate.startsWith('-') ||
      candidate.startsWith('@');
}
