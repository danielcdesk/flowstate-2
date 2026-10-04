import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/data/backup/automatic_backup_key_store.dart';
import 'package:flowstate/data/database/app_database.dart';
import 'package:flowstate/data/storage_paths.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

const int maxBackupBytes = 256 * 1024 * 1024;
const int _formatVersion = 1;
const int _schemaVersion = 2;
const int _argonMemoryKiB = 19 * 1024;
const int _argonIterations = 2;
const int _argonParallelism = 1;
final AesGcm _cipher = AesGcm.with256bits();
final Argon2id _kdf = Argon2id(
  memory: _argonMemoryKiB,
  iterations: _argonIterations,
  parallelism: _argonParallelism,
  hashLength: 32,
);
const List<String> _tableNames = <String>[
  'habits',
  'habit_logs',
  'tasks',
  'task_completions',
  'routine_blocks',
  'focus_sessions',
  'workout_plans',
  'workout_sessions',
  'workout_sets',
  'xp_events',
  'app_preferences',
];
const Map<String, List<String>> _tableColumns = <String, List<String>>{
  'habits': <String>[
    'id',
    'created_at',
    'updated_at',
    'deleted_at',
    'device_id',
    'name',
    'icon_id',
    'category_id',
    'recurrence_json',
    'cue',
    'minimum_version',
    'is_essential',
    'reminder_minute',
  ],
  'habit_logs': <String>[
    'id',
    'created_at',
    'updated_at',
    'deleted_at',
    'device_id',
    'habit_id',
    'logical_date',
    'level_id',
  ],
  'tasks': <String>[
    'id',
    'created_at',
    'updated_at',
    'deleted_at',
    'device_id',
    'title',
    'notes',
    'due_date',
    'due_minute',
    'estimated_minutes',
    'priority_id',
    'project_id',
    'recurrence_json',
  ],
  'task_completions': <String>[
    'id',
    'created_at',
    'updated_at',
    'deleted_at',
    'device_id',
    'task_id',
    'occurrence_date',
  ],
  'routine_blocks': <String>[
    'id',
    'created_at',
    'updated_at',
    'deleted_at',
    'device_id',
    'title',
    'start_minute',
    'duration_minutes',
    'category_id',
    'weekdays_json',
  ],
  'focus_sessions': <String>[
    'id',
    'created_at',
    'updated_at',
    'deleted_at',
    'device_id',
    'started_at',
    'end_at',
    'task_id',
  ],
  'workout_plans': <String>[
    'id',
    'created_at',
    'updated_at',
    'deleted_at',
    'device_id',
    'title',
    'exercises_json',
  ],
  'workout_sessions': <String>[
    'id',
    'created_at',
    'updated_at',
    'deleted_at',
    'device_id',
    'plan_id',
    'started_at',
    'ended_at',
  ],
  'workout_sets': <String>[
    'id',
    'created_at',
    'updated_at',
    'deleted_at',
    'device_id',
    'session_id',
    'exercise_id',
    'set_index',
    'repetitions',
    'load_kg',
    'rest_seconds',
  ],
  'xp_events': <String>[
    'id',
    'created_at',
    'updated_at',
    'deleted_at',
    'device_id',
    'action_id',
    'source_id',
    'logical_date',
    'units',
    'xp',
    'reversed_at',
  ],
  'app_preferences': <String>[
    'id',
    'created_at',
    'updated_at',
    'deleted_at',
    'device_id',
    'key',
    'value_json',
  ],
};

final class BackupMetadata {
  const BackupMetadata({
    required this.appVersion,
    required this.schemaVersion,
    required this.createdAt,
    required this.sha256,
  });

  final String appVersion;
  final int schemaVersion;
  final DateTime createdAt;
  final String sha256;
}

final class RestorePreview {
  const RestorePreview({
    required this.metadata,
    required this.counts,
    required this.startDate,
    required this.endDate,
  });

  final BackupMetadata metadata;
  final Map<String, int> counts;
  final LocalDate? startDate;
  final LocalDate? endDate;
}

final class PreparedRestore {
  const PreparedRestore._({required this.preview, required this.snapshotPath});

  final RestorePreview preview;
  final String snapshotPath;

  Future<void> dispose() async {
    final File snapshot = File(snapshotPath);
    if (await snapshot.exists()) {
      await snapshot.delete();
    }
  }
}

final class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class BackupService {
  BackupService({
    required this.clock,
    AutomaticBackupKeyStore? automaticKeyStore,
  }) : _automaticKeyStore =
           automaticKeyStore ?? DeviceProtectedBackupKeyStore();

  final Clock clock;
  final AutomaticBackupKeyStore _automaticKeyStore;
  Future<File> createBackup({
    required AppDatabase database,
    required String password,
    required Directory destination,
    required String appVersion,
  }) async {
    _validatePassword(password);
    await destination.create(recursive: true);
    final Directory temporary = await Directory.systemTemp.createTemp(
      'flow-backup-',
    );
    try {
      final File snapshot = File(
        '${temporary.path}${Platform.pathSeparator}snapshot.sqlite',
      );
      await database.customStatement('VACUUM INTO ?', <Object>[snapshot.path]);
      final int snapshotLength = await snapshot.length();
      if (snapshotLength > maxBackupBytes) {
        throw const BackupException('Backup exceeds the supported size.');
      }
      final Uint8List snapshotBytes = await snapshot.readAsBytes();
      final DateTime createdAt = clock.now().toUtc();
      final String digest = _hex(await Sha256().hash(snapshotBytes));
      final Map<String, Object> payload = <String, Object>{
        'metadata': <String, Object>{
          'appVersion': appVersion,
          'schemaVersion': _schemaVersion,
          'createdAt': createdAt.toIso8601String(),
          'sha256': digest,
        },
        'database': base64Encode(snapshotBytes),
      };
      final List<int> salt = _secureRandomBytes(16);
      final SecretKey key = await _deriveKey(password, salt);
      final List<int> aad = utf8.encode('flowbackup:$_formatVersion');
      final SecretBox encrypted = await _cipher.encrypt(
        utf8.encode(jsonEncode(payload)),
        secretKey: key,
        aad: aad,
      );
      final Map<String, Object> envelope = <String, Object>{
        'format': 'flowbackup',
        'formatVersion': _formatVersion,
        'kdf': 'argon2id',
        'memoryKiB': _argonMemoryKiB,
        'iterations': _argonIterations,
        'parallelism': _argonParallelism,
        'cipher': 'aes-256-gcm',
        'salt': base64Encode(salt),
        'nonce': base64Encode(encrypted.nonce),
        'mac': base64Encode(encrypted.mac.bytes),
        'ciphertext': base64Encode(encrypted.cipherText),
      };
      final String baseName =
          'flow-${createdAt.toIso8601String().replaceAll(':', '-')}-${_hexBytes(_secureRandomBytes(6))}.flowbackup';
      final File output = File(
        '${destination.path}${Platform.pathSeparator}$baseName',
      );
      final File temporaryOutput = File(
        '${output.path}.tmp-${_hexBytes(_secureRandomBytes(6))}',
      );
      try {
        await temporaryOutput.writeAsString(jsonEncode(envelope), flush: true);
        return await temporaryOutput.rename(output.path);
      } finally {
        if (await temporaryOutput.exists()) {
          await temporaryOutput.delete();
        }
      }
    } finally {
      await temporary.delete(recursive: true);
    }
  }

  Future<PreparedRestore> prepareRestore({
    required File backup,
    required String password,
    required Directory temporaryDirectory,
  }) async {
    _validatePassword(password);
    final int length = await backup.length();
    if (length > maxBackupBytes * 2) {
      throw const BackupException('Backup exceeds the supported size.');
    }
    final Object? decodedEnvelope;
    try {
      decodedEnvelope = jsonDecode(await backup.readAsString());
    } on FormatException {
      throw const BackupException('Backup file is not valid JSON.');
    }
    if (decodedEnvelope is! Map<String, Object?>) {
      throw const BackupException('Backup envelope is invalid.');
    }
    final Map<String, Object?> envelope = decodedEnvelope;
    if (envelope['format'] != 'flowbackup' ||
        envelope['formatVersion'] != _formatVersion ||
        envelope['kdf'] != 'argon2id' ||
        envelope['cipher'] != 'aes-256-gcm' ||
        envelope['memoryKiB'] != _argonMemoryKiB ||
        envelope['iterations'] != _argonIterations ||
        envelope['parallelism'] != _argonParallelism) {
      throw const BackupException(
        'Backup format or parameters are unsupported.',
      );
    }
    try {
      final List<int> salt = _readBase64(envelope, 'salt', exactLength: 16);
      final List<int> nonce = _readBase64(envelope, 'nonce', exactLength: 12);
      final List<int> mac = _readBase64(envelope, 'mac', exactLength: 16);
      final List<int> encrypted = _readBase64(envelope, 'ciphertext');
      final SecretKey key = await _deriveKey(password, salt);
      final List<int> clearText = await _cipher.decrypt(
        SecretBox(encrypted, nonce: nonce, mac: Mac(mac)),
        secretKey: key,
        aad: utf8.encode('flowbackup:$_formatVersion'),
      );
      final Object? decodedPayload = jsonDecode(utf8.decode(clearText));
      if (decodedPayload is! Map<String, Object?>) {
        throw const BackupException('Backup payload is invalid.');
      }
      return await _writeAndValidatePayload(decodedPayload, temporaryDirectory);
    } on SecretBoxAuthenticationError {
      throw const BackupException(
        'Password is incorrect or backup was changed.',
      );
    } on FormatException {
      throw const BackupException('Backup contents are malformed.');
    } on sqlite.SqliteException {
      throw const BackupException('Backup database is corrupt.');
    }
  }

  Future<File> restore({
    required AppDatabase database,
    required File backup,
    required String password,
    required Directory backupDirectory,
    required Directory temporaryDirectory,
    required String appVersion,
  }) async {
    final PreparedRestore prepared = await prepareRestore(
      backup: backup,
      password: password,
      temporaryDirectory: temporaryDirectory,
    );
    try {
      // Preserve the current state before any mutation; its password is the
      // same one the user supplied to unlock the incoming backup.
      final File safetyCopy = await createBackup(
        database: database,
        password: password,
        destination: backupDirectory,
        appVersion: appVersion,
      );
      await database.replaceFromSnapshot(prepared.snapshotPath);
      return safetyCopy;
    } finally {
      await prepared.dispose();
    }
  }

  Future<File> createAutomaticBackup({
    required AppDatabase database,
    required String appVersion,
    Directory? destination,
  }) async {
    final Directory directory = destination ?? await automaticBackupDirectory();
    final String password = await _getAutomaticBackupKey();
    final File backup = await createBackup(
      database: database,
      password: password,
      destination: directory,
      appVersion: appVersion,
    );
    await rotateAutomaticBackups(directory);
    return backup;
  }

  Future<File> restoreAutomaticBackup({
    required AppDatabase database,
    required File backup,
    required Directory temporaryDirectory,
    required String appVersion,
    Directory? safetyBackupDirectory,
  }) async {
    final String password = await _getAutomaticBackupKey(
      createIfMissing: false,
    );
    return restore(
      database: database,
      backup: backup,
      password: password,
      backupDirectory:
          safetyBackupDirectory ?? await automaticBackupDirectory(),
      temporaryDirectory: temporaryDirectory,
      appVersion: appVersion,
    );
  }

  Future<String> _getAutomaticBackupKey({bool createIfMissing = true}) async {
    final String? existing = await _automaticKeyStore.readKey();
    if (existing != null) return existing;
    if (!createIfMissing) {
      throw const BackupException('Automatic backup key is unavailable.');
    }
    final String created = newAutomaticBackupKey();
    await _automaticKeyStore.writeKey(created);
    return created;
  }

  Future<PreparedRestore> _writeAndValidatePayload(
    Map<String, Object?> payload,
    Directory temporaryDirectory,
  ) async {
    final Object? metadataValue = payload['metadata'];
    final Object? databaseValue = payload['database'];
    if (metadataValue is! Map<String, Object?> || databaseValue is! String) {
      throw const BackupException('Backup payload is incomplete.');
    }
    final Map<String, Object?> metadataJson = metadataValue;
    final int schemaVersion = _asInt(metadataJson['schemaVersion']);
    if (schemaVersion != _schemaVersion) {
      throw const BackupException(
        'This backup schema version is not supported.',
      );
    }
    final Uint8List databaseBytes;
    try {
      databaseBytes = base64Decode(databaseValue);
    } on FormatException {
      throw const BackupException('Database payload is not valid base64.');
    }
    if (databaseBytes.isEmpty || databaseBytes.length > maxBackupBytes) {
      throw const BackupException('Database payload size is invalid.');
    }
    final String digest = _hex(await Sha256().hash(databaseBytes));
    if (metadataJson['sha256'] != digest) {
      throw const BackupException('Database checksum does not match.');
    }
    final DateTime createdAt;
    try {
      createdAt = DateTime.parse(_requiredString(metadataJson['createdAt']))
          .toUtc();
    } on Object {
      throw const BackupException('Backup date is invalid.');
    }
    final String appVersion = _requiredString(metadataJson['appVersion']);
    await temporaryDirectory.create(recursive: true);
    final File snapshot = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}restore-${_hexBytes(_secureRandomBytes(12))}.sqlite',
    );
    await snapshot.writeAsBytes(databaseBytes, flush: true);
    sqlite.Database? check;
    bool keepSnapshot = false;
    try {
      check = sqlite.sqlite3.open(
        snapshot.path,
        mode: sqlite.OpenMode.readOnly,
      );
      final sqlite.ResultSet checkRows = check.select('PRAGMA quick_check');
      if (checkRows.length != 1 || checkRows.first.values.single != 'ok') {
        throw const BackupException('Backup database is corrupt.');
      }
      final sqlite.ResultSet versionRows = check.select('PRAGMA user_version');
      final int actualVersion = _requiredInt(versionRows.first.values.single);
      if (actualVersion != schemaVersion) {
        throw const BackupException('Database schema metadata does not match.');
      }
      final Set<String> tables = check
          .select("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((sqlite.Row row) => _requiredString(row['name']))
          .toSet();
      if (!_tableNames.every(tables.contains)) {
        throw const BackupException('Backup is missing required tables.');
      }
      if (check.select('PRAGMA foreign_key_check').isNotEmpty) {
        throw const BackupException('Backup has invalid record relationships.');
      }
      for (final MapEntry<String, List<String>> entry
          in _tableColumns.entries) {
        final List<String> actualColumns = check
            .select('PRAGMA table_info("${entry.key}")')
            .map((sqlite.Row row) => _requiredString(row['name']))
            .toList(growable: false);
        if (actualColumns.length != entry.value.length ||
            actualColumns.asMap().entries.any(
              (MapEntry<int, String> column) =>
                  column.value != entry.value[column.key],
            )) {
          throw const BackupException('Backup database schema is invalid.');
        }
      }
      final Map<String, int> counts = <String, int>{
        for (final String tableName in _tableNames)
          tableName: _requiredInt(
            check
                .select('SELECT COUNT(*) FROM "$tableName"')
                .first
                .values
                .single,
          ),
      };
      final sqlite.Row periodRow = check.select('''
            SELECT MIN(date_value) AS first_date, MAX(date_value) AS last_date
            FROM (
              SELECT logical_date AS date_value FROM habit_logs
              UNION ALL SELECT due_date FROM tasks WHERE due_date IS NOT NULL
              UNION ALL SELECT occurrence_date FROM task_completions
              UNION ALL SELECT logical_date FROM xp_events
              UNION ALL SELECT date(started_at) FROM workout_sessions
            )
          ''').first;
      final Object? start = periodRow['first_date'];
      final Object? end = periodRow['last_date'];
      keepSnapshot = true;
      return PreparedRestore._(
        preview: RestorePreview(
          metadata: BackupMetadata(
            appVersion: appVersion,
            schemaVersion: schemaVersion,
            createdAt: createdAt,
            sha256: digest,
          ),
          counts: Map<String, int>.unmodifiable(counts),
          startDate: start == null ? null : _parseLocalDate(start),
          endDate: end == null ? null : _parseLocalDate(end),
        ),
        snapshotPath: snapshot.path,
      );
    } finally {
      check?.close();
      if (!keepSnapshot && await snapshot.exists()) {
        await snapshot.delete();
      }
    }
  }
}

Future<Directory> automaticBackupDirectory() async {
  final Directory root = await appDataDirectory();
  return Directory('${root.path}${Platform.pathSeparator}backups');
}

Future<List<File>> rotateAutomaticBackups(Directory directory) async {
  if (!await directory.exists()) return const <File>[];
  final List<File> backups = await directory
      .list()
      .where(
        (FileSystemEntity entity) =>
            entity is File && entity.path.endsWith('.flowbackup'),
      )
      .cast<File>()
      .toList();
  backups.sort(
    (File a, File b) => b.statSync().modified.compareTo(a.statSync().modified),
  );
  for (final File expired in backups.skip(5)) {
    await expired.delete();
  }
  return List<File>.unmodifiable(backups.take(5));
}

Future<SecretKey> _deriveKey(String password, List<int> salt) =>
    _kdf.deriveKeyFromPassword(password: password, nonce: salt);

void _validatePassword(String password) {
  if (password.trim().length < 10) {
    throw const BackupException(
      'Backup password must contain at least 10 characters.',
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  throw const BackupException('Backup numeric metadata is invalid.');
}

int _requiredInt(Object? value) {
  if (value is int) return value;
  throw const BackupException('Backup numeric metadata is invalid.');
}

String _requiredString(Object? value) {
  if (value is String) return value;
  throw const BackupException('Backup text metadata is invalid.');
}

List<int> _readBase64(
  Map<String, Object?> envelope,
  String key, {
  int? exactLength,
}) {
  final Object? value = envelope[key];
  if (value is! String) {
    throw const BackupException('Backup envelope is invalid.');
  }
  final List<int> bytes;
  try {
    bytes = base64Decode(value);
  } on FormatException {
    throw const BackupException('Backup envelope encoding is invalid.');
  }
  if (exactLength != null && bytes.length != exactLength) {
    throw const BackupException(
      'Backup envelope parameter has invalid length.',
    );
  }
  return bytes;
}

List<int> _secureRandomBytes(int count) {
  final Random random = Random.secure();
  return List<int>.generate(count, (_) => random.nextInt(256), growable: false);
}

String _hex(Hash hash) =>
    hash.bytes.map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join();

String _hexBytes(List<int> bytes) =>
    bytes.map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join();

LocalDate _parseLocalDate(Object value) {
  if (value is! String) {
    throw const BackupException('Backup date range is invalid.');
  }
  final List<String> parts = value.split('-');
  if (parts.length != 3) {
    throw const BackupException('Backup date range is invalid.');
  }
  try {
    return LocalDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  } on Object {
    throw const BackupException('Backup date range is invalid.');
  }
}
