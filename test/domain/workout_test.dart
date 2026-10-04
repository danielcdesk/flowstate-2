import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/domain/workouts/workout.dart';

void main() {
  test('calculates Epley one-rep max and next-load suggestion', () {
    expect(estimatedOneRepMax(repetitions: 5, loadKg: 60), closeTo(70, 0.001));
    expect(
      suggestedNextLoad(
        currentLoadKg: 60,
        completedRepetitions: 10,
        targetRepetitions: 10,
      ),
      62.5,
    );
    expect(
      suggestedNextLoad(
        currentLoadKg: 60,
        completedRepetitions: 8,
        targetRepetitions: 10,
      ),
      60,
    );
  });

  test('rest completion derives from absolute endAt', () {
    final DateTime start = DateTime.utc(2026, 10, 4, 12);
    final DateTime end = restEndAt(startedAt: start, restSeconds: 90);
    expect(
      isRestComplete(
        endAt: end,
        clock: Clock(() => DateTime.utc(2026, 10, 4, 12, 1, 30)),
      ),
      isTrue,
    );
  });
}
