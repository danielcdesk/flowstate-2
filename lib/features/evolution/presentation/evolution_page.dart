import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flowstate/design/components/app_button.dart';
import 'package:flowstate/design/components/empty_state.dart';
import 'package:flowstate/design/components/hairline_section.dart';
import 'package:flowstate/design/components/skill_radar.dart';
import 'package:flowstate/design/tokens.dart';
import 'package:flowstate/domain/evolution/evolution.dart';
import 'package:flowstate/domain/insights/weekly_review.dart';
import 'package:flowstate/features/evolution/application/evolution_controller.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class EvolutionPage extends StatefulWidget {
  const EvolutionPage({required this.controller, super.key});

  final EvolutionController controller;

  @override
  State<EvolutionPage> createState() => _EvolutionPageState();
}

class _EvolutionPageState extends State<EvolutionPage> {
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
    final EvolutionController controller = widget.controller;
    if (controller.isLoading && controller.radar.isEmpty) {
      return Semantics(
        label: l10n.evolutionLoading,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.failedToLoad && controller.radar.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.evolutionLoadError, textAlign: TextAlign.center),
            const SizedBox(height: FlowTokens.space4),
            AppButton(label: l10n.retryAction, onPressed: controller.load),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: FlowTokens.pagePadding,
        children: <Widget>[
          Text(
            l10n.evolutionTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: FlowTokens.space2),
          Text(l10n.evolutionSubtitle),
          const SizedBox(height: FlowTokens.space6),
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.evolutionLevelXp(controller.level, controller.totalXp),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: FlowTokens.space6),
          HairlineSection(
            title: l10n.evolutionRadarTitle,
            child: SkillRadar(
              title: l10n.evolutionRadarAccessible,
              metrics: controller.radar
                  .map(
                    (score) => SkillRadarMetric(
                      label: _moduleLabel(l10n, score.moduleId),
                      value: score.score.toDouble(),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: FlowTokens.space6),
          HairlineSection(
            title: l10n.evolutionWeeklyTitle,
            child: controller.weeklyReview.isReady
                ? _buildInsights(
                    context,
                    l10n,
                    controller.weeklyReview.insights,
                  )
                : EmptyState(
                    title: l10n.evolutionWeeklyEmptyTitle,
                    message: l10n.evolutionWeeklyEmptyMessage,
                  ),
          ),
          const SizedBox(height: FlowTokens.space6),
          HairlineSection(
            title: l10n.evolutionAnnualTitle(controller.annual.year),
            child: _buildAnnual(context, l10n, controller.annual),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(
    BuildContext context,
    AppLocalizations l10n,
    List<WeeklyInsight> insights,
  ) {
    if (insights.isEmpty) return Text(l10n.evolutionWeeklyNoInsights);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: insights.map((WeeklyInsight insight) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.insights_outlined),
          title: Text(_insightLabel(l10n, insight.kind)),
          subtitle: Text(_insightValue(l10n, insight)),
        );
      }).toList(),
    );
  }

  Widget _buildAnnual(
    BuildContext context,
    AppLocalizations l10n,
    AnnualRetrospective annual,
  ) {
    if (!annual.isUnlocked) {
      return Semantics(
        label: l10n.evolutionAnnualLocked,
        child: EmptyState(
          title: l10n.evolutionAnnualLockedTitle,
          message: l10n.evolutionAnnualLockedMessage(annual.year + 1),
        ),
      );
    }
    if (annual.events.isEmpty) {
      return EmptyState(
        title: l10n.evolutionAnnualEmptyTitle,
        message: l10n.evolutionAnnualEmptyMessage,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: annual.events.map((EvolutionTimelineEvent event) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(_eventIcon(event.kind)),
          title: Text(
            event.title.isEmpty
                ? _eventLabel(l10n, event.kind, event.value)
                : event.title,
          ),
          subtitle: Text(l10n.evolutionEventDate(event.date.toString())),
        );
      }).toList(),
    );
  }

  String _moduleLabel(AppLocalizations l10n, String moduleId) {
    return switch (moduleId) {
      'habits' => l10n.evolutionSkillHabits,
      'planning' => l10n.evolutionSkillPlanning,
      'focus' => l10n.evolutionSkillFocus,
      _ => moduleId,
    };
  }

  String _insightLabel(AppLocalizations l10n, WeeklyInsightKind kind) {
    return switch (kind) {
      WeeklyInsightKind.strongestWeekday => l10n.evolutionInsightStrongestDay,
      WeeklyInsightKind.mostMissedHabit => l10n.evolutionInsightMostMissedHabit,
      WeeklyInsightKind.typicalHabitTime => l10n.evolutionInsightTypicalTime,
      WeeklyInsightKind.bestFocusHour => l10n.evolutionInsightBestFocus,
      WeeklyInsightKind.workoutRecoveryBalance => l10n.evolutionInsightBalance,
    };
  }

  String _insightValue(AppLocalizations l10n, WeeklyInsight insight) {
    return switch (insight.kind) {
      WeeklyInsightKind.strongestWeekday => l10n.evolutionInsightWeekdayValue(
        insight.value,
      ),
      WeeklyInsightKind.mostMissedHabit => insight.value,
      WeeklyInsightKind.typicalHabitTime => l10n.evolutionInsightMinuteValue(
        insight.value,
      ),
      WeeklyInsightKind.bestFocusHour => l10n.evolutionInsightHourValue(
        insight.value,
      ),
      WeeklyInsightKind.workoutRecoveryBalance =>
        l10n.evolutionInsightBalanceValue(
          int.tryParse(insight.value) ?? 0,
          insight.secondaryValue ?? 0,
        ),
    };
  }

  String _eventLabel(
    AppLocalizations l10n,
    EvolutionEventKind kind,
    int? value,
  ) {
    return switch (kind) {
      EvolutionEventKind.habit => l10n.evolutionEventHabit,
      EvolutionEventKind.task => l10n.evolutionEventTask,
      EvolutionEventKind.focus => l10n.evolutionEventFocus(value ?? 0),
      EvolutionEventKind.milestone => l10n.evolutionEventMilestone,
    };
  }

  IconData _eventIcon(EvolutionEventKind kind) {
    return switch (kind) {
      EvolutionEventKind.habit => Icons.repeat_outlined,
      EvolutionEventKind.task => Icons.check_circle_outline,
      EvolutionEventKind.focus => Icons.timer_outlined,
      EvolutionEventKind.milestone => Icons.emoji_events_outlined,
    };
  }
}
