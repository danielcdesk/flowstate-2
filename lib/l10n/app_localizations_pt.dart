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

  @override
  String get todayGreeting => 'Bom dia';

  @override
  String get todaySubtitle => 'Hoje o mínimo já conta.';

  @override
  String todayLevelXp(int level, int xp) {
    return 'Nível 2 · 100 XP';
  }

  @override
  String get todayProgressTitle => 'Feitos hoje';

  @override
  String todayProgressValue(int completed, int total) {
    return '3 de 7';
  }

  @override
  String get todayLoadError =>
      'Não foi possível carregar seu dia. Seus dados continuam neste aparelho.';

  @override
  String get todayActionError =>
      'Não foi possível salvar essa ação. Seus dados continuam neste aparelho.';

  @override
  String get retryAction => 'Tentar novamente';

  @override
  String get nextActionTitle => 'Próxima ação';

  @override
  String get nextActionEmpty =>
      'Tudo em ordem por enquanto. Adicione um hábito ou tarefa para começar.';

  @override
  String get nextActionTask => 'Separar 10 minutos para organizar a manhã';

  @override
  String get completeAction => 'Concluir';

  @override
  String get quickActionsTitle => 'Ações rápidas';

  @override
  String get newHabitAction => 'Novo hábito';

  @override
  String get newTaskAction => 'Nova tarefa';

  @override
  String get quickActionComingSoon =>
      'Este atalho será conectado em uma próxima etapa.';

  @override
  String get focusTitle => 'Sessão de foco';

  @override
  String get focusIntro =>
      'Escolha um tempo e avance em uma coisa de cada vez.';

  @override
  String get focusLoading => 'Carregando sua sessão de foco';

  @override
  String get focusLoadError =>
      'Não foi possível carregar seu foco. Seus dados continuam neste aparelho.';

  @override
  String get focusSaveError =>
      'Não foi possível salvar a sessão. Tente novamente.';

  @override
  String get focusChooseDuration => 'Por quanto tempo?';

  @override
  String focusDurationPreset(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '$minutes minuto',
    );
    return '$_temp0';
  }

  @override
  String get focusCustomDuration => 'Personalizado';

  @override
  String get focusDurationField => 'Duração';

  @override
  String get focusMinutesUnit => 'min';

  @override
  String focusDurationLimit(int maximum) {
    return 'Escolha de 1 a $maximum minutos.';
  }

  @override
  String get focusLinkTask => 'Vincular a uma tarefa (opcional)';

  @override
  String get focusNoTask => 'Sem tarefa vinculada';

  @override
  String get focusLocalPersistence =>
      'O prazo fica salvo neste aparelho e continua mesmo se você fechar o app.';

  @override
  String get focusStart => 'Iniciar foco';

  @override
  String get focusInProgress => 'Seu foco está em andamento';

  @override
  String get focusNoTaskActive => 'Um passo de cada vez';

  @override
  String focusTimerSemantics(String time) {
    return 'Tempo restante: $time';
  }

  @override
  String focusCountdown(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get focusKeepsRunning =>
      'Pode sair desta tela. Ao voltar, o tempo restante será atualizado pelo horário salvo.';

  @override
  String get focusStop => 'Encerrar sessão';

  @override
  String get focusStopConfirmationTitle => 'Encerrar agora?';

  @override
  String get focusStopConfirmationMessage =>
      'Esta sessão será encerrada sem recompensa de conclusão.';

  @override
  String focusCompletedSummary(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '$minutes minuto',
    );
    return 'Sessão concluída: $_temp0.';
  }

  @override
  String focusXpPolicy(int minutes, int xp, int limit) {
    return 'Sessões concluídas de $minutes min ou mais rendem $xp XP, em até $limit sessões por dia.';
  }

  @override
  String focusXpEarned(int xp) {
    return 'Você ganhou $xp XP.';
  }

  @override
  String get actionCompleted => 'Concluído. Seu progresso foi atualizado.';

  @override
  String get undoAction => 'Desfazer';

  @override
  String get startFocusAction => 'Iniciar foco';

  @override
  String get startWorkoutAction => 'Iniciar treino';

  @override
  String get todayHabitsTitle => 'Hábitos de hoje';

  @override
  String get todayHabitsEmptyTitle => 'Sem hábitos para hoje';

  @override
  String get todayHabitsEmptyMessage =>
      'Quando seus hábitos estiverem configurados, eles aparecerão aqui.';

  @override
  String get habitTapToComplete => 'Toque para marcar como feito';

  @override
  String get completedStatus => 'Concluído';

  @override
  String daysStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
      zero: 'Começando',
    );
    return '$_temp0';
  }

  @override
  String get habitMorning => 'Respirar por 2 minutos';

  @override
  String get habitMorningCue => 'Depois de abrir a janela';

  @override
  String get habitMorningStreak => '3 dias';

  @override
  String get habitReading => 'Ler 10 páginas';

  @override
  String get habitReadingCue => 'Depois do café';

  @override
  String get habitReadingStreak => '5 dias';

  @override
  String get timelineTitle => 'Linha do tempo';

  @override
  String get timelineEmpty =>
      'Nenhum bloco marcado ainda. Quando você planejar algo, ele aparecerá aqui.';

  @override
  String get welcomeTitle => 'Seu dia em um só lugar.';

  @override
  String get welcomeDescription =>
      'Hábitos, tarefas, rotina e treino — com gentileza nos dias difíceis.';

  @override
  String get continueAction => 'Começar';

  @override
  String get backupLink => 'Já tenho um backup';

  @override
  String get localDataNote => 'Seus dados ficam neste aparelho.';

  @override
  String get navToday => 'Hoje';

  @override
  String get navPlan => 'Plano';

  @override
  String get navHabits => 'Hábitos';

  @override
  String get navWorkouts => 'Treinos';

  @override
  String get navEvolution => 'Evolução';

  @override
  String get shellComingSoon =>
      'Este destino será conectado nas próximas fases.';

  @override
  String get flowRingSemanticLabel => 'Progresso do dia';

  @override
  String get habitsScreenTitle => 'Seus hábitos';

  @override
  String get habitsListSectionTitle => 'Seu ritmo';

  @override
  String get habitsScreenSubtitle => 'Pequenos passos, no seu ritmo.';

  @override
  String get habitsCreateAction => 'Criar hábito';

  @override
  String get habitsEmptyTitle => 'Comece com um passo pequeno';

  @override
  String get habitsEmptyMessage =>
      'Escolha algo simples que você gostaria de repetir. Você pode ajustar depois.';

  @override
  String get habitsLoading => 'Carregando seus hábitos';

  @override
  String get habitsLoadError =>
      'Não foi possível carregar seus hábitos. Seus dados continuam neste aparelho.';

  @override
  String get habitsErrorTitle => 'Não foi possível carregar agora';

  @override
  String get habitsSaveError =>
      'Não foi possível salvar o hábito. Seus dados continuam neste aparelho.';

  @override
  String get habitsRetryAction => 'Tentar novamente';

  @override
  String get habitsStreakLabel => 'Sequência atual';

  @override
  String get habitsWeekLabel => 'Nesta semana';

  @override
  String habitsWeekProgress(int completed, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: '$target vezes',
      one: '1 vez',
    );
    return '$completed de $_temp0';
  }

  @override
  String habitsWeeklyTargetOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vezes por semana',
      one: '1 vez por semana',
    );
    return '$_temp0';
  }

  @override
  String get habitsLogFullAction => 'Marcar como feito';

  @override
  String get habitsLogMinimumAction => 'Fazer versão mínima';

  @override
  String get habitsEditAction => 'Editar hábito';

  @override
  String get habitsArchiveAction => 'Arquivar hábito';

  @override
  String get habitsArchivedMessage =>
      'Hábito arquivado. Seu histórico foi preservado.';

  @override
  String get habitsCreateTitle => 'Criar hábito';

  @override
  String get habitsEditTitle => 'Editar hábito';

  @override
  String get habitsNameLabel => 'Nome do hábito';

  @override
  String get habitsNameHint => 'Ex.: Ler por 10 minutos';

  @override
  String get habitsIconLabel => 'Ícone';

  @override
  String get habitsCategoryLabel => 'Área';

  @override
  String get habitsCategoryMind => 'Mente';

  @override
  String get habitsCategoryBody => 'Corpo';

  @override
  String get habitsCategoryFocus => 'Foco';

  @override
  String get habitsFrequencyLabel => 'Frequência';

  @override
  String get habitsFrequencyDaily => 'Todos os dias';

  @override
  String get habitsFrequencyWeekdays => 'Dias escolhidos';

  @override
  String get habitsFrequencyWeeklyTarget => 'Meta semanal';

  @override
  String get habitsWeekdaysLabel => 'Repetir em';

  @override
  String get habitsWeeklyTargetLabel => 'Vezes por semana';

  @override
  String get habitsCueLabel => 'Gatilho (opcional)';

  @override
  String get habitsCueHint => 'Depois de...';

  @override
  String get habitsMinimumLabel => 'Versão mínima (opcional)';

  @override
  String get habitsMinimumHint => 'Ex.: Ler uma página';

  @override
  String get habitsEssentialLabel => 'Hábito essencial';

  @override
  String get habitsReminderLabel => 'Lembrete opcional';

  @override
  String get habitsChooseReminderAction => 'Escolher horário';

  @override
  String get habitsRemoveReminderAction => 'Remover lembrete';

  @override
  String get habitsNotScheduledToday => 'Sem repetição programada para hoje';

  @override
  String get habitsSaveAction => 'Salvar hábito';

  @override
  String get habitsCancelAction => 'Cancelar';

  @override
  String get habitsHistoryLabel => 'Últimos 28 dias';

  @override
  String get habitsHistoryFull => 'Feito';

  @override
  String get habitsHistoryMinimum => 'Versão mínima';

  @override
  String get habitsHistoryMissed => 'Sem registro';

  @override
  String get habitsTodayCompleted => 'Feito hoje';

  @override
  String get habitsArchivedTitle => 'Hábitos arquivados';

  @override
  String get habitIconMindfulness => 'Respiração';

  @override
  String get habitIconReading => 'Leitura';

  @override
  String get habitIconMovement => 'Movimento';

  @override
  String get habitIconWater => 'Pausa';

  @override
  String get weekdayMon => 'Seg';

  @override
  String get weekdayTue => 'Ter';

  @override
  String get weekdayWed => 'Qua';

  @override
  String get weekdayThu => 'Qui';

  @override
  String get weekdayFri => 'Sex';

  @override
  String get weekdaySat => 'Sáb';

  @override
  String get weekdaySun => 'Dom';

  @override
  String get planTitle => 'Seu plano';

  @override
  String get planSubtitle => 'Organize o dia sem perder espaço para respirar.';

  @override
  String get planPreviousWeek => 'Semana anterior';

  @override
  String get planNextWeek => 'Próxima semana';

  @override
  String get planTasksTitle => 'Tarefas do dia';

  @override
  String get planRoutineTitle => 'Rotina';

  @override
  String get planFreeSlotsTitle => 'Espaços livres';

  @override
  String get planUnscheduledTitle => 'Sem data';

  @override
  String get planTasksEmptyTitle => 'Um dia aberto';

  @override
  String get planTasksEmptyMessage =>
      'Adicione uma tarefa ou escolha um horário livre para começar.';

  @override
  String get planRoutineEmptyTitle => 'Sua rotina começa aqui';

  @override
  String get planRoutineEmptyMessage =>
      'Crie blocos recorrentes para dar ritmo à semana.';

  @override
  String get planSlotsEmpty => 'Não há intervalos de 25 minutos neste período.';

  @override
  String get planCreateTask => 'Criar tarefa';

  @override
  String get planCreateRoutine => 'Criar bloco';

  @override
  String get planEditTask => 'Editar tarefa';

  @override
  String get planStartFocus => 'Iniciar foco nesta tarefa';

  @override
  String get planEditRoutine => 'Editar bloco';

  @override
  String get planArchiveTask => 'Arquivar tarefa';

  @override
  String get planArchiveRoutine => 'Arquivar bloco';

  @override
  String get planTaskCreateTitle => 'Nova tarefa';

  @override
  String get planRoutineCreateTitle => 'Novo bloco de rotina';

  @override
  String get planTaskNameLabel => 'Tarefa';

  @override
  String get planTaskNotesLabel => 'Notas (opcional)';

  @override
  String get planTimeLabel => 'Horário';

  @override
  String get planNoTime => 'Sem horário';

  @override
  String get planDurationLabel => 'Duração em minutos';

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
  String get planPriorityLabel => 'Prioridade';

  @override
  String get planPriorityLow => 'Baixa';

  @override
  String get planPriorityNormal => 'Normal';

  @override
  String get planPriorityHigh => 'Alta';

  @override
  String get planRepeatLabel => 'Repetição';

  @override
  String get planRepeatOnce => 'Só neste dia';

  @override
  String get planRepeatWeekdays => 'Dias escolhidos';

  @override
  String get planRepeatOn => 'Repetir em';

  @override
  String get planRoutineNameLabel => 'Nome do bloco';

  @override
  String get planRoutineCategoryLabel => 'Área';

  @override
  String get planCategoryMind => 'Mente';

  @override
  String get planCategoryBody => 'Corpo';

  @override
  String get planCategoryFocus => 'Foco';

  @override
  String get planSaveTask => 'Salvar tarefa';

  @override
  String get planSaveRoutine => 'Salvar bloco';

  @override
  String get planCancel => 'Cancelar';

  @override
  String get planConflictTitle => 'Há horários sobrepostos';

  @override
  String get planConflictMessage =>
      'Revise os itens que acontecem ao mesmo tempo.';

  @override
  String planConflictPair(String first, String second) {
    return '$first ↔ $second';
  }

  @override
  String get planRemoveTime => 'Remover horário';

  @override
  String planSuggestedSlot(String time) {
    return 'Livre às $time';
  }

  @override
  String get planScheduleTask => 'Agendar tarefa';

  @override
  String get planCompleteTask => 'Concluir tarefa';

  @override
  String get planTaskCompleted =>
      'Tarefa concluída. Seu progresso foi atualizado.';

  @override
  String get planTaskArchived =>
      'Tarefa arquivada. Seu histórico foi preservado.';

  @override
  String get planRoutineArchived => 'Bloco arquivado.';

  @override
  String get planLoading => 'Carregando seu plano';

  @override
  String get planLoadError =>
      'Não foi possível carregar seu plano. Seus dados continuam neste aparelho.';

  @override
  String get planSaveError =>
      'Não foi possível salvar. Seus dados continuam neste aparelho.';

  @override
  String get planRetry => 'Tentar novamente';

  @override
  String get planTaskNoDate => 'Sem data definida';

  @override
  String planPrioritySemantics(String priority) {
    return 'Prioridade $priority';
  }

  @override
  String get evolutionTitle => 'Sua evolução';

  @override
  String get evolutionSubtitle =>
      'Veja o que seu histórico já está construindo, sem comparação e sem culpa.';

  @override
  String get evolutionLoading => 'Carregando sua evolução';

  @override
  String get evolutionLoadError =>
      'Não foi possível carregar sua evolução. Seus dados continuam neste aparelho.';

  @override
  String evolutionLevelXp(int level, int xp) {
    return 'Nível $level · $xp XP acumulados';
  }

  @override
  String get evolutionRadarTitle => 'Radar de habilidades';

  @override
  String get evolutionRadarAccessible =>
      'Radar de habilidades calculado pelo seu histórico';

  @override
  String get evolutionSkillHabits => 'Hábitos';

  @override
  String get evolutionSkillPlanning => 'Planejamento';

  @override
  String get evolutionSkillFocus => 'Foco';

  @override
  String get evolutionWeeklyTitle => 'Revisão das últimas duas semanas';

  @override
  String get evolutionWeeklyEmptyTitle => 'Sua revisão ainda está se formando';

  @override
  String get evolutionWeeklyEmptyMessage =>
      'Depois de 14 dias completos, aparecem padrões úteis do seu ritmo.';

  @override
  String get evolutionWeeklyNoInsights =>
      'Ainda não há um padrão forte para destacar.';

  @override
  String get evolutionInsightStrongestDay => 'Dia mais consistente';

  @override
  String get evolutionInsightMostMissedHabit => 'Hábito que mais pede atenção';

  @override
  String get evolutionInsightTypicalTime => 'Horário mais comum';

  @override
  String get evolutionInsightBestFocus => 'Melhor horário de foco';

  @override
  String get evolutionInsightBalance => 'Treino e recuperação';

  @override
  String evolutionInsightWeekdayValue(String weekday) {
    return 'Dia da semana $weekday';
  }

  @override
  String evolutionInsightMinuteValue(String minute) {
    return 'Por volta do minuto $minute do dia';
  }

  @override
  String evolutionInsightHourValue(String hour) {
    return 'Por volta de ${hour}h';
  }

  @override
  String evolutionInsightBalanceValue(int workout, int recovery) {
    return '$workout treino · $recovery recuperação';
  }

  @override
  String evolutionAnnualTitle(int year) {
    return 'Retrospectiva $year';
  }

  @override
  String get evolutionAnnualLocked =>
      'Retrospectiva anual bloqueada até o fim do ano';

  @override
  String get evolutionAnnualLockedTitle =>
      'Sua história ainda está acontecendo';

  @override
  String evolutionAnnualLockedMessage(int yearPlusOne) {
    return 'No começo de $yearPlusOne, você poderá percorrer seus marcos deste ano.';
  }

  @override
  String get evolutionAnnualEmptyTitle => 'Um ano para começar';

  @override
  String get evolutionAnnualEmptyMessage =>
      'Quando houver registros, eles aparecerão aqui em uma linha do tempo.';

  @override
  String evolutionEventDate(String date) {
    return 'Em $date';
  }

  @override
  String get evolutionEventHabit => 'Hábito concluído';

  @override
  String get evolutionEventTask => 'Tarefa concluída';

  @override
  String evolutionEventFocus(int minutes) {
    return 'Foco por $minutes minutos';
  }

  @override
  String get evolutionEventMilestone => 'Marco pessoal';

  @override
  String get workoutsTitle => 'Treinos';

  @override
  String get workoutsSubtitle =>
      'Registre séries, cargas e descansos no seu ritmo.';

  @override
  String get workoutsLoading => 'Carregando seus treinos';

  @override
  String get workoutsLoadError =>
      'Não foi possível carregar seus treinos. Seus dados continuam neste aparelho.';

  @override
  String get workoutsEmptyTitle => 'Comece com um treino simples';

  @override
  String get workoutsEmptyMessage =>
      'Um plano inicial ajuda você a começar sem decidir tudo agora.';

  @override
  String get workoutsCreateStarter => 'Criar treino inicial';

  @override
  String get workoutsStarterTitle => 'Força essencial';

  @override
  String get workoutsStart => 'Iniciar treino';

  @override
  String workoutsExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercícios',
      one: '1 exercício',
    );
    return '$_temp0';
  }

  @override
  String get workoutsInProgress => 'Treino em andamento';

  @override
  String workoutsElapsed(String time) {
    return 'Começou às $time';
  }

  @override
  String workoutsSetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séries registradas',
      one: '1 série registrada',
      zero: 'Nenhuma série registrada',
    );
    return '$_temp0';
  }

  @override
  String workoutsRestRemaining(int seconds) {
    return 'Descanso restante: $seconds segundos';
  }

  @override
  String workoutsRecordSet(String exercise) {
    return 'Registrar série de $exercise';
  }

  @override
  String get workoutsFinish => 'Concluir treino';

  @override
  String get onboardingSettings => 'Configurar módulos';

  @override
  String get onboardingTitle => 'Monte seu Flow';

  @override
  String get onboardingSubtitle =>
      'Escolha o que faz sentido agora. Você pode mudar depois sem apagar seus dados.';

  @override
  String get onboardingLoading => 'Carregando suas preferências';

  @override
  String get onboardingTemplatesTitle => 'Comece com um modelo';

  @override
  String get onboardingTemplateMorning => 'Manhã produtiva';

  @override
  String get onboardingTemplateMorningDescription =>
      'Hábitos, plano e foco para organizar o começo do dia.';

  @override
  String get onboardingTemplateStrength => 'Calistenia iniciante 3x por semana';

  @override
  String get onboardingTemplateStrengthDescription =>
      'Hábitos, plano e treinos leves para criar ritmo.';

  @override
  String get onboardingModulesTitle => 'Módulos ativos';

  @override
  String get onboardingModuleHabits => 'Hábitos';

  @override
  String get onboardingModuleHabitsDescription =>
      'Repetições gentis e versões mínimas.';

  @override
  String get onboardingModulePlanning => 'Plano';

  @override
  String get onboardingModulePlanningDescription => 'Tarefas e rotina semanal.';

  @override
  String get onboardingModuleFocus => 'Foco';

  @override
  String get onboardingModuleFocusDescription => 'Sessões por prazo salvo.';

  @override
  String get onboardingModuleWorkouts => 'Treinos';

  @override
  String get onboardingModuleWorkoutsDescription =>
      'Séries, cargas e descanso.';

  @override
  String get onboardingSave => 'Salvar preferências';

  @override
  String get onboardingSaveError =>
      'Não foi possível salvar. Seus dados continuam neste aparelho.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

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

  @override
  String get todayGreeting => 'Bom dia';

  @override
  String get todaySubtitle => 'Hoje o mínimo já conta.';

  @override
  String todayLevelXp(int level, int xp) {
    return 'Nível $level · $xp XP';
  }

  @override
  String get todayProgressTitle => 'Feitos hoje';

  @override
  String todayProgressValue(int completed, int total) {
    return '$completed de $total';
  }

  @override
  String get todayLoadError =>
      'Não foi possível carregar seu dia. Seus dados continuam neste aparelho.';

  @override
  String get todayActionError =>
      'Não foi possível salvar essa ação. Seus dados continuam neste aparelho.';

  @override
  String get retryAction => 'Tentar novamente';

  @override
  String get nextActionTitle => 'Próxima ação';

  @override
  String get nextActionEmpty =>
      'Tudo em ordem por enquanto. Adicione um hábito ou tarefa para começar.';

  @override
  String get nextActionTask => 'Separar 10 minutos para organizar a manhã';

  @override
  String get completeAction => 'Concluir';

  @override
  String get quickActionsTitle => 'Ações rápidas';

  @override
  String get newHabitAction => 'Criar hábito';

  @override
  String get newTaskAction => 'Criar tarefa';

  @override
  String get quickActionComingSoon =>
      'Este atalho será conectado em uma próxima etapa.';

  @override
  String get focusTitle => 'Sessão de foco';

  @override
  String get focusIntro =>
      'Escolha um tempo e avance em uma coisa de cada vez.';

  @override
  String get focusLoading => 'Carregando sua sessão de foco';

  @override
  String get focusLoadError =>
      'Não foi possível carregar seu foco. Seus dados continuam neste aparelho.';

  @override
  String get focusSaveError =>
      'Não foi possível salvar a sessão. Tente novamente.';

  @override
  String get focusChooseDuration => 'Por quanto tempo?';

  @override
  String focusDurationPreset(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '$minutes minuto',
    );
    return '$_temp0';
  }

  @override
  String get focusCustomDuration => 'Personalizado';

  @override
  String get focusDurationField => 'Duração';

  @override
  String get focusMinutesUnit => 'min';

  @override
  String focusDurationLimit(int maximum) {
    return 'Escolha de 1 a $maximum minutos.';
  }

  @override
  String get focusLinkTask => 'Vincular a uma tarefa (opcional)';

  @override
  String get focusNoTask => 'Sem tarefa vinculada';

  @override
  String get focusLocalPersistence =>
      'O prazo fica salvo neste aparelho e continua mesmo se você fechar o app.';

  @override
  String get focusStart => 'Iniciar foco';

  @override
  String get focusInProgress => 'Seu foco está em andamento';

  @override
  String get focusNoTaskActive => 'Um passo de cada vez';

  @override
  String focusTimerSemantics(String time) {
    return 'Tempo restante: $time';
  }

  @override
  String focusCountdown(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get focusKeepsRunning =>
      'Pode sair desta tela. Ao voltar, o tempo restante será atualizado pelo horário salvo.';

  @override
  String get focusStop => 'Encerrar sessão';

  @override
  String get focusStopConfirmationTitle => 'Encerrar agora?';

  @override
  String get focusStopConfirmationMessage =>
      'Esta sessão será encerrada sem recompensa de conclusão.';

  @override
  String focusCompletedSummary(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '$minutes minuto',
    );
    return 'Sessão concluída: $_temp0.';
  }

  @override
  String focusXpPolicy(int minutes, int xp, int limit) {
    return 'Sessões concluídas de $minutes min ou mais rendem $xp XP, em até $limit sessões por dia.';
  }

  @override
  String focusXpEarned(int xp) {
    return 'Você ganhou $xp XP.';
  }

  @override
  String get actionCompleted => 'Concluído. Seu progresso foi atualizado.';

  @override
  String get undoAction => 'Desfazer';

  @override
  String get startFocusAction => 'Iniciar foco';

  @override
  String get startWorkoutAction => 'Iniciar treino';

  @override
  String get todayHabitsTitle => 'Hábitos de hoje';

  @override
  String get todayHabitsEmptyTitle => 'Sem hábitos para hoje';

  @override
  String get todayHabitsEmptyMessage =>
      'Quando seus hábitos estiverem configurados, eles aparecerão aqui.';

  @override
  String get habitTapToComplete => 'Toque para marcar como feito';

  @override
  String get completedStatus => 'Concluído';

  @override
  String daysStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
      zero: 'Começando',
    );
    return '$_temp0';
  }

  @override
  String get habitMorning => 'Respirar por 2 minutos';

  @override
  String get habitMorningCue => 'Depois de abrir a janela';

  @override
  String get habitMorningStreak => '3 dias';

  @override
  String get habitReading => 'Ler 10 páginas';

  @override
  String get habitReadingCue => 'Depois do café';

  @override
  String get habitReadingStreak => '5 dias';

  @override
  String get timelineTitle => 'Linha do tempo';

  @override
  String get timelineEmpty =>
      'Nenhum bloco marcado ainda. Quando você planejar algo, ele aparecerá aqui.';

  @override
  String get welcomeTitle => 'Seu dia em um só lugar.';

  @override
  String get welcomeDescription =>
      'Hábitos, tarefas, rotina e treino — com gentileza nos dias difíceis.';

  @override
  String get continueAction => 'Começar';

  @override
  String get backupLink => 'Já tenho um backup';

  @override
  String get localDataNote => 'Seus dados ficam neste aparelho.';

  @override
  String get navToday => 'Hoje';

  @override
  String get navPlan => 'Plano';

  @override
  String get navHabits => 'Hábitos';

  @override
  String get navWorkouts => 'Treinos';

  @override
  String get navEvolution => 'Evolução';

  @override
  String get shellComingSoon =>
      'Este destino será conectado nas próximas fases.';

  @override
  String get flowRingSemanticLabel => 'Progresso do dia';

  @override
  String get habitsScreenTitle => 'Seus hábitos';

  @override
  String get habitsListSectionTitle => 'Seu ritmo';

  @override
  String get habitsScreenSubtitle => 'Pequenos passos, no seu ritmo.';

  @override
  String get habitsCreateAction => 'Criar hábito';

  @override
  String get habitsEmptyTitle => 'Comece com um passo pequeno';

  @override
  String get habitsEmptyMessage =>
      'Escolha algo simples que você gostaria de repetir. Você pode ajustar depois.';

  @override
  String get habitsLoading => 'Carregando seus hábitos';

  @override
  String get habitsLoadError =>
      'Não foi possível carregar seus hábitos. Seus dados continuam neste aparelho.';

  @override
  String get habitsErrorTitle => 'Não foi possível carregar agora';

  @override
  String get habitsSaveError =>
      'Não foi possível salvar o hábito. Seus dados continuam neste aparelho.';

  @override
  String get habitsRetryAction => 'Tentar novamente';

  @override
  String get habitsStreakLabel => 'Sequência atual';

  @override
  String get habitsWeekLabel => 'Nesta semana';

  @override
  String habitsWeekProgress(int completed, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: '$target vezes',
      one: '1 vez',
    );
    return '$completed de $_temp0';
  }

  @override
  String habitsWeeklyTargetOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vezes por semana',
      one: '1 vez por semana',
    );
    return '$_temp0';
  }

  @override
  String get habitsLogFullAction => 'Marcar como feito';

  @override
  String get habitsLogMinimumAction => 'Fazer versão mínima';

  @override
  String get habitsEditAction => 'Editar hábito';

  @override
  String get habitsArchiveAction => 'Arquivar hábito';

  @override
  String get habitsArchivedMessage =>
      'Hábito arquivado. Seu histórico foi preservado.';

  @override
  String get habitsCreateTitle => 'Criar hábito';

  @override
  String get habitsEditTitle => 'Editar hábito';

  @override
  String get habitsNameLabel => 'Nome do hábito';

  @override
  String get habitsNameHint => 'Ex.: Ler por 10 minutos';

  @override
  String get habitsIconLabel => 'Ícone';

  @override
  String get habitsCategoryLabel => 'Área';

  @override
  String get habitsCategoryMind => 'Mente';

  @override
  String get habitsCategoryBody => 'Corpo';

  @override
  String get habitsCategoryFocus => 'Foco';

  @override
  String get habitsFrequencyLabel => 'Frequência';

  @override
  String get habitsFrequencyDaily => 'Todos os dias';

  @override
  String get habitsFrequencyWeekdays => 'Dias escolhidos';

  @override
  String get habitsFrequencyWeeklyTarget => 'Meta semanal';

  @override
  String get habitsWeekdaysLabel => 'Repetir em';

  @override
  String get habitsWeeklyTargetLabel => 'Vezes por semana';

  @override
  String get habitsCueLabel => 'Gatilho (opcional)';

  @override
  String get habitsCueHint => 'Depois de...';

  @override
  String get habitsMinimumLabel => 'Versão mínima (opcional)';

  @override
  String get habitsMinimumHint => 'Ex.: Ler uma página';

  @override
  String get habitsEssentialLabel => 'Hábito essencial';

  @override
  String get habitsReminderLabel => 'Lembrete opcional';

  @override
  String get habitsChooseReminderAction => 'Escolher horário';

  @override
  String get habitsRemoveReminderAction => 'Remover lembrete';

  @override
  String get habitsNotScheduledToday => 'Sem repetição programada para hoje';

  @override
  String get habitsSaveAction => 'Salvar hábito';

  @override
  String get habitsCancelAction => 'Cancelar';

  @override
  String get habitsHistoryLabel => 'Últimos 28 dias';

  @override
  String get habitsHistoryFull => 'Feito';

  @override
  String get habitsHistoryMinimum => 'Versão mínima';

  @override
  String get habitsHistoryMissed => 'Sem registro';

  @override
  String get habitsTodayCompleted => 'Feito hoje';

  @override
  String get habitsArchivedTitle => 'Hábitos arquivados';

  @override
  String get habitIconMindfulness => 'Respiração';

  @override
  String get habitIconReading => 'Leitura';

  @override
  String get habitIconMovement => 'Movimento';

  @override
  String get habitIconWater => 'Pausa';

  @override
  String get weekdayMon => 'Seg';

  @override
  String get weekdayTue => 'Ter';

  @override
  String get weekdayWed => 'Qua';

  @override
  String get weekdayThu => 'Qui';

  @override
  String get weekdayFri => 'Sex';

  @override
  String get weekdaySat => 'Sáb';

  @override
  String get weekdaySun => 'Dom';

  @override
  String get planTitle => 'Seu plano';

  @override
  String get planSubtitle => 'Organize o dia sem perder espaço para respirar.';

  @override
  String get planPreviousWeek => 'Semana anterior';

  @override
  String get planNextWeek => 'Próxima semana';

  @override
  String get planTasksTitle => 'Tarefas do dia';

  @override
  String get planRoutineTitle => 'Rotina';

  @override
  String get planFreeSlotsTitle => 'Espaços livres';

  @override
  String get planUnscheduledTitle => 'Sem data';

  @override
  String get planTasksEmptyTitle => 'Um dia aberto';

  @override
  String get planTasksEmptyMessage =>
      'Adicione uma tarefa ou escolha um horário livre para começar.';

  @override
  String get planRoutineEmptyTitle => 'Sua rotina começa aqui';

  @override
  String get planRoutineEmptyMessage =>
      'Crie blocos recorrentes para dar ritmo à semana.';

  @override
  String get planSlotsEmpty => 'Não há intervalos de 25 minutos neste período.';

  @override
  String get planCreateTask => 'Criar tarefa';

  @override
  String get planCreateRoutine => 'Criar bloco';

  @override
  String get planEditTask => 'Editar tarefa';

  @override
  String get planStartFocus => 'Iniciar foco nesta tarefa';

  @override
  String get planEditRoutine => 'Editar bloco';

  @override
  String get planArchiveTask => 'Arquivar tarefa';

  @override
  String get planArchiveRoutine => 'Arquivar bloco';

  @override
  String get planTaskCreateTitle => 'Nova tarefa';

  @override
  String get planRoutineCreateTitle => 'Novo bloco de rotina';

  @override
  String get planTaskNameLabel => 'Tarefa';

  @override
  String get planTaskNotesLabel => 'Notas (opcional)';

  @override
  String get planTimeLabel => 'Horário';

  @override
  String get planNoTime => 'Sem horário';

  @override
  String get planDurationLabel => 'Duração em minutos';

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
  String get planPriorityLabel => 'Prioridade';

  @override
  String get planPriorityLow => 'Baixa';

  @override
  String get planPriorityNormal => 'Normal';

  @override
  String get planPriorityHigh => 'Alta';

  @override
  String get planRepeatLabel => 'Repetição';

  @override
  String get planRepeatOnce => 'Só neste dia';

  @override
  String get planRepeatWeekdays => 'Dias escolhidos';

  @override
  String get planRepeatOn => 'Repetir em';

  @override
  String get planRoutineNameLabel => 'Nome do bloco';

  @override
  String get planRoutineCategoryLabel => 'Área';

  @override
  String get planCategoryMind => 'Mente';

  @override
  String get planCategoryBody => 'Corpo';

  @override
  String get planCategoryFocus => 'Foco';

  @override
  String get planSaveTask => 'Salvar tarefa';

  @override
  String get planSaveRoutine => 'Salvar bloco';

  @override
  String get planCancel => 'Cancelar';

  @override
  String get planConflictTitle => 'Há horários sobrepostos';

  @override
  String get planConflictMessage =>
      'Revise os itens que acontecem ao mesmo tempo.';

  @override
  String planConflictPair(String first, String second) {
    return '$first ↔ $second';
  }

  @override
  String get planRemoveTime => 'Remover horário';

  @override
  String planSuggestedSlot(String time) {
    return 'Livre às $time';
  }

  @override
  String get planScheduleTask => 'Agendar tarefa';

  @override
  String get planCompleteTask => 'Concluir tarefa';

  @override
  String get planTaskCompleted =>
      'Tarefa concluída. Seu progresso foi atualizado.';

  @override
  String get planTaskArchived =>
      'Tarefa arquivada. Seu histórico foi preservado.';

  @override
  String get planRoutineArchived => 'Bloco arquivado.';

  @override
  String get planLoading => 'Carregando seu plano';

  @override
  String get planLoadError =>
      'Não foi possível carregar seu plano. Seus dados continuam neste aparelho.';

  @override
  String get planSaveError =>
      'Não foi possível salvar. Seus dados continuam neste aparelho.';

  @override
  String get planRetry => 'Tentar novamente';

  @override
  String get planTaskNoDate => 'Sem data definida';

  @override
  String planPrioritySemantics(String priority) {
    return 'Prioridade $priority';
  }

  @override
  String get evolutionTitle => 'Sua evolução';

  @override
  String get evolutionSubtitle =>
      'Veja o que seu histórico já está construindo, sem comparação e sem culpa.';

  @override
  String get evolutionLoading => 'Carregando sua evolução';

  @override
  String get evolutionLoadError =>
      'Não foi possível carregar sua evolução. Seus dados continuam neste aparelho.';

  @override
  String evolutionLevelXp(int level, int xp) {
    return 'Nível $level · $xp XP acumulados';
  }

  @override
  String get evolutionRadarTitle => 'Radar de habilidades';

  @override
  String get evolutionRadarAccessible =>
      'Radar de habilidades calculado pelo seu histórico';

  @override
  String get evolutionSkillHabits => 'Hábitos';

  @override
  String get evolutionSkillPlanning => 'Planejamento';

  @override
  String get evolutionSkillFocus => 'Foco';

  @override
  String get evolutionWeeklyTitle => 'Revisão das últimas duas semanas';

  @override
  String get evolutionWeeklyEmptyTitle => 'Sua revisão ainda está se formando';

  @override
  String get evolutionWeeklyEmptyMessage =>
      'Depois de 14 dias completos, aparecem padrões úteis do seu ritmo.';

  @override
  String get evolutionWeeklyNoInsights =>
      'Ainda não há um padrão forte para destacar.';

  @override
  String get evolutionInsightStrongestDay => 'Dia mais consistente';

  @override
  String get evolutionInsightMostMissedHabit => 'Hábito que mais pede atenção';

  @override
  String get evolutionInsightTypicalTime => 'Horário mais comum';

  @override
  String get evolutionInsightBestFocus => 'Melhor horário de foco';

  @override
  String get evolutionInsightBalance => 'Treino e recuperação';

  @override
  String evolutionInsightWeekdayValue(String weekday) {
    return 'Dia da semana $weekday';
  }

  @override
  String evolutionInsightMinuteValue(String minute) {
    return 'Por volta do minuto $minute do dia';
  }

  @override
  String evolutionInsightHourValue(String hour) {
    return 'Por volta de ${hour}h';
  }

  @override
  String evolutionInsightBalanceValue(int workout, int recovery) {
    return '$workout treino · $recovery recuperação';
  }

  @override
  String evolutionAnnualTitle(int year) {
    return 'Retrospectiva $year';
  }

  @override
  String get evolutionAnnualLocked =>
      'Retrospectiva anual bloqueada até o fim do ano';

  @override
  String get evolutionAnnualLockedTitle =>
      'Sua história ainda está acontecendo';

  @override
  String evolutionAnnualLockedMessage(int yearPlusOne) {
    return 'No começo de $yearPlusOne, você poderá percorrer seus marcos deste ano.';
  }

  @override
  String get evolutionAnnualEmptyTitle => 'Um ano para começar';

  @override
  String get evolutionAnnualEmptyMessage =>
      'Quando houver registros, eles aparecerão aqui em uma linha do tempo.';

  @override
  String evolutionEventDate(String date) {
    return 'Em $date';
  }

  @override
  String get evolutionEventHabit => 'Hábito concluído';

  @override
  String get evolutionEventTask => 'Tarefa concluída';

  @override
  String evolutionEventFocus(int minutes) {
    return 'Foco por $minutes minutos';
  }

  @override
  String get evolutionEventMilestone => 'Marco pessoal';

  @override
  String get workoutsTitle => 'Treinos';

  @override
  String get workoutsSubtitle =>
      'Registre séries, cargas e descansos no seu ritmo.';

  @override
  String get workoutsLoading => 'Carregando seus treinos';

  @override
  String get workoutsLoadError =>
      'Não foi possível carregar seus treinos. Seus dados continuam neste aparelho.';

  @override
  String get workoutsEmptyTitle => 'Comece com um treino simples';

  @override
  String get workoutsEmptyMessage =>
      'Um plano inicial ajuda você a começar sem decidir tudo agora.';

  @override
  String get workoutsCreateStarter => 'Criar treino inicial';

  @override
  String get workoutsStarterTitle => 'Força essencial';

  @override
  String get workoutsStart => 'Iniciar treino';

  @override
  String workoutsExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercícios',
      one: '1 exercício',
    );
    return '$_temp0';
  }

  @override
  String get workoutsInProgress => 'Treino em andamento';

  @override
  String workoutsElapsed(String time) {
    return 'Começou às $time';
  }

  @override
  String workoutsSetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séries registradas',
      one: '1 série registrada',
      zero: 'Nenhuma série registrada',
    );
    return '$_temp0';
  }

  @override
  String workoutsRestRemaining(int seconds) {
    return 'Descanso restante: $seconds segundos';
  }

  @override
  String workoutsRecordSet(String exercise) {
    return 'Registrar série de $exercise';
  }

  @override
  String get workoutsFinish => 'Concluir treino';

  @override
  String get onboardingSettings => 'Configurar módulos';

  @override
  String get onboardingTitle => 'Monte seu Flow';

  @override
  String get onboardingSubtitle =>
      'Escolha o que faz sentido agora. Você pode mudar depois sem apagar seus dados.';

  @override
  String get onboardingLoading => 'Carregando suas preferências';

  @override
  String get onboardingTemplatesTitle => 'Comece com um modelo';

  @override
  String get onboardingTemplateMorning => 'Manhã produtiva';

  @override
  String get onboardingTemplateMorningDescription =>
      'Hábitos, plano e foco para organizar o começo do dia.';

  @override
  String get onboardingTemplateStrength => 'Calistenia iniciante 3x por semana';

  @override
  String get onboardingTemplateStrengthDescription =>
      'Hábitos, plano e treinos leves para criar ritmo.';

  @override
  String get onboardingModulesTitle => 'Módulos ativos';

  @override
  String get onboardingModuleHabits => 'Hábitos';

  @override
  String get onboardingModuleHabitsDescription =>
      'Repetições gentis e versões mínimas.';

  @override
  String get onboardingModulePlanning => 'Plano';

  @override
  String get onboardingModulePlanningDescription => 'Tarefas e rotina semanal.';

  @override
  String get onboardingModuleFocus => 'Foco';

  @override
  String get onboardingModuleFocusDescription => 'Sessões por prazo salvo.';

  @override
  String get onboardingModuleWorkouts => 'Treinos';

  @override
  String get onboardingModuleWorkoutsDescription =>
      'Séries, cargas e descanso.';

  @override
  String get onboardingSave => 'Salvar preferências';

  @override
  String get onboardingSaveError =>
      'Não foi possível salvar. Seus dados continuam neste aparelho.';
}
