import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';

import '../../fixtures/today_controller_fixture.dart';

void main() {
  test(
    'creates a habit, logs its minimum, and reverses its XP on undo',
    () async {
      final fixture = createTodayControllerFixture();
      addTearDown(fixture.dispose);
      final controller = fixture.habitsController;

      await controller.load();
      await controller.saveHabit(
        name: 'Ler',
        iconId: 'reading',
        categoryId: HabitCategoryId.mind,
        recurrence: Recurrence.weekdays(<int>{1, 3, 5}),
        cue: 'Depois do café',
        minimumVersion: 'Uma página',
        isEssential: true,
      );

      expect(controller.habits, hasLength(1));
      final habit = controller.habits.single;
      expect(habit.name, 'Ler');
      expect(habit.recurrence.weekdays, <int>{1, 3, 5});
      expect(habit.cue, 'Depois do café');

      await controller.logToday(habit, HabitLogLevel.minimum);
      expect(controller.levelToday(habit), HabitLogLevel.minimum);
      expect(controller.streakFor(habit), 1);
      expect(controller.completedInCurrentWeek(habit), 1);
      expect(controller.logs, hasLength(1));
      expect(
        (await fixture.habitsController.xpRepository.getLedger()).single.xp,
        5,
      );

      await controller.undoLastLog();
      expect(controller.isCompletedToday(habit), isFalse);
      expect(controller.logs, isEmpty);
      expect(
        await fixture.habitsController.xpRepository.getLedger(),
        hasLength(1),
      );
    },
  );

  test(
    'editing preserves habit identity and archiving is a soft delete',
    () async {
      final fixture = createTodayControllerFixture();
      addTearDown(fixture.dispose);
      final controller = fixture.habitsController;
      await controller.load();
      await controller.saveHabit(
        name: 'Caminhar',
        iconId: 'movement',
        categoryId: HabitCategoryId.body,
        recurrence: Recurrence.daily(),
        isEssential: false,
      );
      final Habit original = controller.habits.single;

      await controller.saveHabit(
        existing: original,
        name: 'Caminhar ao ar livre',
        iconId: original.iconId,
        categoryId: original.categoryId,
        recurrence: original.recurrence,
        isEssential: true,
      );
      expect(controller.habits.single.id, original.id);
      expect(controller.habits.single.name, 'Caminhar ao ar livre');

      await controller.logToday(controller.habits.single, HabitLogLevel.full);
      await controller.archive(controller.habits.single);
      expect(controller.habits, isEmpty);
      expect(controller.logs, hasLength(1));
    },
  );

  test('only scheduled weekdays can be checked in', () async {
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    final controller = fixture.habitsController;
    await controller.load();
    await controller.saveHabit(
      name: 'Monday walk',
      iconId: 'movement',
      categoryId: HabitCategoryId.body,
      recurrence: Recurrence.weekdays(<int>{1}),
      isEssential: false,
    );
    final Habit habit = controller.habits.single;

    expect(controller.currentDate.weekday, 3);
    expect(controller.isScheduledToday(habit), isFalse);
  });
}
