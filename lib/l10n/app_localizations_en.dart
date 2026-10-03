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
  String get todayLevelXp => 'Level 2 · 100 XP';

  @override
  String get todayProgressTitle => 'Done today';

  @override
  String get todayProgressValue => '3 of 7';

  @override
  String get nextActionTitle => 'Next action';

  @override
  String get nextActionTask => 'Take 10 minutes to set up your morning';

  @override
  String get completeAction => 'Complete';

  @override
  String get quickActionsTitle => 'Quick actions';

  @override
  String get newHabitAction => 'New habit';

  @override
  String get newTaskAction => 'New task';

  @override
  String get startFocusAction => 'Start focus';

  @override
  String get startWorkoutAction => 'Start workout';

  @override
  String get todayHabitsTitle => 'Today\'s habits';

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
}
