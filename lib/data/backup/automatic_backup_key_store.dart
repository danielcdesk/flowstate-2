import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AutomaticBackupKeyStore {
  Future<String?> readKey();

  Future<void> writeKey(String key);
}

final class DeviceProtectedBackupKeyStore implements AutomaticBackupKeyStore {
  DeviceProtectedBackupKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage();

  static const String _keyName = 'automatic_backup_key_v1';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> readKey() => _storage.read(key: _keyName);

  @override
  Future<void> writeKey(String key) =>
      _storage.write(key: _keyName, value: key);
}

String newAutomaticBackupKey() => base64UrlEncode(
  List<int>.generate(32, (_) => Random.secure().nextInt(256), growable: false),
);
