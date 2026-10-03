import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';

import '../fixtures/domain_fixtures.dart';

void main() {
  test('creates UTC audit timestamps and a UUID using the injected clock', () {
    final RecordMetadata metadata = RecordMetadata.create(
      clock: Clock.fixed(DateTime.utc(2026, 10, 3, 12, 30)),
      deviceId: testDeviceId,
    );

    expect(metadata.createdAt, DateTime.utc(2026, 10, 3, 12, 30));
    expect(metadata.updatedAt, metadata.createdAt);
    expect(metadata.createdAt.isUtc, isTrue);
    expect(metadata.deletedAt, isNull);
    expect(metadata.deviceId, testDeviceId);
    expect(metadata.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
  });

  test('rejects invalid identifiers and non-UTC audit timestamps', () {
    expect(
      () => RecordMetadata(
        id: 'invalid',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        deviceId: testDeviceId,
      ),
      throwsArgumentError,
    );
    expect(
      () => RecordMetadata(
        id: testUuid(2),
        createdAt: DateTime(2026),
        updatedAt: DateTime.utc(2026),
        deviceId: testDeviceId,
      ),
      throwsArgumentError,
    );
    expect(
      () => RecordMetadata(
        id: testUuid(3),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        deletedAt: DateTime(2026),
        deviceId: testDeviceId,
      ),
      throwsArgumentError,
    );
    expect(
      () => RecordMetadata(
        id: testUuid(4),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        deviceId: ' ',
      ),
      throwsArgumentError,
    );
  });
}
