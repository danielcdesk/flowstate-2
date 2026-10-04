import 'package:flutter_test/flutter_test.dart';

import 'package:flowstate/domain/preferences/onboarding.dart';
import 'package:flowstate/domain/repositories/preferences_repository.dart';
import 'package:flowstate/features/onboarding/application/onboarding_controller.dart';

void main() {
  test('loads, applies a template and saves module preferences', () async {
    final _MemoryPreferences preferences = _MemoryPreferences();
    final OnboardingController controller = OnboardingController(
      repository: preferences,
    );

    await controller.load();
    controller.applyTemplate(onboardingTemplates.last);
    await controller.save();

    expect(controller.activeModules, contains(FlowModule.workouts.id));
    expect(
      preferences.values[OnboardingController.activeModulesKey],
      isNotNull,
    );
    controller.dispose();
  });
}

final class _MemoryPreferences implements PreferencesRepository {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> getValue(String key) async => values[key];

  @override
  Future<void> setValue({
    required String key,
    required String valueJson,
  }) async {
    values[key] = valueJson;
  }
}
