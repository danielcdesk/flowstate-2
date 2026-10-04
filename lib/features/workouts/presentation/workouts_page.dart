import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flowstate/design/components/app_button.dart';
import 'package:flowstate/design/components/empty_state.dart';
import 'package:flowstate/design/tokens.dart';
import 'package:flowstate/domain/workouts/workout.dart';
import 'package:flowstate/features/workouts/application/workouts_controller.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({required this.controller, super.key});

  final WorkoutsController controller;

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
    unawaited(widget.controller.load());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n =
        AppLocalizations.of(context) ?? AppLocalizationsPtBr();
    final WorkoutsController controller = widget.controller;
    if (controller.isLoading && controller.plans.isEmpty) {
      return Semantics(
        label: l10n.workoutsLoading,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.error != null && controller.plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.workoutsLoadError, textAlign: TextAlign.center),
            const SizedBox(height: FlowTokens.space4),
            AppButton(label: l10n.retryAction, onPressed: controller.load),
          ],
        ),
      );
    }
    final WorkoutSession? active = controller.activeSession;
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: FlowTokens.pagePadding,
        children: <Widget>[
          Text(
            l10n.workoutsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: FlowTokens.space2),
          Text(l10n.workoutsSubtitle),
          const SizedBox(height: FlowTokens.space6),
          if (active != null)
            _buildActive(context, l10n, active)
          else if (controller.plans.isEmpty)
            _buildEmpty(context, l10n)
          else
            ...controller.plans.map(
              (WorkoutPlan plan) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.fitness_center_outlined),
                title: Text(plan.title),
                subtitle: Text(
                  l10n.workoutsExerciseCount(plan.exerciseIds.length),
                ),
                trailing: IconButton(
                  tooltip: l10n.workoutsStart,
                  onPressed: controller.isSaving
                      ? null
                      : () => controller.startSession(plan),
                  icon: const Icon(Icons.play_arrow_outlined),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: <Widget>[
        EmptyState(
          title: l10n.workoutsEmptyTitle,
          message: l10n.workoutsEmptyMessage,
        ),
        AppButton(
          label: l10n.workoutsCreateStarter,
          onPressed: widget.controller.isSaving
              ? null
              : () => widget.controller.createStarterPlan(
                  title: l10n.workoutsStarterTitle,
                ),
        ),
      ],
    );
  }

  Widget _buildActive(
    BuildContext context,
    AppLocalizations l10n,
    WorkoutSession session,
  ) {
    final WorkoutsController controller = widget.controller;
    final String exerciseId = controller.activeSets.isEmpty
        ? defaultWorkoutExercises.first.id
        : controller.activeSets.last.exerciseId;
    final WorkoutExercise exercise = defaultWorkoutExercises.firstWhere(
      (WorkoutExercise item) => item.id == exerciseId,
      orElse: () => defaultWorkoutExercises.first,
    );
    final int seconds = controller.restRemaining.inSeconds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.workoutsInProgress,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: FlowTokens.space2),
        Text(l10n.workoutsElapsed(session.startedAt.toLocal().toString())),
        const SizedBox(height: FlowTokens.space4),
        Text(l10n.workoutsSetCount(controller.activeSets.length)),
        if (seconds > 0) ...<Widget>[
          const SizedBox(height: FlowTokens.space2),
          Semantics(
            liveRegion: true,
            child: Text(l10n.workoutsRestRemaining(seconds)),
          ),
        ],
        const SizedBox(height: FlowTokens.space4),
        AppButton(
          label: l10n.workoutsRecordSet(exercise.name),
          onPressed: controller.isSaving
              ? null
              : () => controller.recordSet(
                  exerciseId: exercise.id,
                  repetitions: 8,
                  loadKg: 0,
                  restSeconds: 90,
                ),
        ),
        const SizedBox(height: FlowTokens.space2),
        AppButton(
          label: l10n.workoutsFinish,
          secondary: true,
          onPressed: controller.isSaving ? null : controller.finishSession,
        ),
      ],
    );
  }
}
