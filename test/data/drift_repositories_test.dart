import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/data/database/app_database.dart' as db;
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/domain/focus/focus_session.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/domain/routine/routine_block.dart';
import 'package:flowstate/domain/shared/record_metadata.dart';
import 'package:flowstate/domain/tasks/task.dart';
import 'package:flutter_test/flutter_test.dart';

final Clock testClock = Clock.fixed(DateTime.utc(2026, 10, 3, 12));

void main() {
  test('domain records round-trip with stable ids and local dates', () async {
    final db.AppDatabase database = db.AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final DriftHabitRepository habits = DriftHabitRepository(database);
    final DriftTaskRepository tasks = DriftTaskRepository(database);
    final DriftRoutineRepository routines = DriftRoutineRepository(database);
    final DriftFocusRepository focus = DriftFocusRepository(database);
    final DriftXpRepository xp = DriftXpRepository(database);
    final LocalDate day = LocalDate(2026, 10, 3);
    final Habit habit = Habit(
      metadata: _metadata(10),
      name: 'Ler',
      iconId: 'book',
      categoryId: 'mind',
      recurrence: Recurrence.weekdays(<int>{1, 3, 5}),
      cue: 'Depois do café',
      isEssential: true,
    );
    await habits.saveHabit(habit);
    final Task task = Task(
      metadata: _metadata(11),
      title: 'Estudar',
      dueDate: day,
      dueMinute: 555,
      priority: TaskPriority.high,
      recurrence: Recurrence.everyNDays(interval: 3, anchor: day),
    );
    await tasks.saveTask(task);
    final HabitLog log = HabitLog(
      metadata: _metadata(12),
      habitId: habit.id,
      logicalDate: day,
      level: HabitLogLevel.minimum,
    );
    await habits.saveHabitLog(log);
    await habits.saveHabitLog(
      HabitLog(
        metadata: _metadata(17),
        habitId: habit.id,
        logicalDate: day,
        level: HabitLogLevel.full,
      ),
    );
    final TaskCompletion completion = TaskCompletion(
      metadata: _metadata(13),
      taskId: task.id,
      occurrenceDate: day,
    );
    await tasks.saveCompletion(completion);
    await tasks.saveCompletion(
      TaskCompletion(
        metadata: _metadata(18),
        taskId: task.id,
        occurrenceDate: day,
      ),
    );
    await routines.saveBlock(
      RoutineBlock(
        metadata: _metadata(14),
        title: 'Leitura',
        startMinute: 1380,
        durationMinutes: 90,
        categoryId: 'mind',
        weekdays: <int>{1, 7},
      ),
    );
    final FocusSession session = FocusSession(
      metadata: _metadata(15),
      startedAt: DateTime.utc(2026, 10, 3, 12),
      endAt: DateTime.utc(2026, 10, 3, 12, 25),
      taskId: task.id,
    );
    await focus.saveSession(session);
    final XpEvent event = XpEvent(
      metadata: _metadata(16),
      action: XpAction.focusSession,
      sourceId: session.metadata.id,
      logicalDate: day,
      units: 25,
      xp: 25,
    );

    expect(await xp.insertIfAbsent(event), isTrue);
    expect(await xp.insertIfAbsent(event), isFalse);
    expect((await habits.getActiveHabits()).single.recurrence.weekdays, <int>{
      1,
      3,
      5,
    });
    expect(
      (await habits.getHabitLogs(from: day, through: day)).single.level,
      HabitLogLevel.full,
    );
    expect(await habits.getHabitLogs(from: day, through: day), hasLength(1));
    expect((await tasks.getActiveTasks()).single.recurrence?.intervalDays, 3);
    expect(
      (await tasks.getCompletions(from: day, through: day)).single.metadata.id,
      _metadata(18).id,
    );
    expect((await routines.getActiveBlocks()).single.weekdays, <int>{1, 7});
    expect((await focus.getSessions()).single.endAt, session.endAt);
    expect(
      (await xp.getLedger(through: day)).single.action,
      XpAction.focusSession,
    );
    await xp.reverse(event.reverse(clock: testClock));
    expect((await xp.getLedger(through: day)).single.isActive, isFalse);
  });
}

RecordMetadata _metadata(int value) {
  final DateTime created = testClock.now().toUtc();
  return RecordMetadata(
    id: '00000000-0000-4000-8000-${value.toString().padLeft(12, '0')}',
    createdAt: created,
    updatedAt: created,
    deviceId: 'test-device',
  );
}
