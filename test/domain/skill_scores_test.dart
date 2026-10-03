import 'package:flutter_test/flutter_test.dart';
import 'package:flowstate/domain/gamification/skill_scores.dart';

void main() {
  test(
    'calculates one deterministic 0–100 axis per active module with data',
    () {
      final scores = calculateSkillScores(
        activeModuleIds: const <String>{'workouts', 'habits', 'plan'},
        progress: const <SkillProgress>[
          SkillProgress(moduleId: 'habits', current: 3, target: 4),
          SkillProgress(moduleId: 'plan', current: 12, target: 10),
          SkillProgress(moduleId: 'workouts', current: 0, target: 5),
          SkillProgress(moduleId: 'focus', current: 7, target: 10),
        ],
      );

      expect(
        scores.map(
          (SkillScore score) => <String, int>{score.moduleId: score.score},
        ),
        <Map<String, int>>[
          <String, int>{'habits': 75},
          <String, int>{'plan': 100},
          <String, int>{'workouts': 0},
        ],
      );
      expect(() => scores.clear(), throwsUnsupportedError);
    },
  );

  test(
    'rejects invalid targets, progress and duplicate module measurements',
    () {
      expect(
        () => calculateSkillScores(
          activeModuleIds: const <String>{'habits'},
          progress: const <SkillProgress>[
            SkillProgress(moduleId: 'habits', current: 0, target: 0),
          ],
        ),
        throwsArgumentError,
      );
      expect(
        () => calculateSkillScores(
          activeModuleIds: const <String>{'habits'},
          progress: const <SkillProgress>[
            SkillProgress(moduleId: 'habits', current: 1, target: 2),
            SkillProgress(moduleId: 'habits', current: 2, target: 2),
          ],
        ),
        throwsArgumentError,
      );
    },
  );
}
