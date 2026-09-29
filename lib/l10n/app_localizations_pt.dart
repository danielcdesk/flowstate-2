// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get designCatalogTitle => 'Catálogo visual';

  @override
  String get skillRadarTitle => 'Radar de habilidades';

  @override
  String get skillRadarDescription =>
      'Uma prévia visual com dados falsos. A evolução real será calculada a partir do seu histórico.';

  @override
  String get skillRadarAccessibleTitle => 'Radar de habilidades de exemplo';

  @override
  String get skillConsistency => 'Constância';

  @override
  String get skillFocus => 'Foco';

  @override
  String get skillPlanning => 'Planejamento';

  @override
  String get skillEnergy => 'Energia';

  @override
  String get skillStrength => 'Força';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');
}
