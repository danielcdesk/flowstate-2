import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flowstate/design/components/app_button.dart';
import 'package:flowstate/design/components/flow_ring.dart';
import 'package:flowstate/design/tokens.dart';
import 'package:flowstate/domain/focus/focus_session.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';
import 'package:flowstate/domain/tasks/task.dart';
import 'package:flowstate/features/focus/application/focus_controller.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class FocusSessionSheet extends StatefulWidget {
  const FocusSessionSheet({
    required this.controller,
    this.initialTaskId,
    super.key,
  });

  final FocusController controller;
  final String? initialTaskId;

  @override
  State<FocusSessionSheet> createState() => _FocusSessionSheetState();
}

class _FocusSessionSheetState extends State<FocusSessionSheet> {
  final TextEditingController _customMinutesController = TextEditingController(
    text: '30',
  );
  _FocusPreset _preset = _FocusPreset.twentyFive;
  String? _taskId;

  @override
  void initState() {
    super.initState();
    _taskId = widget.initialTaskId;
    widget.controller.addListener(_handleControllerChange);
    unawaited(widget.controller.load());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    _customMinutesController.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n =
        AppLocalizations.of(context) ?? AppLocalizationsPtBr();
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: FlowTokens.focusSheetMaxWidth,
          ),
          child: SingleChildScrollView(
            padding: FlowTokens.focusSheetPadding,
            child: _buildContent(context, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    if (widget.controller.isLoading && widget.controller.tasks.isEmpty) {
      return Semantics(
        label: l10n.focusLoading,
        child: const Padding(
          padding: FlowTokens.focusLoadingPadding,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (widget.controller.error != null &&
        widget.controller.failedToLoad &&
        widget.controller.activeSession == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(l10n.focusLoadError),
          const SizedBox(height: FlowTokens.space4),
          AppButton(label: l10n.retryAction, onPressed: widget.controller.load),
        ],
      );
    }
    final FocusSession? active = widget.controller.activeSession;
    if (active != null) return _buildActiveSession(context, l10n, active);
    return _buildSetup(context, l10n);
  }

  Widget _buildSetup(BuildContext context, AppLocalizations l10n) {
    final FocusSession? completed = widget.controller.completedSession;
    final int? duration = _selectedDuration;
    final String selectedTaskId =
        widget.controller.tasks.any((Task task) => task.id == _taskId)
        ? _taskId ?? ''
        : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(l10n.focusTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: FlowTokens.space2),
        Text(l10n.focusIntro),
        if (completed != null) ...<Widget>[
          const SizedBox(height: FlowTokens.space4),
          Semantics(
            liveRegion: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.focusCompletedSummary(completed.durationMinutes),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (widget.controller.completedSessionXp > 0) ...<Widget>[
                  const SizedBox(height: FlowTokens.space2),
                  Text(
                    l10n.focusXpEarned(widget.controller.completedSessionXp),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: FlowTokens.space6),
        Text(
          l10n.focusChooseDuration,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: FlowTokens.space3),
        Text(
          l10n.focusXpPolicy(
            XpPolicy.minFocusMinutes,
            XpPolicy.focusSession,
            XpPolicy.maxFocusAwardsPerDay,
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: FlowTokens.space3),
        Wrap(
          spacing: FlowTokens.space2,
          runSpacing: FlowTokens.space2,
          children: <Widget>[
            ChoiceChip(
              label: Text(l10n.focusDurationPreset(25)),
              selected: _preset == _FocusPreset.twentyFive,
              onSelected: (_) => setState(() {
                _preset = _FocusPreset.twentyFive;
              }),
            ),
            ChoiceChip(
              label: Text(l10n.focusDurationPreset(50)),
              selected: _preset == _FocusPreset.fifty,
              onSelected: (_) => setState(() {
                _preset = _FocusPreset.fifty;
              }),
            ),
            ChoiceChip(
              label: Text(l10n.focusCustomDuration),
              selected: _preset == _FocusPreset.custom,
              onSelected: (_) => setState(() {
                _preset = _FocusPreset.custom;
              }),
            ),
          ],
        ),
        if (_preset == _FocusPreset.custom) ...<Widget>[
          const SizedBox(height: FlowTokens.space3),
          TextFormField(
            controller: _customMinutesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.focusDurationField,
              suffixText: l10n.focusMinutesUnit,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: FlowTokens.space2),
          Text(
            l10n.focusDurationLimit(FocusSession.maxFocusDurationMinutes),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: FlowTokens.space6),
        DropdownButtonFormField<String>(
          initialValue: selectedTaskId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.focusLinkTask,
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(value: '', child: Text(l10n.focusNoTask)),
            for (final Task task in widget.controller.tasks)
              DropdownMenuItem<String>(value: task.id, child: Text(task.title)),
          ],
          onChanged: (String? value) => setState(() {
            _taskId = value == null || value.isEmpty ? null : value;
          }),
        ),
        const SizedBox(height: FlowTokens.space3),
        Text(
          l10n.focusLocalPersistence,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (widget.controller.error != null) ...<Widget>[
          const SizedBox(height: FlowTokens.space3),
          Text(l10n.focusSaveError),
        ],
        const SizedBox(height: FlowTokens.space6),
        AppButton(
          label: l10n.focusStart,
          onPressed: duration == null || widget.controller.isSaving
              ? null
              : () => widget.controller.startSession(
                  durationMinutes: duration,
                  taskId: _taskId,
                ),
        ),
      ],
    );
  }

  Widget _buildActiveSession(
    BuildContext context,
    AppLocalizations l10n,
    FocusSession session,
  ) {
    final Duration remaining = widget.controller.remaining;
    final int minutes = remaining.inMinutes;
    final int seconds = remaining.inSeconds.remainder(60);
    final NumberFormat twoDigits = NumberFormat('00');
    final String countdown = l10n.focusCountdown(
      twoDigits.format(minutes),
      twoDigits.format(seconds),
    );
    final double progress =
        1 - remaining.inSeconds / (session.durationMinutes * 60);
    final String? taskTitle = _taskTitle(session.taskId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.focusInProgress,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: FlowTokens.space2),
        Text(taskTitle ?? l10n.focusNoTaskActive),
        const SizedBox(height: FlowTokens.space6),
        Center(
          child: FlowRing(
            progress: progress,
            size: FlowTokens.focusTimerSize,
            semanticLabel: l10n.focusTimerSemantics(countdown),
            centerLabel: countdown,
          ),
        ),
        const SizedBox(height: FlowTokens.space6),
        Text(
          l10n.focusKeepsRunning,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (widget.controller.error != null) ...<Widget>[
          const SizedBox(height: FlowTokens.space3),
          Text(l10n.focusSaveError),
        ],
        const SizedBox(height: FlowTokens.space6),
        AppButton(
          label: l10n.focusStop,
          secondary: true,
          onPressed: widget.controller.isSaving
              ? null
              : () => _confirmStop(context, l10n),
        ),
      ],
    );
  }

  Future<void> _confirmStop(BuildContext context, AppLocalizations l10n) async {
    final bool shouldStop =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(l10n.focusStopConfirmationTitle),
            content: Text(l10n.focusStopConfirmationMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.planCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.focusStop),
              ),
            ],
          ),
        ) ??
        false;
    if (shouldStop) await widget.controller.stopSession();
  }

  int? get _selectedDuration {
    switch (_preset) {
      case _FocusPreset.twentyFive:
        return 25;
      case _FocusPreset.fifty:
        return 50;
      case _FocusPreset.custom:
        final int? value = int.tryParse(_customMinutesController.text);
        if (value == null ||
            value < 1 ||
            value > FocusSession.maxFocusDurationMinutes) {
          return null;
        }
        return value;
    }
  }

  String? _taskTitle(String? taskId) {
    if (taskId == null) return null;
    for (final Task task in widget.controller.tasks) {
      if (task.id == taskId) return task.title;
    }
    return null;
  }
}

enum _FocusPreset { twentyFive, fifty, custom }
