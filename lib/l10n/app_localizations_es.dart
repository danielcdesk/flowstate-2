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

  @override
  String get habitsScreenTitle => 'Tus hábitos';

  @override
  String get habitsListSectionTitle => 'Tu ritmo';

  @override
  String get habitsScreenSubtitle => 'Pequeños pasos, a tu ritmo.';

  @override
  String get habitsCreateAction => 'Crear hábito';

  @override
  String get habitsEmptyTitle => 'Empieza con un pequeño paso';

  @override
  String get habitsEmptyMessage =>
      'Elige algo sencillo que quieras repetir. Puedes ajustarlo después.';

  @override
  String get habitsLoading => 'Cargando tus hábitos';

  @override
  String get habitsLoadError =>
      'No se pudieron cargar tus hábitos. Tus datos siguen en este dispositivo.';

  @override
  String get habitsErrorTitle => 'No se pudieron cargar tus hábitos ahora';

  @override
  String get habitsSaveError =>
      'No se pudo guardar el hábito. Tus datos siguen en este dispositivo.';

  @override
  String get habitsRetryAction => 'Intentar de nuevo';

  @override
  String get habitsStreakLabel => 'Racha actual';

  @override
  String get habitsWeekLabel => 'Esta semana';

  @override
  String habitsWeekProgress(int completed, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: '$target veces',
      one: '1 vez',
    );
    return '$completed de $_temp0';
  }

  @override
  String habitsWeeklyTargetOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces por semana',
      one: '1 vez por semana',
    );
    return '$_temp0';
  }

  @override
  String get habitsLogFullAction => 'Marcar como hecho';

  @override
  String get habitsLogMinimumAction => 'Hacer la versión mínima';

  @override
  String get habitsEditAction => 'Editar hábito';

  @override
  String get habitsArchiveAction => 'Archivar hábito';

  @override
  String get habitsArchivedMessage =>
      'Hábito archivado. El historial se conservó.';

  @override
  String get habitsCreateTitle => 'Crear hábito';

  @override
  String get habitsEditTitle => 'Editar hábito';

  @override
  String get habitsNameLabel => 'Nombre del hábito';

  @override
  String get habitsNameHint => 'Ej.: Leer durante 10 minutos';

  @override
  String get habitsIconLabel => 'Icono';

  @override
  String get habitsCategoryLabel => 'Área';

  @override
  String get habitsCategoryMind => 'Mente';

  @override
  String get habitsCategoryBody => 'Cuerpo';

  @override
  String get habitsCategoryFocus => 'Enfoque';

  @override
  String get habitsFrequencyLabel => 'Frecuencia';

  @override
  String get habitsFrequencyDaily => 'Todos los días';

  @override
  String get habitsFrequencyWeekdays => 'Días elegidos';

  @override
  String get habitsFrequencyWeeklyTarget => 'Meta semanal';

  @override
  String get habitsWeekdaysLabel => 'Repetir los días';

  @override
  String get habitsWeeklyTargetLabel => 'Veces por semana';

  @override
  String get habitsCueLabel => 'Señal (opcional)';

  @override
  String get habitsCueHint => 'Después de...';

  @override
  String get habitsMinimumLabel => 'Versión mínima (opcional)';

  @override
  String get habitsMinimumHint => 'Ej.: Leer una página';

  @override
  String get habitsEssentialLabel => 'Hábito esencial';

  @override
  String get habitsReminderLabel => 'Recordatorio opcional';

  @override
  String get habitsChooseReminderAction => 'Elegir hora';

  @override
  String get habitsRemoveReminderAction => 'Quitar recordatorio';

  @override
  String get habitsNotScheduledToday => 'No está programado para hoy';

  @override
  String get habitsSaveAction => 'Guardar hábito';

  @override
  String get habitsCancelAction => 'Cancelar';

  @override
  String get habitsHistoryLabel => 'Últimos 28 días';

  @override
  String get habitsHistoryFull => 'Hecho';

  @override
  String get habitsHistoryMinimum => 'Versión mínima';

  @override
  String get habitsHistoryMissed => 'Sin registro';

  @override
  String get habitsTodayCompleted => 'Hecho hoy';

  @override
  String get habitsArchivedTitle => 'Hábitos archivados';

  @override
  String get habitIconMindfulness => 'Respiración';

  @override
  String get habitIconReading => 'Lectura';

  @override
  String get habitIconMovement => 'Movimiento';

  @override
  String get habitIconWater => 'Pausa';

  @override
  String get weekdayMon => 'Lun';

  @override
  String get weekdayTue => 'Mar';

  @override
  String get weekdayWed => 'Mié';

  @override
  String get weekdayThu => 'Jue';

  @override
  String get weekdayFri => 'Vie';

  @override
  String get weekdaySat => 'Sáb';

  @override
  String get weekdaySun => 'Dom';

  @override
  String get planTitle => 'Tu plan';

  @override
  String get planSubtitle => 'Organiza el día y deja espacio para respirar.';

  @override
  String get planPreviousWeek => 'Semana anterior';

  @override
  String get planNextWeek => 'Próxima semana';

  @override
  String get planTasksTitle => 'Tareas del día';

  @override
  String get planRoutineTitle => 'Rutina';

  @override
  String get planFreeSlotsTitle => 'Tiempo libre';

  @override
  String get planUnscheduledTitle => 'Sin fecha';

  @override
  String get planTasksEmptyTitle => 'Un día abierto';

  @override
  String get planTasksEmptyMessage =>
      'Añade una tarea o elige un horario libre para empezar.';

  @override
  String get planRoutineEmptyTitle => 'Tu rutina empieza aquí';

  @override
  String get planRoutineEmptyMessage =>
      'Crea bloques recurrentes para dar ritmo a la semana.';

  @override
  String get planSlotsEmpty =>
      'No hay intervalos de 25 minutos en este horario.';

  @override
  String get planCreateTask => 'Crear tarea';

  @override
  String get planCreateRoutine => 'Crear bloque';

  @override
  String get planEditTask => 'Editar tarea';

  @override
  String get planEditRoutine => 'Editar bloque';

  @override
  String get planArchiveTask => 'Archivar tarea';

  @override
  String get planArchiveRoutine => 'Archivar bloque';

  @override
  String get planTaskCreateTitle => 'Nueva tarea';

  @override
  String get planRoutineCreateTitle => 'Nuevo bloque de rutina';

  @override
  String get planTaskNameLabel => 'Tarea';

  @override
  String get planTaskNotesLabel => 'Notas (opcional)';

  @override
  String get planTimeLabel => 'Horario';

  @override
  String get planNoTime => 'Sin horario';

  @override
  String get planDurationLabel => 'Duración en minutos';

  @override
  String planDurationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get planPriorityLabel => 'Prioridad';

  @override
  String get planPriorityLow => 'Baja';

  @override
  String get planPriorityNormal => 'Normal';

  @override
  String get planPriorityHigh => 'Alta';

  @override
  String get planRepeatLabel => 'Repetición';

  @override
  String get planRepeatOnce => 'Solo este día';

  @override
  String get planRepeatWeekdays => 'Días elegidos';

  @override
  String get planRepeatOn => 'Repetir los días';

  @override
  String get planRoutineNameLabel => 'Nombre del bloque';

  @override
  String get planRoutineCategoryLabel => 'Área';

  @override
  String get planCategoryMind => 'Mente';

  @override
  String get planCategoryBody => 'Cuerpo';

  @override
  String get planCategoryFocus => 'Enfoque';

  @override
  String get planSaveTask => 'Guardar tarea';

  @override
  String get planSaveRoutine => 'Guardar bloque';

  @override
  String get planCancel => 'Cancelar';

  @override
  String get planConflictTitle => 'Hay horarios superpuestos';

  @override
  String get planConflictMessage =>
      'Revisa los elementos que ocurren al mismo tiempo.';

  @override
  String planConflictPair(String first, String second) {
    return '$first ↔ $second';
  }

  @override
  String get planRemoveTime => 'Quitar horario';

  @override
  String planSuggestedSlot(String time) {
    return 'Libre a las $time';
  }

  @override
  String get planScheduleTask => 'Programar tarea';

  @override
  String get planCompleteTask => 'Completar tarea';

  @override
  String get planTaskCompleted =>
      'Tarea completada. Tu progreso se ha actualizado.';

  @override
  String get planTaskArchived => 'Tarea archivada. Se conservó su historial.';

  @override
  String get planRoutineArchived => 'Bloque archivado.';

  @override
  String get planLoading => 'Cargando tu plan';

  @override
  String get planLoadError =>
      'No se pudo cargar tu plan. Tus datos siguen en este dispositivo.';

  @override
  String get planSaveError =>
      'No se pudo guardar. Tus datos siguen en este dispositivo.';

  @override
  String get planRetry => 'Intentar de nuevo';

  @override
  String get planTaskNoDate => 'Sin fecha definida';

  @override
  String planPrioritySemantics(String priority) {
    return 'Prioridad $priority';
  }
}
