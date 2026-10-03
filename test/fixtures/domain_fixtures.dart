import 'package:clock/clock.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/domain/routine/routine_block.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';
import 'package:flowstate/domain/tasks/task.dart';

const String testDeviceId = 'test-device';
final Clock fixedClock = Clock.fixed(DateTime(2026, 9, 30, 9));

String testUuid(int number) {
  return '00000000-0000-4000-8000-${number.toString().padLeft(12, '0')}';
}

RecordMetadata testMetadata(int number, {DateTime? deletedAt}) {
  return RecordMetadata(
    id: testUuid(number),
    createdAt: DateTime.utc(2026, 9, 1),
    updatedAt: DateTime.utc(2026, 9, 1),
    deletedAt: deletedAt,
    deviceId: testDeviceId,
  );
}

LocalDate testDate(int year, int month, int day) => LocalDate(year, month, day);

Habit testHabit({
  int id = 1,
  Recurrence? recurrence,
  bool essential = true,
  String categoryId = HabitCategoryId.focus,
}) {
  return Habit(
    metadata: testMetadata(id),
    name: 'Hábito $id',
    iconId: 'icon_$id',
    categoryId: categoryId,
    recurrence: recurrence ?? Recurrence.daily(),
    isEssential: essential,
  );
}

HabitLog testHabitLog({
  required int id,
  required Habit habit,
  required LocalDate date,
  required HabitLogLevel level,
  DateTime? deletedAt,
}) {
  return HabitLog(
    metadata: testMetadata(id, deletedAt: deletedAt),
    habitId: habit.id,
    logicalDate: date,
    level: level,
  );
}

Task testTask({
  int id = 10,
  String? title,
  LocalDate? dueDate,
  int? dueMinute,
  int? estimatedMinutes,
  TaskPriority priority = TaskPriority.normal,
  Recurrence? recurrence,
}) {
  return Task(
    metadata: testMetadata(id),
    title: title ?? 'Tarefa $id',
    dueDate: dueDate,
    dueMinute: dueMinute,
    estimatedMinutes: estimatedMinutes,
    priority: priority,
    recurrence: recurrence,
  );
}

RoutineBlock testBlock({
  int id = 20,
  String title = 'Bloco',
  int startMinute = 600,
  int durationMinutes = 60,
  Set<int> weekdays = const <int>{1, 2, 3, 4, 5, 6, 7},
}) {
  return RoutineBlock(
    metadata: testMetadata(id),
    title: title,
    startMinute: startMinute,
    durationMinutes: durationMinutes,
    categoryId: HabitCategoryId.focus,
    weekdays: weekdays,
  );
}
