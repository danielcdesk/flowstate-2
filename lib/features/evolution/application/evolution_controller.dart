import 'dart:async';
import 'dart:math' as math;

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/core/logical_date.dart';
import 'package:flowstate/domain/evolution/evolution.dart';
import 'package:flowstate/domain/focus/focus_session.dart';
import 'package:flowstate/domain/gamification/skill_scores.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/habits/habit.dart';
import 'package:flowstate/domain/insights/weekly_review.dart';
import 'package:flowstate/domain/repositories/focus_repository.dart';
import 'package:flowstate/domain/repositories/habit_repository.dart';
import 'package:flowstate/domain/repositories/task_repository.dart';
import 'package:flowstate/domain/repositories/xp_repository.dart';
import 'package:flowstate/domain/tasks/task.dart';

final class EvolutionController extends ChangeNotifier {
  EvolutionController({
    required this.habitRepository,
    required this.taskRepository,
    required this.focusRepository,
    required this.xpRepository,
    required this.clock,
  });

  final HabitRepository habitRepository;
  final TaskRepository taskRepository;
  final FocusRepository focusRepository;
  final XpRepository xpRepository;
  final Clock clock;

  bool isLoading = false;
  bool failedToLoad = false;
  Object? error;
  List<SkillScore> radar = const <SkillScore>[];
  WeeklyReview weeklyReview = WeeklyReview(
    isReady: false,
    insights: const <WeeklyInsight>[],
  );
  AnnualRetrospective annual = AnnualRetrospective(
    year: 1,
    isUnlocked: false,
    events: const <EvolutionTimelineEvent>[],
  );
  int totalXp = 0;
  int level = 1;
  int annualYear = 1;

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    failedToLoad = false;
    error = null;
    notifyListeners();
    try {
      final DateTime now = clock.now().toLocal();
      final LocalDate through = logicalDate(now, dayStartMinute: 240);
      final LocalDate historyStart = LocalDate(now.year - 1, 1, 1);
      final List<Object> records = await Future.wait<Object>(<Future<Object>>[
        habitRepository.getActiveHabits(),
        habitRepository.getHabitLogs(from: historyStart, through: through),
        taskRepository.getActiveTasks(),
        taskRepository.getCompletions(from: historyStart, through: through),
        focusRepository.getSessions(),
        xpRepository.getLedger(),
      ]);
      final List<Habit> habits = records[0] as List<Habit>;
      final List<HabitLog> logs = records[1] as List<HabitLog>;
      final List<Task> tasks = records[2] as List<Task>;
      final List<TaskCompletion> completions =
          records[3] as List<TaskCompletion>;
      final List<FocusSession> sessions = records[4] as List<FocusSession>;
      final List<XpEvent> ledger = records[5] as List<XpEvent>;
      final LocalDate periodStart = through.addDays(-13);
      final List<DailyReviewSnapshot> days = _dailySnapshots(
        habits: habits,
        logs: logs,
        sessions: sessions,
        from: periodStart,
        through: through,
        now: now,
      );
      final List<HabitReviewEvent> habitEvents = _habitEvents(
        habits: habits,
        logs: logs,
        from: periodStart,
        through: through,
      );
      final List<FocusReviewSession> focusEvents = _focusEvents(
        sessions: sessions,
        from: periodStart,
        through: through,
        now: now,
      );
      weeklyReview = calculateWeeklyReview(
        dailyData: days,
        habitEvents: habitEvents,
        focusSessions: focusEvents,
        through: through,
      );
      final int habitCurrent = habitEvents
          .where((HabitReviewEvent event) => event.wasCompleted)
          .length;
      final int habitTarget = math.max(
        1,
        habitEvents
            .where((HabitReviewEvent event) => event.wasScheduled)
            .length,
      );
      final int taskCurrent = completions
          .where(
            (TaskCompletion completion) =>
                completion.occurrenceDate.compareTo(periodStart) >= 0 &&
                completion.occurrenceDate.compareTo(through) <= 0,
          )
          .length;
      final int taskTarget = math.max(
        1,
        _scheduledTaskCount(tasks, periodStart, through),
      );
      final int focusCurrent = focusEvents.fold<int>(
        0,
        (int total, FocusReviewSession session) =>
            total + session.durationMinutes,
      );
      radar = calculateSkillScores(
        activeModuleIds: const <String>{'focus', 'habits', 'planning'},
        progress: <SkillProgress>[
          SkillProgress(
            moduleId: 'habits',
            current: habitCurrent,
            target: habitTarget,
          ),
          SkillProgress(
            moduleId: 'planning',
            current: taskCurrent,
            target: taskTarget,
          ),
          SkillProgress(moduleId: 'focus', current: focusCurrent, target: 180),
        ],
      );
      final List<EvolutionTimelineEvent> events = _timelineEvents(
        habits: habits,
        logs: logs,
        tasks: tasks,
        completions: completions,
        sessions: sessions,
        now: now,
      );
      annualYear = now.year;
      annual = calculateAnnualRetrospective(
        year: annualYear,
        through: through,
        events: events,
      );
      totalXp = totalActiveXp(ledger);
      level = levelForXp(totalXp);
    } on Object catch (caught) {
      error = caught;
      failedToLoad = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<DailyReviewSnapshot> _dailySnapshots({
    required List<Habit> habits,
    required List<HabitLog> logs,
    required List<FocusSession> sessions,
    required LocalDate from,
    required LocalDate through,
    required DateTime now,
  }) {
    final List<DailyReviewSnapshot> result = <DailyReviewSnapshot>[];
    for (int index = 0; index < 14; index++) {
      final LocalDate date = from.addDays(index);
      final int scheduled = habits
          .where((Habit habit) => habit.recurrence.isScheduledOn(date))
          .length;
      final int completed = logs
          .where(
            (HabitLog log) =>
                log.logicalDate == date &&
                (log.level == HabitLogLevel.full ||
                    log.level == HabitLogLevel.minimum),
          )
          .length;
      final int focus =
          _focusEvents(
            sessions: sessions,
            from: date,
            through: date,
            now: now,
          ).fold<int>(
            0,
            (int total, FocusReviewSession session) =>
                total + session.durationMinutes,
          );
      result.add(
        DailyReviewSnapshot(
          date: date,
          scheduledHabits: scheduled,
          completedHabits: completed,
          focusMinutes: focus,
          workoutCompleted: false,
          recoveryDay: false,
        ),
      );
    }
    return result;
  }

  List<HabitReviewEvent> _habitEvents({
    required List<Habit> habits,
    required List<HabitLog> logs,
    required LocalDate from,
    required LocalDate through,
  }) {
    final List<HabitReviewEvent> events = <HabitReviewEvent>[];
    for (final Habit habit in habits) {
      for (int index = 0; index <= through.differenceInDays(from); index++) {
        final LocalDate date = from.addDays(index);
        final HabitLog? log = logs.cast<HabitLog?>().firstWhere(
          (HabitLog? item) =>
              item?.habitId == habit.id && item?.logicalDate == date,
          orElse: () => null,
        );
        final bool completed =
            log?.level == HabitLogLevel.full ||
            log?.level == HabitLogLevel.minimum;
        events.add(
          HabitReviewEvent(
            habitId: habit.id,
            date: date,
            wasScheduled: habit.recurrence.isScheduledOn(date),
            wasCompleted: completed,
            performedAtMinute: log == null
                ? null
                : log.metadata.updatedAt.toLocal().hour * 60 +
                      log.metadata.updatedAt.toLocal().minute,
          ),
        );
      }
    }
    return events;
  }

  List<FocusReviewSession> _focusEvents({
    required List<FocusSession> sessions,
    required LocalDate from,
    required LocalDate through,
    required DateTime now,
  }) => sessions
      .where((FocusSession session) {
        final LocalDate date = _logicalDate(session.startedAt);
        return session.metadata.deletedAt == null &&
            !session.endAt.isAfter(now.toUtc()) &&
            date.compareTo(from) >= 0 &&
            date.compareTo(through) <= 0;
      })
      .map(
        (FocusSession session) => FocusReviewSession(
          date: _logicalDate(session.startedAt),
          startMinute:
              session.startedAt.toLocal().hour * 60 +
              session.startedAt.toLocal().minute,
          durationMinutes: session.durationMinutes,
        ),
      )
      .toList();

  List<EvolutionTimelineEvent> _timelineEvents({
    required List<Habit> habits,
    required List<HabitLog> logs,
    required List<Task> tasks,
    required List<TaskCompletion> completions,
    required List<FocusSession> sessions,
    required DateTime now,
  }) {
    final Map<String, String> habitNames = <String, String>{
      for (final Habit habit in habits) habit.id: habit.name,
    };
    final Map<String, String> taskNames = <String, String>{
      for (final Task task in tasks) task.id: task.title,
    };
    final List<EvolutionTimelineEvent> events = <EvolutionTimelineEvent>[];
    for (final HabitLog log in logs.where(
      (HabitLog item) =>
          item.level != HabitLogLevel.skipped &&
          item.metadata.deletedAt == null,
    )) {
      events.add(
        EvolutionTimelineEvent(
          date: log.logicalDate,
          kind: EvolutionEventKind.habit,
          title: habitNames[log.habitId] ?? '',
          detail: '',
        ),
      );
    }
    for (final TaskCompletion completion in completions) {
      events.add(
        EvolutionTimelineEvent(
          date: completion.occurrenceDate,
          kind: EvolutionEventKind.task,
          title: taskNames[completion.taskId] ?? '',
          detail: '',
        ),
      );
    }
    for (final FocusSession session in sessions.where(
      (FocusSession item) =>
          item.metadata.deletedAt == null && !item.endAt.isAfter(now.toUtc()),
    )) {
      events.add(
        EvolutionTimelineEvent(
          date: _logicalDate(session.startedAt),
          kind: EvolutionEventKind.focus,
          title: '',
          detail: '',
          value: session.durationMinutes,
        ),
      );
    }
    return events;
  }

  int _scheduledTaskCount(List<Task> tasks, LocalDate from, LocalDate through) {
    int count = 0;
    for (final Task task in tasks) {
      for (int index = 0; index <= through.differenceInDays(from); index++) {
        if (task.isScheduledOn(from.addDays(index))) count++;
      }
    }
    return count;
  }

  LocalDate _logicalDate(DateTime moment) =>
      logicalDate(moment.toLocal(), dayStartMinute: 240);
}
