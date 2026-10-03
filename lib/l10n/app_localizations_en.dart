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
}
