import 'dart:io';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flowstate/data/backup/backup_service.dart';
import 'package:flowstate/data/backup/automatic_backup_key_store.dart';
import 'package:flowstate/data/database/app_database.dart' as db;
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  final Clock testClock = Clock.fixed(DateTime.utc(2026, 10, 3, 12));
  const String password = 'correct-horse-battery-staple';
  late bool previousDriftWarningSetting;

  setUpAll(() {
    previousDriftWarningSetting =
        driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });
  tearDownAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases =
        previousDriftWarningSetting;
  });

  test('schema v1 creates all tables and passes quick_check', () async {
    final db.AppDatabase database = db.AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    expect(await database.integrityCheck(), <String>['ok']);
    final List<QueryRow> tables = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    expect(
      tables.map((QueryRow row) => row.data['name']),
      containsAll(<String>[
        'habits',
        'habit_logs',
        'tasks',
        'task_completions',
        'routine_blocks',
        'focus_sessions',
        'xp_events',
        'app_preferences',
      ]),
    );
  });

  test('empty version zero database upgrades to schema v1', () async {
    final Directory root = await Directory.systemTemp.createTemp('flow-v0-');
    addTearDown(() => root.delete(recursive: true));
    final File path = File('${root.path}/version-zero.sqlite');
    final sqlite.Database empty = sqlite.sqlite3.open(path.path);
    empty.execute('PRAGMA user_version = 0');
    empty.close();

    final db.AppDatabase database = db.AppDatabase(
      NativeDatabase(File(path.path)),
    );
    addTearDown(database.close);

    expect(await database.integrityCheck(), <String>['ok']);
    final QueryRow version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.data.values.single, 1);
    final List<db.Habit> habits = await database.select(database.habits).get();
    expect(habits, isEmpty);
  });

  test('schema v1 fixture opens without losing existing records', () async {
    final Directory root = await Directory.systemTemp.createTemp('flow-v1-');
    addTearDown(() => root.delete(recursive: true));
    final File fixture = File('test/fixtures/schema_v1.sql');
    final File path = File('${root.path}/fixture.sqlite');
    final sqlite.Database seeded = sqlite.sqlite3.open(path.path);
    seeded.execute(await fixture.readAsString());
    seeded.close();

    final db.AppDatabase database = db.AppDatabase(
      NativeDatabase(File(path.path)),
    );
    addTearDown(database.close);
    expect(await database.integrityCheck(), <String>['ok']);
    final List<db.Habit> habits = await database.select(database.habits).get();
    expect(habits.map((db.Habit habit) => habit.name), <String>['Leitura']);
  });

  test(
    'corrupt database is reported and never deleted automatically',
    () async {
      final Directory root = await Directory.systemTemp.createTemp(
        'flow-corrupt-',
      );
      addTearDown(() => root.delete(recursive: true));
      final File path = File('${root.path}/corrupt.sqlite');
      final db.AppDatabase original = db.AppDatabase(NativeDatabase(path));
      expect(await original.integrityCheck(), <String>['ok']);
      await original.close();
      final List<int> corruptBytes = List<int>.generate(
        128,
        (int index) => (index * 37) & 0xff,
        growable: false,
      );
      await path.writeAsBytes(corruptBytes, flush: true);

      final db.AppDatabase damaged = db.AppDatabase(NativeDatabase(path));
      await expectLater(damaged.integrityCheck(), throwsA(anything));
      await damaged.close();
      expect(await path.readAsBytes(), corruptBytes);
    },
  );

  test('backup is encrypted, previewed and rejected after tampering', () async {
    final Directory root = await Directory.systemTemp.createTemp('flow-test-');
    addTearDown(() => root.delete(recursive: true));
    final Directory output = Directory('${root.path}/out');
    final db.AppDatabase database = db.AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.habits)
        .insert(
          db.HabitsCompanion.insert(
            id: '00000000-0000-4000-8000-000000000001',
            createdAt: testClock.now().toUtc(),
            updatedAt: testClock.now().toUtc(),
            deviceId: 'test-device',
            name: 'Leitura',
            iconId: 'book',
            categoryId: 'mind',
            recurrenceJson: '{"kind":"daily"}',
          ),
        );
    final BackupService service = BackupService(clock: testClock);
    final File backup = await service.createBackup(
      database: database,
      password: password,
      destination: output,
      appVersion: '1.0.0',
    );

    final String contents = await backup.readAsString();
    expect(contents, contains('aes-256-gcm'));
    expect(contents, isNot(contains('Leitura')));
    final PreparedRestore prepared = await service.prepareRestore(
      backup: backup,
      password: password,
      temporaryDirectory: Directory('${root.path}/prepared'),
    );
    addTearDown(() => File(prepared.snapshotPath).delete());
    expect(prepared.preview.metadata.schemaVersion, 1);
    expect(prepared.preview.counts['habits'], 1);

    final File tampered = File('${root.path}/tampered.flowbackup');
    await tampered.writeAsString(
      contents.replaceFirst('aes-256-gcm', 'aes-256-gcx'),
    );
    await expectLater(
      service.prepareRestore(
        backup: tampered,
        password: password,
        temporaryDirectory: Directory('${root.path}/tampered-work'),
      ),
      throwsA(isA<BackupException>()),
    );
  });

  test(
    'restore copy leaves the live database unchanged if transaction fails',
    () async {
      final Directory root = await Directory.systemTemp.createTemp(
        'flow-test-',
      );
      addTearDown(() => root.delete(recursive: true));
      final db.AppDatabase source = db.AppDatabase(NativeDatabase.memory());
      final db.AppDatabase current = db.AppDatabase(NativeDatabase.memory());
      addTearDown(source.close);
      addTearDown(current.close);
      await DriftHabitRepository(source).saveHabit(_habit(id: 2, name: 'Novo'));
      await DriftHabitRepository(current)
          .saveHabit(_habit(id: 3, name: 'Atual'));
      final BackupService service = BackupService(clock: testClock);
      final File backup = await service.createBackup(
        database: source,
        password: password,
        destination: Directory('${root.path}/out'),
        appVersion: '1.0.0',
      );
      final PreparedRestore prepared = await service.prepareRestore(
        backup: backup,
        password: password,
        temporaryDirectory: Directory('${root.path}/prepared'),
      );
      addTearDown(() => File(prepared.snapshotPath).delete());

      await expectLater(
        current.replaceFromSnapshot(
          prepared.snapshotPath,
          afterClear: () async => throw StateError('injected failure'),
        ),
        throwsStateError,
      );
      final List<db.Habit> remaining = await current
          .select(current.habits)
          .get();
      expect(remaining.map((db.Habit row) => row.name), <String>['Atual']);

      await current.replaceFromSnapshot(prepared.snapshotPath);
      final List<db.Habit> restored = await current
          .select(current.habits)
          .get();
      expect(restored.map((db.Habit row) => row.name), <String>['Novo']);
    },
  );

  test('automatic backups keep the newest five files', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'flow-rotation-',
    );
    addTearDown(() => directory.delete(recursive: true));
    for (int index = 0; index < 7; index++) {
      final File file = File('${directory.path}/$index.flowbackup');
      await file.writeAsString('encrypted');
      await file.setLastModified(DateTime.utc(2026, 1, 1 + index));
    }

    final List<File> retained = await rotateAutomaticBackups(directory);

    expect(retained, hasLength(5));
    expect(await File('${directory.path}/0.flowbackup').exists(), isFalse);
    expect(await File('${directory.path}/6.flowbackup').exists(), isTrue);
  });

  test('automatic backup provisions a protected install key once', () async {
    final Directory root = await Directory.systemTemp.createTemp('flow-auto-');
    addTearDown(() => root.delete(recursive: true));
    final _MemoryKeyStore keys = _MemoryKeyStore();
    final db.AppDatabase database = db.AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final BackupService service = BackupService(
      clock: testClock,
      automaticKeyStore: keys,
    );

    final File backup = await service.createAutomaticBackup(
      database: database,
      appVersion: '1.0.0',
      destination: root,
    );

    expect(keys.value, isNot(null));
    expect(await backup.exists(), isTrue);
    expect(backup.path, endsWith('.flowbackup'));
  });
}

final class _MemoryKeyStore implements AutomaticBackupKeyStore {
  String? value;

  @override
  Future<String?> readKey() async => value;

  @override
  Future<void> writeKey(String key) async {
    value = key;
  }
}

Habit _habit({required int id, required String name}) {
  final String uuid =
      '00000000-0000-4000-8000-${id.toString().padLeft(12, '0')}';
  final DateTime now = DateTime.utc(2026, 10, 3);
  return Habit(
    metadata: RecordMetadata(
      id: uuid,
      createdAt: now,
      updatedAt: now,
      deviceId: 'test-device',
    ),
    name: name,
    iconId: 'book',
    categoryId: 'mind',
    recurrence: Recurrence.daily(),
  );
}
