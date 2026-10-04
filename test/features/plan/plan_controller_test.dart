import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/recurrence/recurrence.dart';
import 'package:flowstate/domain/tasks/task.dart';

import '../../fixtures/domain_fixtures.dart';
import '../../fixtures/today_controller_fixture.dart';

void main() {
  test('creates, edits and archives a recurring task', () async {
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    final controller = fixture.planController;
    await controller.load();
    final date = controller.selectedDate!;

    await controller.saveTask(
      title: 'Estudar Flutter',
      notes: 'Revisar widgets',
      date: date,
      dueMinute: 600,
      estimatedMinutes: 45,
      priority: TaskPriority.high,
      recurrence: Recurrence.weekdays(<int>{1, 3, 5}),
    );
    expect(controller.dayTasks, hasLength(1));
    final task = controller.dayTasks.single;
    expect(task.title, 'Estudar Flutter');
    expect(task.notes, 'Revisar widgets');
    expect(task.priority, TaskPriority.high);
    expect(task.isScheduledOn(date.addDays(2)), isTrue);

    await controller.saveTask(
      existing: task,
      title: 'Estudar Dart',
      date: date,
      dueMinute: task.dueMinute,
      estimatedMinutes: task.estimatedMinutes,
      priority: task.priority,
      recurrence: task.recurrence,
    );
    expect(controller.dayTasks.single.id, task.id);
    expect(controller.dayTasks.single.title, 'Estudar Dart');

    await controller.archiveTask(controller.dayTasks.single);
    expect(controller.dayTasks, isEmpty);
    expect(await fixture.controller.taskRepository.getActiveTasks(), isEmpty);
  });

  test('stores routine blocks and derives conflicts and free time', () async {
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    final controller = fixture.planController;
    await controller.load();
    final date = controller.selectedDate!;
    await controller.saveTask(
      title: 'Estudar',
      date: date,
      dueMinute: 600,
      estimatedMinutes: 60,
      priority: TaskPriority.normal,
      recurrence: null,
    );
    await controller.saveRoutineBlock(
      title: 'Pausa',
      startMinute: 630,
      durationMinutes: 30,
      categoryId: 'body',
      weekdays: <int>{date.weekday},
    );

    expect(controller.dayBlocks, hasLength(1));
    expect(controller.conflicts, hasLength(1));
    expect(controller.suggestedSlots, isNotEmpty);
    expect(controller.suggestedSlots.first.startMinute, 8 * 60);
  });

  test('task completion awards idempotent XP and undo reverses it', () async {
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    final controller = fixture.planController;
    await controller.load();
    final date = controller.selectedDate!;
    await controller.saveTask(
      title: 'Ler',
      date: date,
      dueMinute: null,
      estimatedMinutes: null,
      priority: TaskPriority.normal,
      recurrence: null,
    );
    final Task task = controller.dayTasks.single;

    await controller.completeTask(task);
    expect(controller.isTaskComplete(task), isTrue);
    expect(
      (await fixture.controller.xpRepository.getLedger(through: date))
          .where((XpEvent event) => event.action == XpAction.task)
          .single
          .xp,
      5,
    );

    await controller.undoLastCompletion();
    expect(controller.isTaskComplete(task), isFalse);
    final List<XpEvent> ledger = await fixture.controller.xpRepository
        .getLedger(through: date);
    expect(ledger, hasLength(1));
    expect(ledger.single.reversedAt, isNotNull);
  });

  test('schedules an existing task into a suggested free slot', () async {
    final fixture = createTodayControllerFixture();
    addTearDown(fixture.dispose);
    final controller = fixture.planController;
    await controller.load();
    final date = controller.selectedDate!;
    await fixture.controller.taskRepository.saveTask(
      testTask(id: 990, title: 'Planejar semana'),
    );
    await controller.load();
    final task = controller.unscheduledTasks.single;

    await controller.scheduleTask(task, 8 * 60);
    expect(controller.unscheduledTasks, isEmpty);
    expect(controller.dayTasks.single.dueMinute, 8 * 60);
    expect(controller.dayTasks.single.dueDate, date);
  });
}
