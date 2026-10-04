// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get designCatalogTitle => 'Visual catalog';

  @override
  String get skillRadarTitle => 'Skill radar';

  @override
  String get skillRadarDescription =>
      'A visual preview with sample data. Real progress will be calculated from your history.';

  @override
  String get skillRadarAccessibleTitle => 'Sample skill radar';

  @override
  String get skillConsistency => 'Consistency';

  @override
  String get skillFocus => 'Focus';

  @override
  String get skillPlanning => 'Planning';

  @override
  String get skillEnergy => 'Energy';

  @override
  String get skillStrength => 'Strength';

  @override
  String get todayGreeting => 'Good morning';

  @override
  String get todaySubtitle => 'The minimum still counts today.';

  @override
  String todayLevelXp(int level, int xp) {
    return 'Level $level · $xp XP';
  }

  @override
  String get todayProgressTitle => 'Done today';

  @override
  String todayProgressValue(int completed, int total) {
    return '$completed of $total';
  }

  @override
  String get todayLoadError =>
      'Your day could not be loaded. Your data is still on this device.';

  @override
  String get todayActionError =>
      'This action could not be saved. Your data is still on this device.';

  @override
  String get retryAction => 'Try again';

  @override
  String get nextActionTitle => 'Next action';

  @override
  String get nextActionEmpty =>
      'All clear for now. Add a habit or task to get started.';

  @override
  String get nextActionTask => 'Take 10 minutes to set up your morning';

  @override
  String get completeAction => 'Complete';

  @override
  String get quickActionsTitle => 'Quick actions';

  @override
  String get newHabitAction => 'Create habit';

  @override
  String get newTaskAction => 'Create task';

  @override
  String get quickActionComingSoon =>
      'This shortcut will be connected in a later step.';

  @override
  String get actionCompleted => 'Done. Your progress has been updated.';

  @override
  String get undoAction => 'Undo';

  @override
  String get startFocusAction => 'Start focus';

  @override
  String get startWorkoutAction => 'Start workout';

  @override
  String get todayHabitsTitle => 'Today\'s habits';

  @override
  String get todayHabitsEmptyTitle => 'No habits for today';

  @override
  String get todayHabitsEmptyMessage =>
      'Your habits will appear here once they are set up.';

  @override
  String get habitTapToComplete => 'Tap to mark as done';

  @override
  String get completedStatus => 'Completed';

  @override
  String daysStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: 'Getting started',
    );
    return '$_temp0';
  }

  @override
  String get habitMorning => 'Breathe for 2 minutes';

  @override
  String get habitMorningCue => 'After opening the window';

  @override
  String get habitMorningStreak => '3 days';

  @override
  String get habitReading => 'Read 10 pages';

  @override
  String get habitReadingCue => 'After coffee';

  @override
  String get habitReadingStreak => '5 days';

  @override
  String get timelineTitle => 'Timeline';

  @override
  String get timelineEmpty =>
      'Nothing planned yet. When you plan something, it will appear here.';

  @override
  String get welcomeTitle => 'Your day in one place.';

  @override
  String get welcomeDescription =>
      'Habits, tasks, routines, and workouts — with kindness on hard days.';

  @override
  String get continueAction => 'Get started';

  @override
  String get backupLink => 'I already have a backup';

  @override
  String get localDataNote => 'Your data stays on this device.';

  @override
  String get navToday => 'Today';

  @override
  String get navPlan => 'Plan';

  @override
  String get navHabits => 'Habits';

  @override
  String get navWorkouts => 'Workouts';

  @override
  String get navEvolution => 'Evolution';

  @override
  String get shellComingSoon =>
      'This destination will be connected in a later phase.';

  @override
  String get flowRingSemanticLabel => 'Daily progress';

  @override
  String get habitsScreenTitle => 'Your habits';

  @override
  String get habitsListSectionTitle => 'Your rhythm';

  @override
  String get habitsScreenSubtitle => 'Small steps, at your pace.';

  @override
  String get habitsCreateAction => 'Create habit';

  @override
  String get habitsEmptyTitle => 'Start with one small step';

  @override
  String get habitsEmptyMessage =>
      'Choose something simple you would like to repeat. You can adjust it later.';

  @override
  String get habitsLoading => 'Loading your habits';

  @override
  String get habitsLoadError =>
      'Your habits could not be loaded. Your data is still on this device.';

  @override
  String get habitsErrorTitle => 'Your habits could not load just now';

  @override
  String get habitsSaveError =>
      'The habit could not be saved. Your data is still on this device.';

  @override
  String get habitsRetryAction => 'Try again';

  @override
  String get habitsStreakLabel => 'Current streak';

  @override
  String get habitsWeekLabel => 'This week';

  @override
  String habitsWeekProgress(int completed, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: '$target times',
      one: '1 time',
    );
    return '$completed of $_temp0';
  }

  @override
  String habitsWeeklyTargetOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times per week',
      one: '1 time per week',
    );
    return '$_temp0';
  }

  @override
  String get habitsLogFullAction => 'Mark as done';

  @override
  String get habitsLogMinimumAction => 'Do the minimum version';

  @override
  String get habitsEditAction => 'Edit habit';

  @override
  String get habitsArchiveAction => 'Archive habit';

  @override
  String get habitsArchivedMessage =>
      'Habit archived. Its history was preserved.';

  @override
  String get habitsCreateTitle => 'Create habit';

  @override
  String get habitsEditTitle => 'Edit habit';

  @override
  String get habitsNameLabel => 'Habit name';

  @override
  String get habitsNameHint => 'E.g. Read for 10 minutes';

  @override
  String get habitsIconLabel => 'Icon';

  @override
  String get habitsCategoryLabel => 'Area';

  @override
  String get habitsCategoryMind => 'Mind';

  @override
  String get habitsCategoryBody => 'Body';

  @override
  String get habitsCategoryFocus => 'Focus';

  @override
  String get habitsFrequencyLabel => 'Frequency';

  @override
  String get habitsFrequencyDaily => 'Every day';

  @override
  String get habitsFrequencyWeekdays => 'Selected days';

  @override
  String get habitsFrequencyWeeklyTarget => 'Weekly target';

  @override
  String get habitsWeekdaysLabel => 'Repeat on';

  @override
  String get habitsWeeklyTargetLabel => 'Times per week';

  @override
  String get habitsCueLabel => 'Cue (optional)';

  @override
  String get habitsCueHint => 'After I...';

  @override
  String get habitsMinimumLabel => 'Minimum version (optional)';

  @override
  String get habitsMinimumHint => 'E.g. Read one page';

  @override
  String get habitsEssentialLabel => 'Essential habit';

  @override
  String get habitsReminderLabel => 'Optional reminder';

  @override
  String get habitsChooseReminderAction => 'Choose time';

  @override
  String get habitsRemoveReminderAction => 'Remove reminder';

  @override
  String get habitsNotScheduledToday => 'Not scheduled for today';

  @override
  String get habitsSaveAction => 'Save habit';

  @override
  String get habitsCancelAction => 'Cancel';

  @override
  String get habitsHistoryLabel => 'Last 28 days';

  @override
  String get habitsHistoryFull => 'Done';

  @override
  String get habitsHistoryMinimum => 'Minimum version';

  @override
  String get habitsHistoryMissed => 'No check-in';

  @override
  String get habitsTodayCompleted => 'Done today';

  @override
  String get habitsArchivedTitle => 'Archived habits';

  @override
  String get habitIconMindfulness => 'Breathing';

  @override
  String get habitIconReading => 'Reading';

  @override
  String get habitIconMovement => 'Movement';

  @override
  String get habitIconWater => 'Pause';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get planTitle => 'Your plan';

  @override
  String get planSubtitle => 'Shape your day and leave room to breathe.';

  @override
  String get planPreviousWeek => 'Previous week';

  @override
  String get planNextWeek => 'Next week';

  @override
  String get planTasksTitle => 'Tasks for the day';

  @override
  String get planRoutineTitle => 'Routine';

  @override
  String get planFreeSlotsTitle => 'Open time';

  @override
  String get planUnscheduledTitle => 'Unscheduled';

  @override
  String get planTasksEmptyTitle => 'An open day';

  @override
  String get planTasksEmptyMessage =>
      'Add a task or choose an open slot to get started.';

  @override
  String get planRoutineEmptyTitle => 'Your routine starts here';

  @override
  String get planRoutineEmptyMessage =>
      'Create recurring blocks to give your week a rhythm.';

  @override
  String get planSlotsEmpty =>
      'No 25-minute openings are available in this window.';

  @override
  String get planCreateTask => 'Create task';

  @override
  String get planCreateRoutine => 'Create block';

  @override
  String get planEditTask => 'Edit task';

  @override
  String get planEditRoutine => 'Edit block';

  @override
  String get planArchiveTask => 'Archive task';

  @override
  String get planArchiveRoutine => 'Archive block';

  @override
  String get planTaskCreateTitle => 'New task';

  @override
  String get planRoutineCreateTitle => 'New routine block';

  @override
  String get planTaskNameLabel => 'Task';

  @override
  String get planTaskNotesLabel => 'Notes (optional)';

  @override
  String get planTimeLabel => 'Time';

  @override
  String get planNoTime => 'No time';

  @override
  String get planDurationLabel => 'Duration in minutes';

  @override
  String planDurationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get planPriorityLabel => 'Priority';

  @override
  String get planPriorityLow => 'Low';

  @override
  String get planPriorityNormal => 'Normal';

  @override
  String get planPriorityHigh => 'High';

  @override
  String get planRepeatLabel => 'Repeat';

  @override
  String get planRepeatOnce => 'This day only';

  @override
  String get planRepeatWeekdays => 'Selected days';

  @override
  String get planRepeatOn => 'Repeat on';

  @override
  String get planRoutineNameLabel => 'Block name';

  @override
  String get planRoutineCategoryLabel => 'Area';

  @override
  String get planCategoryMind => 'Mind';

  @override
  String get planCategoryBody => 'Body';

  @override
  String get planCategoryFocus => 'Focus';

  @override
  String get planSaveTask => 'Save task';

  @override
  String get planSaveRoutine => 'Save block';

  @override
  String get planCancel => 'Cancel';

  @override
  String get planConflictTitle => 'Some times overlap';

  @override
  String get planConflictMessage =>
      'Review the items scheduled at the same time.';

  @override
  String planConflictPair(String first, String second) {
    return '$first ↔ $second';
  }

  @override
  String get planRemoveTime => 'Remove time';

  @override
  String planSuggestedSlot(String time) {
    return 'Open at $time';
  }

  @override
  String get planScheduleTask => 'Schedule task';

  @override
  String get planCompleteTask => 'Complete task';

  @override
  String get planTaskCompleted =>
      'Task completed. Your progress has been updated.';

  @override
  String get planTaskArchived => 'Task archived. Its history was preserved.';

  @override
  String get planRoutineArchived => 'Block archived.';

  @override
  String get planLoading => 'Loading your plan';

  @override
  String get planLoadError =>
      'Your plan could not be loaded. Your data is still on this device.';

  @override
  String get planSaveError =>
      'This could not be saved. Your data is still on this device.';

  @override
  String get planRetry => 'Try again';

  @override
  String get planTaskNoDate => 'No date set';

  @override
  String planPrioritySemantics(String priority) {
    return '$priority priority';
  }
}
