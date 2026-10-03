import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flowstate/data/storage_paths.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

mixin AuditedTable on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text()();
}

class Habits extends Table with AuditedTable {
  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  TextColumn get name => text()();
  TextColumn get iconId => text()();
  TextColumn get categoryId => text()();
  TextColumn get recurrenceJson => text()();
  TextColumn get cue => text().nullable()();
  TextColumn get minimumVersion => text().nullable()();
  BoolColumn get isEssential =>
      boolean().withDefault(const Constant<bool>(false))();
  IntColumn get reminderMinute => integer().nullable()();
}

class HabitLogs extends Table with AuditedTable {
  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  TextColumn get habitId => text().references(Habits, #id)();
  TextColumn get logicalDate => text()();
  TextColumn get levelId => text()();
  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{habitId, logicalDate},
  ];
}

class Tasks extends Table with AuditedTable {
  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  IntColumn get dueMinute => integer().nullable()();
  IntColumn get estimatedMinutes => integer().nullable()();
  TextColumn get priorityId => text()();
  TextColumn get projectId => text().nullable()();
  TextColumn get recurrenceJson => text().nullable()();
}

class TaskCompletions extends Table with AuditedTable {
  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get occurrenceDate => text()();
  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{taskId, occurrenceDate},
  ];
}

class RoutineBlocks extends Table with AuditedTable {
  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  TextColumn get title => text()();
  IntColumn get startMinute => integer()();
  IntColumn get durationMinutes => integer()();
  TextColumn get categoryId => text()();
  TextColumn get weekdaysJson => text()();
}

class FocusSessions extends Table with AuditedTable {
  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  TextColumn get taskId => text().nullable().references(Tasks, #id)();
}

class XpEvents extends Table with AuditedTable {
  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  TextColumn get actionId => text()();
  TextColumn get sourceId => text()();
  TextColumn get logicalDate => text()();
  IntColumn get units => integer()();
  IntColumn get xp => integer()();
  DateTimeColumn get reversedAt => dateTime().nullable()();
  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{actionId, sourceId, logicalDate},
  ];
}

class AppPreferences extends Table with AuditedTable {
  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  TextColumn get key => text().unique()();
  TextColumn get valueJson => text()();
}

@DriftDatabase(
  tables: <Type>[
    Habits,
    HabitLogs,
    Tasks,
    TaskCompletions,
    RoutineBlocks,
    FocusSessions,
    XpEvents,
    AppPreferences,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open()
    : super(
        driftDatabase(
          name: 'flow_state',
          native: DriftNativeOptions(
            databasePath: () async {
              final Directory root = await appDataDirectory();
              return p.join(root.path, 'flow_state.sqlite');
            },
          ),
        ),
      );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async => migrator.createAll(),
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 1 && to >= 1) await migrator.createAll();
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      final List<QueryRow> rows = await customSelect('PRAGMA quick_check')
          .get();
      final bool healthy =
          rows.length == 1 && rows.single.data.values.single == 'ok';
      if (!healthy) throw const DatabaseIntegrityException();
    },
  );

  Future<List<String>> integrityCheck() async {
    final List<QueryRow> rows = await customSelect('PRAGMA quick_check').get();
    return List<String>.unmodifiable(
      rows.map((QueryRow row) => row.data.values.single.toString()),
    );
  }

  Future<void> replaceFromSnapshot(
    String snapshotPath, {
    Future<void> Function()? afterClear,
  }) async {
    await customStatement('ATTACH DATABASE ? AS restored_snapshot', <Object>[
      snapshotPath,
    ]);
    try {
      await transaction(() async {
        // Delete dependent rows before their referenced records.
        await customStatement('DELETE FROM task_completions');
        await customStatement('DELETE FROM focus_sessions');
        await customStatement('DELETE FROM habit_logs');
        await customStatement('DELETE FROM xp_events');
        await customStatement('DELETE FROM routine_blocks');
        await customStatement('DELETE FROM app_preferences');
        await customStatement('DELETE FROM habits');
        await customStatement('DELETE FROM tasks');
        await afterClear?.call();
        // Insert referenced rows before dependent rows.
        for (final String table in const <String>[
          'habits',
          'tasks',
          'routine_blocks',
          'app_preferences',
          'habit_logs',
          'task_completions',
          'focus_sessions',
          'xp_events',
        ]) {
          await customStatement(
            'INSERT INTO main."$table" SELECT * FROM restored_snapshot."$table"',
          );
        }
      });
    } finally {
      await customStatement('DETACH DATABASE restored_snapshot');
    }
  }
}

final class DatabaseIntegrityException implements Exception {
  const DatabaseIntegrityException();

  @override
  String toString() => 'Database integrity check failed.';
}

String encodeStableJson(Object? value) => jsonEncode(value);
