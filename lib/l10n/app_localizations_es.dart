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

  @override
  String get todayGreeting => 'Buenos días';

  @override
  String get todaySubtitle => 'Hoy, lo mínimo también cuenta.';

  @override
  String todayLevelXp(int level, int xp) {
    return 'Nivel $level · $xp XP';
  }

  @override
  String get todayProgressTitle => 'Hecho hoy';

  @override
  String todayProgressValue(int completed, int total) {
    return '$completed de $total';
  }

  @override
  String get todayLoadError =>
      'No se pudo cargar tu día. Tus datos siguen en este dispositivo.';

  @override
  String get todayActionError =>
      'No se pudo guardar esta acción. Tus datos siguen en este dispositivo.';

  @override
  String get retryAction => 'Intentar de nuevo';

  @override
  String get nextActionTitle => 'Siguiente acción';

  @override
  String get nextActionEmpty =>
      'Todo en orden por ahora. Añade un hábito o una tarea para empezar.';

  @override
  String get nextActionTask => 'Tómate 10 minutos para preparar la mañana';

  @override
  String get completeAction => 'Completar';

  @override
  String get quickActionsTitle => 'Acciones rápidas';

  @override
  String get newHabitAction => 'Crear hábito';

  @override
  String get newTaskAction => 'Crear tarea';

  @override
  String get quickActionComingSoon =>
      'Este acceso se conectará en una próxima etapa.';

  @override
  String get actionCompleted => 'Hecho. Tu progreso se ha actualizado.';

  @override
  String get undoAction => 'Deshacer';

  @override
  String get startFocusAction => 'Iniciar enfoque';

  @override
  String get startWorkoutAction => 'Iniciar entrenamiento';

  @override
  String get todayHabitsTitle => 'Hábitos de hoy';

  @override
  String get todayHabitsEmptyTitle => 'No hay hábitos para hoy';

  @override
  String get todayHabitsEmptyMessage =>
      'Tus hábitos aparecerán aquí cuando estén configurados.';

  @override
  String get habitTapToComplete => 'Toca para marcar como completado';

  @override
  String get completedStatus => 'Completado';

  @override
  String daysStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
      zero: 'Empezando',
    );
    return '$_temp0';
  }

  @override
  String get habitMorning => 'Respirar durante 2 minutos';

  @override
  String get habitMorningCue => 'Después de abrir la ventana';

  @override
  String get habitMorningStreak => '3 días';

  @override
  String get habitReading => 'Leer 10 páginas';

  @override
  String get habitReadingCue => 'Después del café';

  @override
  String get habitReadingStreak => '5 días';

  @override
  String get timelineTitle => 'Línea de tiempo';

  @override
  String get timelineEmpty =>
      'Aún no hay bloques. Cuando planifiques algo, aparecerá aquí.';

  @override
  String get welcomeTitle => 'Tu día en un solo lugar.';

  @override
  String get welcomeDescription =>
      'Hábitos, tareas, rutinas y entrenamientos — con amabilidad en los días difíciles.';

  @override
  String get continueAction => 'Empezar';

  @override
  String get backupLink => 'Ya tengo una copia de seguridad';

  @override
  String get localDataNote => 'Tus datos permanecen en este dispositivo.';

  @override
  String get navToday => 'Hoy';

  @override
  String get navPlan => 'Plan';

  @override
  String get navHabits => 'Hábitos';

  @override
  String get navWorkouts => 'Entrenamientos';

  @override
  String get navEvolution => 'Evolución';

  @override
  String get shellComingSoon =>
      'Este destino se conectará en una fase posterior.';

  @override
  String get flowRingSemanticLabel => 'Progreso del día';
}
