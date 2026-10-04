import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flowstate/domain/preferences/onboarding.dart';
import 'package:flowstate/domain/repositories/preferences_repository.dart';

final class OnboardingController extends ChangeNotifier {
  OnboardingController({required this.repository});

  static const String activeModulesKey = 'active_modules';
  final PreferencesRepository repository;

  Set<String> activeModules = FlowModule.values
      .map((FlowModule item) => item.id)
      .toSet();
  bool isLoading = false;
  bool isSaving = false;
  Object? error;

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final String? encoded = await repository.getValue(activeModulesKey);
      if (encoded != null) {
        final Object? decoded = jsonDecode(encoded);
        if (decoded is List<Object?>) {
          activeModules = normalizeActiveModules(decoded.whereType<String>());
        }
      }
    } on Object catch (caught) {
      error = caught;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void applyTemplate(OnboardingTemplate template) {
    activeModules = normalizeActiveModules(template.moduleIds);
    notifyListeners();
  }

  void toggle(String moduleId, bool enabled) {
    final Set<String> next = <String>{...activeModules};
    if (enabled) {
      next.add(moduleId);
    } else {
      next.remove(moduleId);
    }
    activeModules = normalizeActiveModules(next);
    notifyListeners();
  }

  Future<void> save() async {
    if (isSaving) return;
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final List<String> sorted = activeModules.toList()..sort();
      await repository.setValue(
        key: activeModulesKey,
        valueJson: jsonEncode(sorted),
      );
    } on Object catch (caught) {
      error = caught;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
