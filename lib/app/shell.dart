import 'package:flutter/material.dart';

import 'package:flowstate/design/components/app_bottom_nav.dart';
import 'package:flowstate/design/components/empty_state.dart';
import 'package:flowstate/design/components/sidebar_nav.dart';
import 'package:flowstate/design/tokens.dart';
import 'package:flowstate/core/app_constants.dart';
import 'package:flowstate/features/today/presentation/today_page.dart';
import 'package:flowstate/features/today/application/today_controller.dart';
import 'package:flowstate/features/habits/application/habits_controller.dart';
import 'package:flowstate/features/habits/presentation/habits_page.dart';
import 'package:flowstate/features/plan/application/plan_controller.dart';
import 'package:flowstate/features/plan/presentation/plan_page.dart';
import 'package:flowstate/features/focus/application/focus_controller.dart';
import 'package:flowstate/features/focus/presentation/focus_session_sheet.dart';
import 'package:flowstate/features/evolution/application/evolution_controller.dart';
import 'package:flowstate/features/evolution/presentation/evolution_page.dart';
import 'package:flowstate/features/workouts/application/workouts_controller.dart';
import 'package:flowstate/features/workouts/presentation/workouts_page.dart';
import 'package:flowstate/features/onboarding/application/onboarding_controller.dart';
import 'package:flowstate/features/onboarding/presentation/onboarding_page.dart';
import 'package:flowstate/l10n/app_localizations.dart';
import 'package:flowstate/l10n/app_localizations_pt.dart';

class AdaptiveShell extends StatefulWidget {
  const AdaptiveShell({
    required this.todayController,
    required this.habitsController,
    required this.planController,
    this.focusController,
    this.evolutionController,
    this.workoutsController,
    this.onboardingController,
    super.key,
  });

  final TodayController todayController;
  final HabitsController habitsController;
  final PlanController planController;
  final FocusController? focusController;
  final EvolutionController? evolutionController;
  final WorkoutsController? workoutsController;
  final OnboardingController? onboardingController;

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.onboardingController?.addListener(_handlePreferencesChanged);
  }

  @override
  void dispose() {
    widget.onboardingController?.removeListener(_handlePreferencesChanged);
    super.dispose();
  }

  void _handlePreferencesChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations =
        AppLocalizations.of(context) ?? AppLocalizationsPtBr();
    final bool planningActive = _moduleIsActive('planning');
    final bool habitsActive = _moduleIsActive('habits');
    final bool workoutsActive = _moduleIsActive('workouts');
    final List<String> labels = <String>[
      localizations.navToday,
      if (planningActive) localizations.navPlan,
      if (habitsActive) localizations.navHabits,
      if (workoutsActive) localizations.navWorkouts,
      localizations.navEvolution,
    ];
    final List<IconData> icons = <IconData>[
      Icons.today_outlined,
      if (planningActive) Icons.view_agenda_outlined,
      if (habitsActive) Icons.repeat_outlined,
      if (workoutsActive) Icons.fitness_center_outlined,
      Icons.insights_outlined,
    ];
    final int selectedIndex = _selectedIndex < labels.length
        ? _selectedIndex
        : 0;
    final EvolutionController? evolutionController = widget.evolutionController;
    final WorkoutsController? workoutsController = widget.workoutsController;
    final OnboardingController? onboardingController =
        widget.onboardingController;
    final List<Widget> pages = <Widget>[
      TodayPage(
        controller: widget.todayController,
        evolutionController: evolutionController,
        onStartFocus: widget.focusController == null
            ? null
            : () => _showFocus(context),
      ),
      if (planningActive)
        PlanPage(
          controller: widget.planController,
          onFocusTask: widget.focusController == null
              ? null
              : (task) => _showFocus(context, taskId: task.id),
        ),
      if (habitsActive) HabitsPage(controller: widget.habitsController),
      if (workoutsActive)
        workoutsController == null
            ? _ShellPlaceholder(label: localizations.navWorkouts)
            : WorkoutsPage(controller: workoutsController),
      evolutionController == null
          ? _ShellPlaceholder(label: localizations.navEvolution)
          : EvolutionPage(controller: evolutionController),
    ];
    final List<NavigationDestination> bottomDestinations =
        <NavigationDestination>[
          for (int index = 0; index < labels.length; index++)
            NavigationDestination(
              icon: Icon(icons[index]),
              selectedIcon: Icon(icons[index]),
              label: labels[index],
            ),
        ];
    final List<NavigationRailDestination> railDestinations =
        <NavigationRailDestination>[
          for (int index = 0; index < labels.length; index++)
            NavigationRailDestination(
              icon: Icon(icons[index]),
              selectedIcon: Icon(icons[index]),
              label: Text(labels[index]),
            ),
        ];

    return Scaffold(
      appBar: onboardingController == null
          ? null
          : AppBar(
              title: Text(labels[selectedIndex]),
              actions: <Widget>[
                IconButton(
                  tooltip: localizations.onboardingSettings,
                  onPressed: () => _showOnboarding(context),
                  icon: const Icon(Icons.tune_outlined),
                ),
              ],
            ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final Widget content = IndexedStack(
            index: selectedIndex,
            children: pages,
          );
          if (width >= FlowTokens.expandedBreakpoint) {
            return Row(
              children: <Widget>[
                SidebarNav(
                  currentIndex: selectedIndex,
                  onDestinationSelected: _select,
                  destinations: railDestinations,
                  brandLabel: AppConstants.appName,
                  settingsLabel: localizations.onboardingSettings,
                  onSettingsPressed: onboardingController == null
                      ? null
                      : () => _showOnboarding(context),
                ),
                Expanded(child: content),
              ],
            );
          }
          if (width >= FlowTokens.compactBreakpoint) {
            return Row(
              children: <Widget>[
                SidebarNav(
                  rail: true,
                  currentIndex: selectedIndex,
                  onDestinationSelected: _select,
                  destinations: railDestinations,
                ),
                Expanded(child: content),
              ],
            );
          }
          return Column(
            children: <Widget>[
              Expanded(child: content),
              AppBottomNav(
                currentIndex: selectedIndex,
                onDestinationSelected: _select,
                destinations: bottomDestinations,
              ),
            ],
          );
        },
      ),
    );
  }

  void _select(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool _moduleIsActive(String moduleId) {
    final OnboardingController? controller = widget.onboardingController;
    return controller == null || controller.activeModules.contains(moduleId);
  }

  Future<void> _showFocus(BuildContext context, {String? taskId}) async {
    final FocusController? controller = widget.focusController;
    if (controller == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) =>
          FocusSessionSheet(controller: controller, initialTaskId: taskId),
    );
  }

  Future<void> _showOnboarding(BuildContext context) async {
    final OnboardingController? controller = widget.onboardingController;
    if (controller == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) => OnboardingPage(controller: controller),
    );
  }
}

class _ShellPlaceholder extends StatelessWidget {
  const _ShellPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyState(
        title: label,
        message: (AppLocalizations.of(context) ?? AppLocalizationsPtBr())
            .shellComingSoon,
      ),
    );
  }
}
