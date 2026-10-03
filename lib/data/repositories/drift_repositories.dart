import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/data/database/app_database.dart' as db;
import 'package:flowstate/domain/focus/focus_session.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/domain/repositories/focus_repository.dart';
import 'package:flowstate/domain/repositories/habit_repository.dart';
import 'package:flowstate/domain/repositories/routine_repository.dart';
import 'package:flowstate/domain/repositories/task_repository.dart';
import 'package:flowstate/domain/repositories/xp_repository.dart';
import 'package:flowstate/domain/routine/routine_block.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';
import 'package:flowstate/domain/tasks/task.dart';

final class DriftHabitRepository implements HabitRepository {
  const DriftHabitRepository(this.database);

  final db.AppDatabase database;

  @override
  Future<List<Habit>> getActiveHabits() async {
    final List<Habit> records =
        await (database.select(database.habits)
              ..where((db.Habits row) => row.deletedAt.isNull())
              ..orderBy(<OrderingTerm Function(db.Habits)>[
                (db.Habits row) => OrderingTerm.asc(row.createdAt),
                (db.Habits row) => OrderingTerm.asc(row.id),
              ]))
            .map(_habitFromRow)
            .get();
    return List<Habit>.unmodifiable(records);
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    await database
        .into(database.habits)
        .insertOnConflictUpdate(
          db.HabitsCompanion.insert(
            id: habit.id,
            createdAt: habit.metadata.createdAt,
            updatedAt: habit.metadata.updatedAt,
            deletedAt: Value<DateTime?>(habit.metadata.deletedAt),
            deviceId: habit.metadata.deviceId,
            name: habit.name,
            iconId: habit.iconId,
            categoryId: habit.categoryId,
            recurrenceJson: jsonEncode(_recurrenceToJson(habit.recurrence)),
            cue: Value<String?>(habit.cue),
            minimumVersion: Value<String?>(habit.minimumVersion),
            isEssential: Value<bool>(habit.isEssential),
            reminderMinute: Value<int?>(habit.reminderMinute),
          ),
        );
  }

  @override
  Future<List<HabitLog>> getHabitLogs({
    required LocalDate from,
    required LocalDate through,
  }) async {
    final List<HabitLog> records =
        await (database.select(database.habitLogs)
              ..where(
                (db.HabitLogs row) =>
                    row.deletedAt.isNull() &
                    row.logicalDate.isBetweenValues(
                      from.toString(),
                      through.toString(),
                    ),
              )
              ..orderBy(<OrderingTerm Function(db.HabitLogs)>[
                (db.HabitLogs row) => OrderingTerm.asc(row.logicalDate),
                (db.HabitLogs row) => OrderingTerm.asc(row.id),
              ]))
            .map(_habitLogFromRow)
            .get();
    return List<HabitLog>.unmodifiable(records);
  }

  @override
  Future<void> saveHabitLog(HabitLog log) async {
    final db.HabitLogsCompanion entry = db.HabitLogsCompanion.insert(
      id: log.metadata.id,
      createdAt: log.metadata.createdAt,
      updatedAt: log.metadata.updatedAt,
      deletedAt: Value<DateTime?>(log.metadata.deletedAt),
      deviceId: log.metadata.deviceId,
      habitId: log.habitId,
      logicalDate: log.logicalDate.toString(),
      levelId: _habitLogLevelId(log.level),
    );
    await database
        .into(database.habitLogs)
        .insert(
          entry,
          onConflict: DoUpdate<db.$HabitLogsTable, db.HabitLog>(
            (_) => entry,
            target: <Column<Object>>[
              database.habitLogs.habitId,
              database.habitLogs.logicalDate,
            ],
          ),
        );
  }
}

final class DriftTaskRepository implements TaskRepository {
  const DriftTaskRepository(this.database);

  final db.AppDatabase database;

  @override
  Future<List<Task>> getActiveTasks() async {
    final List<Task> records =
        await (database.select(database.tasks)
              ..where((db.Tasks row) => row.deletedAt.isNull())
              ..orderBy(<OrderingTerm Function(db.Tasks)>[
                (db.Tasks row) => OrderingTerm.asc(row.createdAt),
                (db.Tasks row) => OrderingTerm.asc(row.id),
              ]))
            .map(_taskFromRow)
            .get();
    return List<Task>.unmodifiable(records);
  }

  @override
  Future<void> saveTask(Task task) async {
    await database
        .into(database.tasks)
        .insertOnConflictUpdate(
          db.TasksCompanion.insert(
            id: task.id,
            createdAt: task.metadata.createdAt,
            updatedAt: task.metadata.updatedAt,
            deletedAt: Value<DateTime?>(task.metadata.deletedAt),
            deviceId: task.metadata.deviceId,
            title: task.title,
            notes: Value<String?>(task.notes),
            dueDate: Value<String?>(task.dueDate?.toString()),
            dueMinute: Value<int?>(task.dueMinute),
            estimatedMinutes: Value<int?>(task.estimatedMinutes),
            priorityId: _priorityId(task.priority),
            projectId: Value<String?>(task.projectId),
            recurrenceJson: Value<String?>(
              _encodeOptionalRecurrence(task.recurrence),
            ),
          ),
        );
  }

  @override
  Future<List<TaskCompletion>> getCompletions({
    required LocalDate from,
    required LocalDate through,
  }) async {
    final List<TaskCompletion> records =
        await (database.select(database.taskCompletions)
              ..where(
                (db.TaskCompletions row) =>
                    row.deletedAt.isNull() &
                    row.occurrenceDate.isBetweenValues(
                      from.toString(),
                      through.toString(),
                    ),
              )
              ..orderBy(<OrderingTerm Function(db.TaskCompletions)>[
                (db.TaskCompletions row) =>
                    OrderingTerm.asc(row.occurrenceDate),
                (db.TaskCompletions row) => OrderingTerm.asc(row.id),
              ]))
            .map(_taskCompletionFromRow)
            .get();
    return List<TaskCompletion>.unmodifiable(records);
  }

  @override
  Future<void> saveCompletion(TaskCompletion completion) async {
    final db.TaskCompletionsCompanion entry =
        db.TaskCompletionsCompanion.insert(
          id: completion.metadata.id,
          createdAt: completion.metadata.createdAt,
          updatedAt: completion.metadata.updatedAt,
          deletedAt: Value<DateTime?>(completion.metadata.deletedAt),
          deviceId: completion.metadata.deviceId,
          taskId: completion.taskId,
          occurrenceDate: completion.occurrenceDate.toString(),
        );
    await database
        .into(database.taskCompletions)
        .insert(
          entry,
          onConflict: DoUpdate<db.$TaskCompletionsTable, db.TaskCompletion>(
            (_) => entry,
            target: <Column<Object>>[
              database.taskCompletions.taskId,
              database.taskCompletions.occurrenceDate,
            ],
          ),
        );
  }
}

final class DriftRoutineRepository implements RoutineRepository {
  const DriftRoutineRepository(this.database);

  final db.AppDatabase database;

  @override
  Future<List<RoutineBlock>> getActiveBlocks() async {
    final List<RoutineBlock> records =
        await (database.select(database.routineBlocks)
              ..where((db.RoutineBlocks row) => row.deletedAt.isNull())
              ..orderBy(<OrderingTerm Function(db.RoutineBlocks)>[
                (db.RoutineBlocks row) => OrderingTerm.asc(row.startMinute),
                (db.RoutineBlocks row) => OrderingTerm.asc(row.id),
              ]))
            .map(_routineFromRow)
            .get();
    return List<RoutineBlock>.unmodifiable(records);
  }

  @override
  Future<void> saveBlock(RoutineBlock block) async {
    await database
        .into(database.routineBlocks)
        .insertOnConflictUpdate(
          db.RoutineBlocksCompanion.insert(
            id: block.id,
            createdAt: block.metadata.createdAt,
            updatedAt: block.metadata.updatedAt,
            deletedAt: Value<DateTime?>(block.metadata.deletedAt),
            deviceId: block.metadata.deviceId,
            title: block.title,
            startMinute: block.startMinute,
            durationMinutes: block.durationMinutes,
            categoryId: block.categoryId,
            weekdaysJson: jsonEncode(block.weekdays.toList()..sort()),
          ),
        );
  }
}

final class DriftFocusRepository implements FocusRepository {
  const DriftFocusRepository(this.database);

  final db.AppDatabase database;

  @override
  Future<List<FocusSession>> getSessions() async {
    final List<FocusSession> records =
        await (database.select(database.focusSessions)
              ..where((db.FocusSessions row) => row.deletedAt.isNull())
              ..orderBy(<OrderingTerm Function(db.FocusSessions)>[
                (db.FocusSessions row) => OrderingTerm.asc(row.startedAt),
                (db.FocusSessions row) => OrderingTerm.asc(row.id),
              ]))
            .map(_focusFromRow)
            .get();
    return List<FocusSession>.unmodifiable(records);
  }

  @override
  Future<void> saveSession(FocusSession session) async {
    await database
        .into(database.focusSessions)
        .insertOnConflictUpdate(
          db.FocusSessionsCompanion.insert(
            id: session.metadata.id,
            createdAt: session.metadata.createdAt,
            updatedAt: session.metadata.updatedAt,
            deletedAt: Value<DateTime?>(session.metadata.deletedAt),
            deviceId: session.metadata.deviceId,
            startedAt: session.startedAt,
            endAt: session.endAt,
            taskId: Value<String?>(session.taskId),
          ),
        );
  }
}

final class DriftXpRepository implements XpRepository {
  const DriftXpRepository(this.database);

  final db.AppDatabase database;

  @override
  Future<List<XpEvent>> getLedger({LocalDate? through}) async {
    final SimpleSelectStatement<db.$XpEventsTable, db.XpEvent> query =
        database.select(database.xpEvents)..where(
          (db.XpEvents row) => row.logicalDate.isSmallerOrEqualValue(
            through?.toString() ?? '9999-12-31',
          ),
        );
    final List<XpEvent> records = await query.map(_xpFromRow).get();
    return List<XpEvent>.unmodifiable(records);
  }

  @override
  Future<bool> insertIfAbsent(XpEvent event) async {
    return database.transaction(() async {
      final db.XpEvent? previous =
          await (database.select(database.xpEvents)..where(
                (db.XpEvents row) =>
                    row.actionId.equals(event.action.id) &
                    row.sourceId.equals(event.sourceId) &
                    row.logicalDate.equals(event.logicalDate.toString()),
              ))
              .getSingleOrNull();
      if (previous != null) return false;
      await database
          .into(database.xpEvents)
          .insert(
            db.XpEventsCompanion.insert(
              id: event.metadata.id,
              createdAt: event.metadata.createdAt,
              updatedAt: event.metadata.updatedAt,
              deletedAt: Value<DateTime?>(event.metadata.deletedAt),
              deviceId: event.metadata.deviceId,
              actionId: event.action.id,
              sourceId: event.sourceId,
              logicalDate: event.logicalDate.toString(),
              units: event.units,
              xp: event.xp,
              reversedAt: Value<DateTime?>(event.reversedAt),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    });
  }

  @override
  Future<void> reverse(XpEvent event) async {
    final DateTime? reversedAt = event.reversedAt;
    if (reversedAt == null) {
      throw ArgumentError.value(
        event,
        'event',
        'Pass a reversed ledger event.',
      );
    }
    await (database.update(
      database.xpEvents,
    )..where((db.XpEvents row) => row.id.equals(event.metadata.id))).write(
      db.XpEventsCompanion(
        updatedAt: Value<DateTime>(event.metadata.updatedAt),
        reversedAt: Value<DateTime?>(reversedAt),
      ),
    );
  }
}

Habit _habitFromRow(db.Habit row) => Habit(
  metadata: _metadata(
    id: row.id,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
    deviceId: row.deviceId,
  ),
  name: row.name,
  iconId: row.iconId,
  categoryId: row.categoryId,
  recurrence: _recurrenceFromJson(jsonDecode(row.recurrenceJson)),
  cue: row.cue,
  minimumVersion: row.minimumVersion,
  isEssential: row.isEssential,
  reminderMinute: row.reminderMinute,
);

HabitLog _habitLogFromRow(db.HabitLog row) => HabitLog(
  metadata: _metadata(
    id: row.id,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
    deviceId: row.deviceId,
  ),
  habitId: row.habitId,
  logicalDate: _date(row.logicalDate),
  level: _habitLogLevel(row.levelId),
);

Task _taskFromRow(db.Task row) => Task(
  metadata: _metadata(
    id: row.id,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
    deviceId: row.deviceId,
  ),
  title: row.title,
  notes: row.notes,
  dueDate: _optionalDate(row.dueDate),
  dueMinute: row.dueMinute,
  estimatedMinutes: row.estimatedMinutes,
  priority: _priority(row.priorityId),
  projectId: row.projectId,
  recurrence: _optionalRecurrence(row.recurrenceJson),
);

TaskCompletion _taskCompletionFromRow(db.TaskCompletion row) => TaskCompletion(
  metadata: _metadata(
    id: row.id,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
    deviceId: row.deviceId,
  ),
  taskId: row.taskId,
  occurrenceDate: _date(row.occurrenceDate),
);

RoutineBlock _routineFromRow(db.RoutineBlock row) {
  final Object? decoded = jsonDecode(row.weekdaysJson);
  if (decoded is! List<Object?> || decoded.any((Object? day) => day is! int)) {
    throw const FormatException('Stored routine weekdays are invalid.');
  }
  return RoutineBlock(
    metadata: _metadata(
      id: row.id,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      deviceId: row.deviceId,
    ),
    title: row.title,
    startMinute: row.startMinute,
    durationMinutes: row.durationMinutes,
    categoryId: row.categoryId,
    weekdays: decoded.map((Object? value) => _requiredInt(value)).toSet(),
  );
}

FocusSession _focusFromRow(db.FocusSession row) => FocusSession(
  metadata: _metadata(
    id: row.id,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
    deviceId: row.deviceId,
  ),
  startedAt: row.startedAt.toUtc(),
  endAt: row.endAt.toUtc(),
  taskId: row.taskId,
);

XpEvent _xpFromRow(db.XpEvent row) => XpEvent(
  metadata: _metadata(
    id: row.id,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
    deviceId: row.deviceId,
  ),
  action: _xpAction(row.actionId),
  sourceId: row.sourceId,
  logicalDate: _date(row.logicalDate),
  units: row.units,
  xp: row.xp,
  reversedAt: row.reversedAt?.toUtc(),
);

RecordMetadata _metadata({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required DateTime? deletedAt,
  required String deviceId,
}) => RecordMetadata(
  id: id,
  createdAt: createdAt.toUtc(),
  updatedAt: updatedAt.toUtc(),
  deletedAt: deletedAt?.toUtc(),
  deviceId: deviceId,
);

LocalDate _date(String date) {
  final List<String> parts = date.split('-');
  if (parts.length != 3) throw const FormatException('Stored date is invalid.');
  return LocalDate(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

LocalDate? _optionalDate(String? date) => date == null ? null : _date(date);

Recurrence? _optionalRecurrence(String? encoded) =>
    encoded == null ? null : _recurrenceFromJson(jsonDecode(encoded));

String? _encodeOptionalRecurrence(Recurrence? recurrence) =>
    recurrence == null ? null : jsonEncode(_recurrenceToJson(recurrence));

Map<String, Object?> _recurrenceToJson(Recurrence recurrence) =>
    <String, Object?>{
      'kind': _recurrenceKindId(recurrence.kind),
      'weekdays': recurrence.weekdays.toList()..sort(),
      'intervalDays': recurrence.intervalDays,
      'anchorDate': recurrence.anchorDate?.toString(),
      'weeklyTarget': recurrence.weeklyTarget,
      'monthlyDay': recurrence.monthlyDay,
    };

String _recurrenceKindId(RecurrenceKind kind) => switch (kind) {
  RecurrenceKind.daily => 'daily',
  RecurrenceKind.weekdays => 'weekdays',
  RecurrenceKind.everyNDays => 'every_n_days',
  RecurrenceKind.weeklyTarget => 'weekly_target',
  RecurrenceKind.monthlyDay => 'monthly_day',
};

Recurrence _recurrenceFromJson(Object? value) {
  if (value is! Map<String, Object?>) {
    throw const FormatException('Stored recurrence is invalid.');
  }
  final Object? kindValue = value['kind'];
  if (kindValue is! String) {
    throw const FormatException('Recurrence kind is missing.');
  }
  final List<int> weekdays = _integerList(value['weekdays']);
  switch (kindValue) {
    case 'daily':
      return Recurrence.daily();
    case 'weekdays':
      return Recurrence.weekdays(weekdays.toSet());
    case 'every_n_days':
      return Recurrence.everyNDays(
        interval: _requiredInt(value['intervalDays']),
        anchor: _date(_requiredString(value['anchorDate'])),
      );
    case 'weekly_target':
      return Recurrence.weeklyTarget(_requiredInt(value['weeklyTarget']));
    case 'monthly_day':
      return Recurrence.monthlyDay(_requiredInt(value['monthlyDay']));
    default:
      throw const FormatException('Unknown recurrence kind.');
  }
}

List<int> _integerList(Object? value) {
  if (value is! List<Object?> || value.any((Object? item) => item is! int)) {
    throw const FormatException('Stored integer list is invalid.');
  }
  return value.cast<int>();
}

int _requiredInt(Object? value) {
  if (value is int) return value;
  throw const FormatException('Stored recurrence number is invalid.');
}

String _requiredString(Object? value) {
  if (value is String) return value;
  throw const FormatException('Stored recurrence date is invalid.');
}

String _habitLogLevelId(HabitLogLevel level) => switch (level) {
  HabitLogLevel.full => 'full',
  HabitLogLevel.minimum => 'minimum',
  HabitLogLevel.skipped => 'skipped',
};

HabitLogLevel _habitLogLevel(String value) => switch (value) {
  'full' => HabitLogLevel.full,
  'minimum' => HabitLogLevel.minimum,
  'skipped' => HabitLogLevel.skipped,
  _ => throw const FormatException('Unknown habit log level.'),
};

String _priorityId(TaskPriority priority) => switch (priority) {
  TaskPriority.low => 'low',
  TaskPriority.normal => 'normal',
  TaskPriority.high => 'high',
};

TaskPriority _priority(String value) => switch (value) {
  'low' => TaskPriority.low,
  'normal' => TaskPriority.normal,
  'high' => TaskPriority.high,
  _ => throw const FormatException('Unknown task priority.'),
};

XpAction _xpAction(String value) => switch (value) {
  'habit_full' => XpAction.habitFull,
  'habit_minimum' => XpAction.habitMinimum,
  'task_completed' => XpAction.task,
  'routine_block_completed' => XpAction.routineBlock,
  'focus_session_completed' => XpAction.focusSession,
  'workout_completed' => XpAction.workout,
  'energy_checkin' => XpAction.energyCheckin,
  _ => throw const FormatException('Unknown XP action.'),
};
