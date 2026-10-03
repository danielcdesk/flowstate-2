/// Progress against a user's chosen target for one module.
final class SkillProgress {
  const SkillProgress({
    required this.moduleId,
    required this.current,
    required this.target,
  });

  final String moduleId;
  final int current;
  final int target;
}

/// A normalized radar axis. Scores are bounded to the visual scale 0–100.
final class SkillScore {
  const SkillScore({required this.moduleId, required this.score});

  final String moduleId;
  final int score;
}

/// Calculates radar axes from domain progress, excluding inactive modules.
///
/// [current] is supplied by selectors over actual records; this function does
/// not persist progress or award points. Each included target must be positive.
List<SkillScore> calculateSkillScores({
  required Set<String> activeModuleIds,
  required Iterable<SkillProgress> progress,
}) {
  final Map<String, SkillProgress> byModule = <String, SkillProgress>{};
  for (final SkillProgress item in progress) {
    if (item.moduleId.trim().isEmpty || item.current < 0 || item.target < 1) {
      throw ArgumentError('Skill progress is outside valid ranges.');
    }
    if (byModule.containsKey(item.moduleId)) {
      throw ArgumentError.value(item.moduleId, 'progress', 'Duplicate module.');
    }
    byModule[item.moduleId] = item;
  }

  final List<String> modules = activeModuleIds.toList()..sort();
  final List<SkillScore> scores = <SkillScore>[];
  for (final String moduleId in modules) {
    final SkillProgress? item = byModule[moduleId];
    if (item == null) continue;
    final int boundedCurrent = item.current > item.target
        ? item.target
        : item.current;
    scores.add(
      SkillScore(
        moduleId: moduleId,
        score: (boundedCurrent * 100 / item.target).round(),
      ),
    );
  }
  return List<SkillScore>.unmodifiable(scores);
}
