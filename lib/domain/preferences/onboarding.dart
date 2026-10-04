enum FlowModule { habits, planning, focus, workouts }

extension FlowModuleId on FlowModule {
  String get id => switch (this) {
    FlowModule.habits => 'habits',
    FlowModule.planning => 'planning',
    FlowModule.focus => 'focus',
    FlowModule.workouts => 'workouts',
  };
}

final class OnboardingTemplate {
  const OnboardingTemplate({required this.id, required this.moduleIds});

  final String id;
  final Set<String> moduleIds;
}

const List<OnboardingTemplate> onboardingTemplates = <OnboardingTemplate>[
  OnboardingTemplate(
    id: 'productive_morning',
    moduleIds: <String>{'habits', 'planning', 'focus'},
  ),
  OnboardingTemplate(
    id: 'beginner_strength',
    moduleIds: <String>{'habits', 'planning', 'workouts'},
  ),
];

Set<String> normalizeActiveModules(Iterable<String> moduleIds) {
  final Set<String> allowed = FlowModule.values
      .map((FlowModule item) => item.id)
      .toSet();
  final Set<String> normalized = moduleIds.where(allowed.contains).toSet();
  return Set<String>.unmodifiable(normalized);
}
