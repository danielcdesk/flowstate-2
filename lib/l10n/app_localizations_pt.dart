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
  String get todayLevelXp => 'Nível 2 · 100 XP';

  @override
  String get todayProgressTitle => 'Feitos hoje';

  @override
  String get todayProgressValue => '3 de 7';

  @override
  String get nextActionTitle => 'Próxima ação';

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
  String get startFocusAction => 'Iniciar foco';

  @override
  String get startWorkoutAction => 'Iniciar treino';

  @override
  String get todayHabitsTitle => 'Hábitos de hoje';

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
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');
}
