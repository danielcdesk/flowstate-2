import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/core/logical_date.dart';
import 'package:flowstate/core/ids.dart';

void main() {
  group('LocalDate', () {
    test('rejects impossible month days and months', () {
      expect(() => LocalDate(2026, 2, 29), throwsArgumentError);
      expect(() => LocalDate(2026, 13, 1), throwsArgumentError);
      expect(() => LocalDate(2026, 0, 1), throwsArgumentError);
    });

    test('supports leap day and year boundaries', () {
      expect(LocalDate(2024, 2, 29).addDays(1), LocalDate(2024, 3, 1));
      expect(LocalDate(2025, 1, 1).addDays(-1), LocalDate(2024, 12, 31));
      expect(LocalDate(2025, 12, 31).addDays(1), LocalDate(2026, 1, 1));
    });

    test('exposes ISO weekday, week start, ordering and day difference', () {
      final LocalDate wednesday = LocalDate(2026, 9, 30);
      expect(wednesday.weekday, DateTime.wednesday);
      expect(wednesday.startOfIsoWeek, LocalDate(2026, 9, 28));
      expect(wednesday.compareTo(LocalDate(2026, 9, 29)), greaterThan(0));
      expect(wednesday.differenceInDays(LocalDate(2026, 9, 29)), 1);
      expect(wednesday.toString(), '2026-09-30');
      expect(wednesday, LocalDate(2026, 9, 30));
      expect(wednesday.hashCode, LocalDate(2026, 9, 30).hashCode);
    });
  });

  group('logicalDate', () {
    test('moves early local time to the previous logical day', () {
      expect(
        logicalDate(DateTime(2026, 9, 30, 3, 59), dayStartMinute: 240),
        LocalDate(2026, 9, 29),
      );
      expect(
        logicalDate(DateTime(2026, 9, 30, 4), dayStartMinute: 240),
        LocalDate(2026, 9, 30),
      );
    });

    test('handles midnight default and validates the configured boundary', () {
      expect(
        logicalDate(DateTime(2026, 1, 1), dayStartMinute: 0),
        LocalDate(2026, 1, 1),
      );
      expect(
        () => logicalDate(DateTime(2026), dayStartMinute: -1),
        throwsArgumentError,
      );
      expect(
        () => logicalDate(DateTime(2026), dayStartMinute: 1440),
        throwsArgumentError,
      );
    });
  });

  test('creates valid random UUID identifiers', () {
    final String id = newId();
    expect(isUuid(id), isTrue);
    expect(isUuid('not-an-id'), isFalse);
  });
}
