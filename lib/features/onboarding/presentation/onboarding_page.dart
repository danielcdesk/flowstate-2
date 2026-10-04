import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flowstate/design/components/app_button.dart';
import 'package:flowstate/design/tokens.dart';
import 'package:flowstate/domain/preferences/onboarding.dart';
import 'package:flowstate/features/onboarding/application/onboarding_controller.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.controller, super.key});

  final OnboardingController controller;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
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
    final OnboardingController controller = widget.controller;
    if (controller.isLoading) {
      return Semantics(
        label: l10n.onboardingLoading,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return SafeArea(
      child: SingleChildScrollView(
        padding: FlowTokens.focusSheetPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.onboardingTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: FlowTokens.space2),
            Text(l10n.onboardingSubtitle),
            const SizedBox(height: FlowTokens.space6),
            Text(
              l10n.onboardingTemplatesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: FlowTokens.space2),
            for (final OnboardingTemplate template in onboardingTemplates)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.auto_awesome_outlined),
                title: Text(_templateTitle(l10n, template.id)),
                subtitle: Text(_templateDescription(l10n, template.id)),
                onTap: () => controller.applyTemplate(template),
              ),
            const SizedBox(height: FlowTokens.space4),
            Text(
              l10n.onboardingModulesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final FlowModule module in FlowModule.values)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.activeModules.contains(module.id),
                title: Text(_moduleTitle(l10n, module)),
                subtitle: Text(_moduleDescription(l10n, module)),
                onChanged: (bool? value) =>
                    controller.toggle(module.id, value ?? false),
              ),
            if (controller.error != null) ...<Widget>[
              const SizedBox(height: FlowTokens.space2),
              Text(l10n.onboardingSaveError),
            ],
            const SizedBox(height: FlowTokens.space4),
            AppButton(
              label: l10n.onboardingSave,
              onPressed: controller.isSaving
                  ? null
                  : () async {
                      await controller.save();
                      if (context.mounted && controller.error == null) {
                        Navigator.of(context).pop();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  String _templateTitle(AppLocalizations l10n, String id) => switch (id) {
    'productive_morning' => l10n.onboardingTemplateMorning,
    'beginner_strength' => l10n.onboardingTemplateStrength,
    _ => id,
  };

  String _templateDescription(AppLocalizations l10n, String id) => switch (id) {
    'productive_morning' => l10n.onboardingTemplateMorningDescription,
    'beginner_strength' => l10n.onboardingTemplateStrengthDescription,
    _ => '',
  };

  String _moduleTitle(AppLocalizations l10n, FlowModule module) =>
      switch (module) {
        FlowModule.habits => l10n.onboardingModuleHabits,
        FlowModule.planning => l10n.onboardingModulePlanning,
        FlowModule.focus => l10n.onboardingModuleFocus,
        FlowModule.workouts => l10n.onboardingModuleWorkouts,
      };

  String _moduleDescription(AppLocalizations l10n, FlowModule module) =>
      switch (module) {
        FlowModule.habits => l10n.onboardingModuleHabitsDescription,
        FlowModule.planning => l10n.onboardingModulePlanningDescription,
        FlowModule.focus => l10n.onboardingModuleFocusDescription,
        FlowModule.workouts => l10n.onboardingModuleWorkoutsDescription,
      };
}
