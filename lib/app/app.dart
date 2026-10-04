import 'dart:async';

import 'package:flutter/material.dart';
import 'package:clock/clock.dart';

import 'package:flowstate/core/app_constants.dart';
import 'package:flowstate/core/ids.dart';
import 'package:flowstate/data/database/app_database.dart';
import 'package:flowstate/data/repositories/drift_repositories.dart';
import 'package:flowstate/design/theme.dart';
import 'package:flowstate/app/shell.dart';
import 'package:flowstate/features/today/application/today_controller.dart';
import 'package:flowstate/features/habits/application/habits_controller.dart';
import 'package:flowstate/features/plan/application/plan_controller.dart';
import 'package:flowstate/features/focus/application/focus_controller.dart';
import 'package:flowstate/features/evolution/application/evolution_controller.dart';
import 'package:flowstate/features/workouts/application/workouts_controller.dart';
import 'package:flowstate/features/onboarding/application/onboarding_controller.dart';
import 'package:flowstate/l10n/app_localizations.dart';

class FlowStateApp extends StatefulWidget {
  const FlowStateApp({this.database, super.key});

  final AppDatabase? database;

  @override
  State<FlowStateApp> createState() => _FlowStateAppState();
}

class _FlowStateAppState extends State<FlowStateApp> {
  late final AppDatabase _database = widget.database ?? AppDatabase.open();
  late final String _deviceId = newId();
  late final TodayController _todayController = TodayController(
    habitRepository: DriftHabitRepository(_database),
    taskRepository: DriftTaskRepository(_database),
    routineRepository: DriftRoutineRepository(_database),
    xpRepository: DriftXpRepository(_database),
    clock: Clock(),
    deviceId: _deviceId,
  );
  late final HabitsController _habitsController = HabitsController(
    habitRepository: DriftHabitRepository(_database),
    xpRepository: DriftXpRepository(_database),
    clock: Clock(),
    deviceId: _deviceId,
    onDataChanged: _todayController.load,
  );
  late final PlanController _planController = PlanController(
    taskRepository: DriftTaskRepository(_database),
    routineRepository: DriftRoutineRepository(_database),
    xpRepository: DriftXpRepository(_database),
    clock: Clock(),
    deviceId: _deviceId,
    onDataChanged: _todayController.load,
  );
  late final FocusController _focusController = FocusController(
    focusRepository: DriftFocusRepository(_database),
    taskRepository: DriftTaskRepository(_database),
    xpRepository: DriftXpRepository(_database),
    clock: Clock(),
    deviceId: _deviceId,
    onDataChanged: _todayController.load,
  );
  late final EvolutionController _evolutionController = EvolutionController(
    habitRepository: DriftHabitRepository(_database),
    taskRepository: DriftTaskRepository(_database),
    focusRepository: DriftFocusRepository(_database),
    xpRepository: DriftXpRepository(_database),
    clock: Clock(),
  );
  late final WorkoutsController _workoutsController = WorkoutsController(
    repository: DriftWorkoutRepository(_database),
    xpRepository: DriftXpRepository(_database),
    clock: Clock(),
    deviceId: _deviceId,
    onDataChanged: _todayController.load,
  );
  late final OnboardingController _onboardingController = OnboardingController(
    repository: DriftPreferencesRepository(
      database: _database,
      clock: Clock(),
      deviceId: _deviceId,
    ),
  );

  @override
  void initState() {
    super.initState();
    unawaited(_focusController.load());
    unawaited(_evolutionController.load());
    unawaited(_workoutsController.load());
    unawaited(_onboardingController.load());
  }

  @override
  void dispose() {
    _todayController.dispose();
    _habitsController.dispose();
    _planController.dispose();
    _focusController.dispose();
    _evolutionController.dispose();
    _workoutsController.dispose();
    _onboardingController.dispose();
    unawaited(_database.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: FlowTheme.light(),
      darkTheme: FlowTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AdaptiveShell(
        todayController: _todayController,
        habitsController: _habitsController,
        planController: _planController,
        focusController: _focusController,
        evolutionController: _evolutionController,
        workoutsController: _workoutsController,
        onboardingController: _onboardingController,
      ),
    );
  }
}
