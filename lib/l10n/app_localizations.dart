import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @designCatalogTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Catálogo visual'**
  String get designCatalogTitle;

  /// No description provided for @skillRadarTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Radar de habilidades'**
  String get skillRadarTitle;

  /// No description provided for @skillRadarDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Uma prévia visual com dados falsos. A evolução real será calculada a partir do seu histórico.'**
  String get skillRadarDescription;

  /// No description provided for @skillRadarAccessibleTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Radar de habilidades de exemplo'**
  String get skillRadarAccessibleTitle;

  /// No description provided for @skillConsistency.
  ///
  /// In pt_BR, this message translates to:
  /// **'Constância'**
  String get skillConsistency;

  /// No description provided for @skillFocus.
  ///
  /// In pt_BR, this message translates to:
  /// **'Foco'**
  String get skillFocus;

  /// No description provided for @skillPlanning.
  ///
  /// In pt_BR, this message translates to:
  /// **'Planejamento'**
  String get skillPlanning;

  /// No description provided for @skillEnergy.
  ///
  /// In pt_BR, this message translates to:
  /// **'Energia'**
  String get skillEnergy;

  /// No description provided for @skillStrength.
  ///
  /// In pt_BR, this message translates to:
  /// **'Força'**
  String get skillStrength;

  /// No description provided for @todayGreeting.
  ///
  /// In pt_BR, this message translates to:
  /// **'Bom dia'**
  String get todayGreeting;

  /// No description provided for @todaySubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hoje o mínimo já conta.'**
  String get todaySubtitle;

  /// No description provided for @todayLevelXp.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nível {level} · {xp} XP'**
  String todayLevelXp(int level, int xp);

  /// No description provided for @todayProgressTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Feitos hoje'**
  String get todayProgressTitle;

  /// No description provided for @todayProgressValue.
  ///
  /// In pt_BR, this message translates to:
  /// **'{completed} de {total}'**
  String todayProgressValue(int completed, int total);

  /// No description provided for @todayLoadError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não foi possível carregar seu dia. Seus dados continuam neste aparelho.'**
  String get todayLoadError;

  /// No description provided for @todayActionError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não foi possível salvar essa ação. Seus dados continuam neste aparelho.'**
  String get todayActionError;

  /// No description provided for @retryAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tentar novamente'**
  String get retryAction;

  /// No description provided for @nextActionTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Próxima ação'**
  String get nextActionTitle;

  /// No description provided for @nextActionEmpty.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tudo em ordem por enquanto. Adicione um hábito ou tarefa para começar.'**
  String get nextActionEmpty;

  /// No description provided for @nextActionTask.
  ///
  /// In pt_BR, this message translates to:
  /// **'Separar 10 minutos para organizar a manhã'**
  String get nextActionTask;

  /// No description provided for @completeAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Concluir'**
  String get completeAction;

  /// No description provided for @quickActionsTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ações rápidas'**
  String get quickActionsTitle;

  /// No description provided for @newHabitAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Criar hábito'**
  String get newHabitAction;

  /// No description provided for @newTaskAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Criar tarefa'**
  String get newTaskAction;

  /// No description provided for @quickActionComingSoon.
  ///
  /// In pt_BR, this message translates to:
  /// **'Este atalho será conectado em uma próxima etapa.'**
  String get quickActionComingSoon;

  /// No description provided for @actionCompleted.
  ///
  /// In pt_BR, this message translates to:
  /// **'Concluído. Seu progresso foi atualizado.'**
  String get actionCompleted;

  /// No description provided for @undoAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Desfazer'**
  String get undoAction;

  /// No description provided for @startFocusAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Iniciar foco'**
  String get startFocusAction;

  /// No description provided for @startWorkoutAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Iniciar treino'**
  String get startWorkoutAction;

  /// No description provided for @todayHabitsTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hábitos de hoje'**
  String get todayHabitsTitle;

  /// No description provided for @todayHabitsEmptyTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sem hábitos para hoje'**
  String get todayHabitsEmptyTitle;

  /// No description provided for @todayHabitsEmptyMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'Quando seus hábitos estiverem configurados, eles aparecerão aqui.'**
  String get todayHabitsEmptyMessage;

  /// No description provided for @habitTapToComplete.
  ///
  /// In pt_BR, this message translates to:
  /// **'Toque para marcar como feito'**
  String get habitTapToComplete;

  /// No description provided for @completedStatus.
  ///
  /// In pt_BR, this message translates to:
  /// **'Concluído'**
  String get completedStatus;

  /// No description provided for @daysStreak.
  ///
  /// In pt_BR, this message translates to:
  /// **'{count, plural, =0 {Começando} =1 {1 dia} other {{count} dias}}'**
  String daysStreak(int count);

  /// No description provided for @habitMorning.
  ///
  /// In pt_BR, this message translates to:
  /// **'Respirar por 2 minutos'**
  String get habitMorning;

  /// No description provided for @habitMorningCue.
  ///
  /// In pt_BR, this message translates to:
  /// **'Depois de abrir a janela'**
  String get habitMorningCue;

  /// No description provided for @habitMorningStreak.
  ///
  /// In pt_BR, this message translates to:
  /// **'3 dias'**
  String get habitMorningStreak;

  /// No description provided for @habitReading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ler 10 páginas'**
  String get habitReading;

  /// No description provided for @habitReadingCue.
  ///
  /// In pt_BR, this message translates to:
  /// **'Depois do café'**
  String get habitReadingCue;

  /// No description provided for @habitReadingStreak.
  ///
  /// In pt_BR, this message translates to:
  /// **'5 dias'**
  String get habitReadingStreak;

  /// No description provided for @timelineTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Linha do tempo'**
  String get timelineTitle;

  /// No description provided for @timelineEmpty.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nenhum bloco marcado ainda. Quando você planejar algo, ele aparecerá aqui.'**
  String get timelineEmpty;

  /// No description provided for @welcomeTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Seu dia em um só lugar.'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hábitos, tarefas, rotina e treino — com gentileza nos dias difíceis.'**
  String get welcomeDescription;

  /// No description provided for @continueAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Começar'**
  String get continueAction;

  /// No description provided for @backupLink.
  ///
  /// In pt_BR, this message translates to:
  /// **'Já tenho um backup'**
  String get backupLink;

  /// No description provided for @localDataNote.
  ///
  /// In pt_BR, this message translates to:
  /// **'Seus dados ficam neste aparelho.'**
  String get localDataNote;

  /// No description provided for @navToday.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hoje'**
  String get navToday;

  /// No description provided for @navPlan.
  ///
  /// In pt_BR, this message translates to:
  /// **'Plano'**
  String get navPlan;

  /// No description provided for @navHabits.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hábitos'**
  String get navHabits;

  /// No description provided for @navWorkouts.
  ///
  /// In pt_BR, this message translates to:
  /// **'Treinos'**
  String get navWorkouts;

  /// No description provided for @navEvolution.
  ///
  /// In pt_BR, this message translates to:
  /// **'Evolução'**
  String get navEvolution;

  /// No description provided for @shellComingSoon.
  ///
  /// In pt_BR, this message translates to:
  /// **'Este destino será conectado nas próximas fases.'**
  String get shellComingSoon;

  /// No description provided for @flowRingSemanticLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Progresso do dia'**
  String get flowRingSemanticLabel;

  /// No description provided for @habitsScreenTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Seus hábitos'**
  String get habitsScreenTitle;

  /// No description provided for @habitsListSectionTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Seu ritmo'**
  String get habitsListSectionTitle;

  /// No description provided for @habitsScreenSubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Pequenos passos, no seu ritmo.'**
  String get habitsScreenSubtitle;

  /// No description provided for @habitsCreateAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Criar hábito'**
  String get habitsCreateAction;

  /// No description provided for @habitsEmptyTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Comece com um passo pequeno'**
  String get habitsEmptyTitle;

  /// No description provided for @habitsEmptyMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'Escolha algo simples que você gostaria de repetir. Você pode ajustar depois.'**
  String get habitsEmptyMessage;

  /// No description provided for @habitsLoading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Carregando seus hábitos'**
  String get habitsLoading;

  /// No description provided for @habitsLoadError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não foi possível carregar seus hábitos. Seus dados continuam neste aparelho.'**
  String get habitsLoadError;

  /// No description provided for @habitsErrorTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não foi possível carregar agora'**
  String get habitsErrorTitle;

  /// No description provided for @habitsSaveError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não foi possível salvar o hábito. Seus dados continuam neste aparelho.'**
  String get habitsSaveError;

  /// No description provided for @habitsRetryAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tentar novamente'**
  String get habitsRetryAction;

  /// No description provided for @habitsStreakLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sequência atual'**
  String get habitsStreakLabel;

  /// No description provided for @habitsWeekLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nesta semana'**
  String get habitsWeekLabel;

  /// No description provided for @habitsWeekProgress.
  ///
  /// In pt_BR, this message translates to:
  /// **'{completed} de {target, plural, =1 {1 vez} other {{target} vezes}}'**
  String habitsWeekProgress(int completed, int target);

  /// No description provided for @habitsWeeklyTargetOption.
  ///
  /// In pt_BR, this message translates to:
  /// **'{count, plural, =1 {1 vez por semana} other {{count} vezes por semana}}'**
  String habitsWeeklyTargetOption(int count);

  /// No description provided for @habitsLogFullAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Marcar como feito'**
  String get habitsLogFullAction;

  /// No description provided for @habitsLogMinimumAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fazer versão mínima'**
  String get habitsLogMinimumAction;

  /// No description provided for @habitsEditAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Editar hábito'**
  String get habitsEditAction;

  /// No description provided for @habitsArchiveAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Arquivar hábito'**
  String get habitsArchiveAction;

  /// No description provided for @habitsArchivedMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hábito arquivado. Seu histórico foi preservado.'**
  String get habitsArchivedMessage;

  /// No description provided for @habitsCreateTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Criar hábito'**
  String get habitsCreateTitle;

  /// No description provided for @habitsEditTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Editar hábito'**
  String get habitsEditTitle;

  /// No description provided for @habitsNameLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome do hábito'**
  String get habitsNameLabel;

  /// No description provided for @habitsNameHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ex.: Ler por 10 minutos'**
  String get habitsNameHint;

  /// No description provided for @habitsIconLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ícone'**
  String get habitsIconLabel;

  /// No description provided for @habitsCategoryLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Área'**
  String get habitsCategoryLabel;

  /// No description provided for @habitsCategoryMind.
  ///
  /// In pt_BR, this message translates to:
  /// **'Mente'**
  String get habitsCategoryMind;

  /// No description provided for @habitsCategoryBody.
  ///
  /// In pt_BR, this message translates to:
  /// **'Corpo'**
  String get habitsCategoryBody;

  /// No description provided for @habitsCategoryFocus.
  ///
  /// In pt_BR, this message translates to:
  /// **'Foco'**
  String get habitsCategoryFocus;

  /// No description provided for @habitsFrequencyLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Frequência'**
  String get habitsFrequencyLabel;

  /// No description provided for @habitsFrequencyDaily.
  ///
  /// In pt_BR, this message translates to:
  /// **'Todos os dias'**
  String get habitsFrequencyDaily;

  /// No description provided for @habitsFrequencyWeekdays.
  ///
  /// In pt_BR, this message translates to:
  /// **'Dias escolhidos'**
  String get habitsFrequencyWeekdays;

  /// No description provided for @habitsFrequencyWeeklyTarget.
  ///
  /// In pt_BR, this message translates to:
  /// **'Meta semanal'**
  String get habitsFrequencyWeeklyTarget;

  /// No description provided for @habitsWeekdaysLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Repetir em'**
  String get habitsWeekdaysLabel;

  /// No description provided for @habitsWeeklyTargetLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Vezes por semana'**
  String get habitsWeeklyTargetLabel;

  /// No description provided for @habitsCueLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Gatilho (opcional)'**
  String get habitsCueLabel;

  /// No description provided for @habitsCueHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Depois de...'**
  String get habitsCueHint;

  /// No description provided for @habitsMinimumLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Versão mínima (opcional)'**
  String get habitsMinimumLabel;

  /// No description provided for @habitsMinimumHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ex.: Ler uma página'**
  String get habitsMinimumHint;

  /// No description provided for @habitsEssentialLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hábito essencial'**
  String get habitsEssentialLabel;

  /// No description provided for @habitsReminderLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Lembrete opcional'**
  String get habitsReminderLabel;

  /// No description provided for @habitsChooseReminderAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Escolher horário'**
  String get habitsChooseReminderAction;

  /// No description provided for @habitsRemoveReminderAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Remover lembrete'**
  String get habitsRemoveReminderAction;

  /// No description provided for @habitsNotScheduledToday.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sem repetição programada para hoje'**
  String get habitsNotScheduledToday;

  /// No description provided for @habitsSaveAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Salvar hábito'**
  String get habitsSaveAction;

  /// No description provided for @habitsCancelAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cancelar'**
  String get habitsCancelAction;

  /// No description provided for @habitsHistoryLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Últimos 28 dias'**
  String get habitsHistoryLabel;

  /// No description provided for @habitsHistoryFull.
  ///
  /// In pt_BR, this message translates to:
  /// **'Feito'**
  String get habitsHistoryFull;

  /// No description provided for @habitsHistoryMinimum.
  ///
  /// In pt_BR, this message translates to:
  /// **'Versão mínima'**
  String get habitsHistoryMinimum;

  /// No description provided for @habitsHistoryMissed.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sem registro'**
  String get habitsHistoryMissed;

  /// No description provided for @habitsTodayCompleted.
  ///
  /// In pt_BR, this message translates to:
  /// **'Feito hoje'**
  String get habitsTodayCompleted;

  /// No description provided for @habitsArchivedTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hábitos arquivados'**
  String get habitsArchivedTitle;

  /// No description provided for @habitIconMindfulness.
  ///
  /// In pt_BR, this message translates to:
  /// **'Respiração'**
  String get habitIconMindfulness;

  /// No description provided for @habitIconReading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Leitura'**
  String get habitIconReading;

  /// No description provided for @habitIconMovement.
  ///
  /// In pt_BR, this message translates to:
  /// **'Movimento'**
  String get habitIconMovement;

  /// No description provided for @habitIconWater.
  ///
  /// In pt_BR, this message translates to:
  /// **'Pausa'**
  String get habitIconWater;

  /// No description provided for @weekdayMon.
  ///
  /// In pt_BR, this message translates to:
  /// **'Seg'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ter'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In pt_BR, this message translates to:
  /// **'Qua'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In pt_BR, this message translates to:
  /// **'Qui'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sex'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sáb'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In pt_BR, this message translates to:
  /// **'Dom'**
  String get weekdaySun;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
