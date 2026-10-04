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

  @override
  void dispose() {
    _todayController.dispose();
    _habitsController.dispose();
    _planController.dispose();
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
      ),
    );
  }
}
