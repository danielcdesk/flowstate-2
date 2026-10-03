import 'package:clock/clock.dart';

import 'package:flowstate/core/ids.dart';

/// Audit fields shared by all persisted domain records.
final class RecordMetadata {
  RecordMetadata({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    this.deletedAt,
  }) {
    if (!isUuid(id)) throw ArgumentError.value(id, 'id', 'Must be a UUID.');
    if (createdAt.isUtc == false || updatedAt.isUtc == false) {
      throw ArgumentError('Record timestamps must be UTC.');
    }
    final DateTime? deletionTimestamp = deletedAt;
    if (deletionTimestamp != null && !deletionTimestamp.isUtc) {
      throw ArgumentError('deletedAt must be UTC.');
    }
    if (deviceId.trim().isEmpty) {
      throw ArgumentError.value(deviceId, 'deviceId');
    }
  }

  factory RecordMetadata.create({
    required Clock clock,
    required String deviceId,
    String? id,
  }) {
    final DateTime now = clock.now().toUtc();
    return RecordMetadata(
      id: id ?? newId(),
      createdAt: now,
      updatedAt: now,
      deviceId: deviceId,
    );
  }

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
}
