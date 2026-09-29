// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get designCatalogTitle => 'Catálogo visual';

  @override
  String get skillRadarTitle => 'Radar de habilidades';

  @override
  String get skillRadarDescription =>
      'Una vista previa visual con datos de ejemplo. El progreso real se calculará a partir de tu historial.';

  @override
  String get skillRadarAccessibleTitle => 'Radar de habilidades de ejemplo';

  @override
  String get skillConsistency => 'Constancia';

  @override
  String get skillFocus => 'Enfoque';

  @override
  String get skillPlanning => 'Planificación';

  @override
  String get skillEnergy => 'Energía';

  @override
  String get skillStrength => 'Fuerza';
}
