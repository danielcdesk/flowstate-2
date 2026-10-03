import 'package:flowstate/data/export/csv_exporter.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/domain_fixtures.dart';

void main() {
  test('CSV escapes formula payloads and follows RFC quoting', () {
    final Habit unsafe = Habit(
      metadata: testMetadata(300),
      name: '=HYPERLINK("https://example.test")',
      iconId: 'book',
      categoryId: 'mind',
      recurrence: Recurrence.daily(),
    );

    final String csv = exportHabitsCsv(<Habit>[unsafe]);

    expect(csv, contains('"\'=HYPERLINK(""https://example.test"")"'));
  });

  test('CSV protects formula markers after leading whitespace', () {
    final Habit unsafe = Habit(
      metadata: testMetadata(301),
      name: '  @SUM(1,2)',
      iconId: 'book',
      categoryId: 'mind',
      recurrence: Recurrence.daily(),
    );

    expect(exportHabitsCsv(<Habit>[unsafe]), contains("'  @SUM(1,2)"));
  });
}
