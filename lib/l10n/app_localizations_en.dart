// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get designCatalogTitle => 'Visual catalog';

  @override
  String get skillRadarTitle => 'Skill radar';

  @override
  String get skillRadarDescription =>
      'A visual preview with sample data. Real progress will be calculated from your history.';

  @override
  String get skillRadarAccessibleTitle => 'Sample skill radar';

  @override
  String get skillConsistency => 'Consistency';

  @override
  String get skillFocus => 'Focus';

  @override
  String get skillPlanning => 'Planning';

  @override
  String get skillEnergy => 'Energy';

  @override
  String get skillStrength => 'Strength';
}
